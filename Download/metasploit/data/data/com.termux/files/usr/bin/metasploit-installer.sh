#!/data/data/com.termux/files/usr/bin/bash
set -e
export PREFIX=/data/data/com.termux/files/usr
export TMPDIR=/data/data/com.termux/files/usr/tmp
export MSF_VERSION=5.0.65

# Lock terminal to prevent sending text input and special key
# combinations that may break installation process.
stty -echo -icanon time 0 min 0 intr undef quit undef susp undef

# Use trap to unlock terminal at exit.
trap 'while read -r; do true; done; stty sane;' EXIT

if [ "$(id -u)" = "0" ]; then
	echo "[!] Do not install Termux packages as root :)"
	exit 1
fi

echo "[*] Downloading Metasploit Framework..."
mkdir -p "$TMPDIR"
rm -f "$TMPDIR/metasploit-$MSF_VERSION.tar.gz"
curl --fail --retry 3 --location --output "$TMPDIR/metasploit-$MSF_VERSION.tar.gz" \
	"https://github.com/rapid7/metasploit-framework/archive/$MSF_VERSION.tar.gz"

echo "[*] Removing previous version Metasploit Framework..."
rm -rf "$PREFIX"/opt/metasploit-framework

echo "[*] Extracting new version of Metasploit Framework..."
mkdir -p "$PREFIX"/opt/metasploit-framework
tar zxf "$TMPDIR/metasploit-$MSF_VERSION.tar.gz" --strip-components=1 \
	-C "$PREFIX"/opt/metasploit-framework

echo "[*] Installing 'rubygems-update' if necessary..."
if [ "$(gem list -i rubygems-update 2>/dev/null)" = "false" ]; then
	gem install --no-document --verbose rubygems-update
fi

echo "[*] Updating Ruby gems..."
update_rubygems

echo "[*] Installing 'bundler:1.17.3'..."
gem install --no-document --verbose bundler:1.17.3

echo "[*] Installing Metasploit dependencies (may take long time)..."
cd "$PREFIX"/opt/metasploit-framework
bundle config build.nokogiri --use-system-libraries
bundle install --jobs=2 --verbose

echo "[*] Running fixes..."
sed -i "s@/etc/resolv.conf@$PREFIX/etc/resolv.conf@g" "$PREFIX"/opt/metasploit-framework/lib/net/dns/resolver.rb
find "$PREFIX"/opt/metasploit-framework -type f -executable -print0 | xargs -0 -r termux-fix-shebang
find "$PREFIX"/lib/ruby/gems -type f -iname \*.so -print0 | xargs -0 -r termux-elf-cleaner

echo "[*] Setting up PostgreSQL database..."
mkdir -p "$PREFIX"/opt/metasploit-framework/config
cat <<- EOF > "$PREFIX"/opt/metasploit-framework/config/database.yml
production:
  adapter: postgresql
  database: msf_database
  username: msf
  password:
  host: 127.0.0.1
  port: 5432
  pool: 75
  timeout: 5
EOF
mkdir -p "$PREFIX"/var/lib/postgresql
pg_ctl -D "$PREFIX"/var/lib/postgresql stop > /dev/null 2>&1 || true
if ! pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent; then
    initdb "$PREFIX"/var/lib/postgresql
    pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent
fi
if [ -z "$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='msf'")" ]; then
    createuser msf
fi
if [ -z "$(psql -l | grep msf_database)" ]; then
    createdb msf_database
fi

echo "[*] Metasploit Framework installation finished."

exit 0

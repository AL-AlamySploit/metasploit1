A7Y='\033[01;32m'
echo
echo "$A7Y █████╗ ██╗       █████╗ ██╗      █████╗ ███╗   ███╗██╗   ██╗";
echo "$A7Y██╔══██╗██║      ██╔══██╗██║     ██╔══██╗████╗ ████║╚██╗ ██╔╝";
echo "$A7Y███████║██║█████╗███████║██║     ███████║██╔████╔██║ ╚████╔╝";
echo "$A7Y██╔══██║██║╚════╝██╔══██║██║     ██╔══██║██║╚██╔╝██║  ╚██╔╝";
echo "$A7Y██║  ██║███████╗ ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║   ██║";
echo "$A7Y╚═╝  ╚═╝╚══════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝   ╚═╝";
echo
echo
echo "$A7Y[The code By With Metasploit]"

printf "${A7Y}[+] witing to Down..  ..\n"

apt upgrade –y
pkg install wget
pkg install curl
pkg install openssh
pkg install git –y
apt install ruby
gem install bundle
gem install bundler
pip install bundle
gem update --system
git clone https://github.com/rapid7/metasploit-framework.git
ls
cd metasploit-framework
./msfconsole

#!/bin/bash
####################################################################################################################

#incorporate brad's signatures in to signatures/cross, remove andromedia/dridex_apis/chimera_api/deletes_self/cryptowall_apis


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
gitdir=$PWD

##Logging setup
logfile=/var/log/mobsf_install.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

##Functions
function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

function error_check
{

if [ $? -eq 0 ]; then
	print_good "$1 successfully."
else
	print_error "$1 failed. Please check $logfile for more details."
exit 1
fi

}

function install_packages()
{

apt-get update &>> $logfile && apt-get install -y --allow-unauthenticated ${@} &>> $logfile
error_check 'Package installation completed'

}

function dir_check()
{

if [ ! -d $1 ]; then
	print_notification "$1 does not exist. Creating.."
	mkdir -p $1
else
	print_notification "$1 already exists. (No problem, We'll use it anyhow)"
fi

}
########################################
##BEGIN MAIN SCRIPT##
#Pre checks: These are a couple of basic sanity checks the script does before proceeding.
##Java
print_status "${YELLOW}Removing any old Java sources, apt-get packages.${NC}"
rm /var/lib/dpkg/info/oracle-java7-installer*  &>> $logfile
rm /var/lib/dpkg/info/oracle-java8-installer*  &>> $logfile
apt-get purge oracle-java7-installer -y &>> $logfile
apt-get purge oracle-java8-installer -y &>> $logfile
rm /etc/apt/sources.list.d/*java*  &>> $logfile
dpkg -P oracle-java7-installer  &>> $logfile
dpkg -P oracle-java8-installer  &>> $logfile
apt-get -f install  &>> $logfile
add-apt-repository ppa:webupd8team/java -y &>> $logfile
error_check 'Java repo added'

apt-get update

##Java 
print_status "${YELLOW}Installing Java${NC}"
echo debconf shared/accepted-oracle-license-v1-1 select true | \
  sudo debconf-set-selections &>> $logfile
apt-get install oracle-java8-installer -y &>> $logfile
error_check 'Java Installed'

apt install build-essential libssl-dev libffi-dev python-dev python-pip wkhtmltopdf virtualbox unzip -y
git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git
cd Mobile*
pip install -r requirements.txt
vboxmanage hostonlyif create
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform*
firefox https://goo.gl/QxgHZa &


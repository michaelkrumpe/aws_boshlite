## Prefill these values, or be prompted for to enter in temporary memory during run
vBOSH_AWS_ACCESS_KEY_ID=''
vBOSH_AWS_SECRET_ACCESS_KEY=''
vBOSH_LITE_NAME=''
vBOSH_LITE_SECURITY_GROUP=''
vBOSH_LITE_KEYPAIR=''
vBOSH_LITE_PRIVATE_KEY=''
vBOSH_LITE_SUBNET_ID=''
vBOSH_LITE_INSTANCE_TYPE=''

if [ "$vBOSH_AWS_ACCESS_KEY_ID" == '']; then
    echo "AWS ACCESS KEY
    "
    read -p vAWS_ACCESS_KEY
    vBOSH_AWS_ACCESS_KEY_ID=$vAWS_ACCESS_KEY
fi

if [ "$vBOSH_AWS_SECRET_ACCESS_KEY" == '']; then
    echo "AWS SECRET KEY
    "
    read -p vAWS_SECRET_KEY
    vBOSH_AWS_SECRET_ACCESS_KEY=$vAWS_SECRET_KEY
fi

if [ "$vBOSH_LITE_NAME" == '']; then
    echo "Name of the BOSH machine to deploy
    "
    read -p vBOSHNAME
    vBOSH_LITE_NAME=$vBOSHNAME
fi

if [ "$vBOSH_LITE_SECURITY_GROUP" == '']; then
    echo "Name of the AWS Security group setup
    "
    read -p vSECURITYGROUP
    vBOSH_LITE_SECURITY_GROUP=$vSECURITYGROUP
fi

if [ "$vBOSH_LITE_KEYPAIR" == '']; then
    echo "Name of the AWS API Key Pair to be used by Vagrant
    "
    read -p vKEYPAIR
    vBOSH_LITE_KEYPAIR=$vKEYPAIR
fi

if [ "$vBOSH_LITE_PRIVATE_KEY" == '']; then
    echo "File path on this machine of the .pem file from your keys. Should be in ~/.ssh/ directory. If you have not uploaded, please do so now and type the full path including the ~
    "
    read -p vKEYLOC
    vBOSH_LITE_PRIVATE_KEY=$vKEYLOC
fi

if [ "$vBOSH_LITE_SUBNET_ID" == '']; then
    echo "AWS VPC Subnet ID
    "
    read -p vSUBNET
    vBOSH_LITE_SUBNET_ID=vSUBNET
fi

if [ "$vBOSH_LITE_INSTANCE_TYPE" == '']; then
    echo "AWS Instance type. Should be either m3.medium or m3.large
    "
    read -p vINSTANCE
    vBOSH_LITE_INSTANCE_TYPE=$vINSTANCE
fi

#echo "update"
apt-get update

echo "install prereqs"
sudo apt-get install build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlib1g-dev git awscli

aws configure #accesskey, secretkey, region=us-east1

sudo apt install linuxbrew-wrapper

# ...first add the Cloud Foundry Foundation public key and package repository to your system
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb http://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
# ...then, update your local package index, then finally install the cf CLI
sudo apt-get update
sudo apt-get install cf-cli

echo "get upstream vagrant latest"
wget https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.deb
dpkg -i vagrant_1.8.6_x86_64.deb
sudo apt-get install -f

echo "gem installs"
sudo gem install bosh_cli --no-ri --no-rdoc	##(sudo needed to install gems in /var/lib/gems) 

echo "get bosh-lite"
mkdir ~/workspace
cd ~/workspace
git clone https://github.com/cloudfoundry/bosh-lite
cd bosh-lite

vagrant box add cloudfoundry/bosh-lite

echo "rsa keys"
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -f "bosh_rsa" -q -N ""

echo "setup vagrant"
vagrant plugin install vagrant-aws
vagrant plugin list
vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box

export BOSH_AWS_ACCESS_KEY_ID=vBOSH_AWS_ACCESS_KEY_ID
export BOSH_AWS_SECRET_ACCESS_KEY=vBOSH_AWS_SECRET_ACCESS_KEY
export BOSH_LITE_NAME=vBOSH_LITE_NAME 
export BOSH_LITE_SECURITY_GROUP=vBOSH_LITE_SECURITY_GROUP
export BOSH_LITE_KEYPAIR=vBOSH_LITE_KEYPAIR
export BOSH_LITE_PRIVATE_KEY=vBOSH_LITE_PRIVATE_KEY
export BOSH_LITE_SUBNET_ID=vBOSH_LITE_SUBNET_ID
export BOSH_LITE_INSTANCE_TYPE=vBOSH_LITE_INSTANCE_TYPE

vagrant up
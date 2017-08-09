## Prefill these values, or be prompted for to enter in temporary memory during run
vBOSH_AWS_ACCESS_KEY_ID=
vBOSH_AWS_SECRET_ACCESS_KEY=
vBOSH_VPC_DOMAIN=
vBOSH_VPC_SUBDOMAIN=
vBOSH_AWS_REGION=us-east-1
vBOSH_VPC_PRIMARY_AZ=us-east-1a
vBOSH_VPC_SECONDARY_AZ=us-east-1d

read -p "Have you uploaded your stub manifest file to your user's root ~/ directory? y/n"


if [ "$vBOSH_AWS_ACCESS_KEY_ID" == ""]; then
    echo "AWS ACCESS KEY
    "
    read vAWS_ACCESS_KEY
    vBOSH_AWS_ACCESS_KEY_ID=$vAWS_ACCESS_KEY
fi

if [ "$vBOSH_AWS_SECRET_ACCESS_KEY" == ""]; then
    echo "AWS SECRET KEY
    "
    read vAWS_SECRET_KEY
    vBOSH_AWS_SECRET_ACCESS_KEY=$vAWS_SECRET_KEY
fi

if [ "$vBOSH_VPC_DOMAIN" == "" ]; then
    echo "VPC Domain, pointing to CF. If you do not have one use, IP.Address.numbers.xip.io
    "
    read vDomain
    vBOSH_VPC_DOMAIN=$vDomain
fi

if [ "$vBOSH_VPC_SUBDOMAIN" == "" ]; then
    echo "AWS SUBDOMAIN
    "
    read vSUBDOMAIN
    vBOSH_VPC_SUBDOMAIN=$vSUBDOMAIN
fi

if [ "$vBOSH_AWS_REGION" == "" ]; then
    echo "AWS Region to deploy CF (Should be the same as BOSH-LITE)
    "
    read vREGION
    vBOSH_AWS_REGION=vREGION
fi

if [ "$vBOSH_VPC_PRIMARY_AZ" == "" ]; then
    echo "VPC Primary Domain
    "
    read vPRIMARY
    vBOSH_VPC_PRIMARY_AZ=vPRIMARY
fi

if [ "$vBOSH_VPC_SECONDARY_AZ" == "" ]; then
    echo "VPC Secondary Domain
    "
    read vSECONDARY
    vBOSH_VPC_SECONDARY_AZ=vSECONDARY
fi

sudo apt-get update && sudo apt-get -y install git unzip
wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64.zip
sudo unzip spiff_linux_amd64.zip -d /usr/local/bin

bosh target 127.0.0.1

mkdir workspace
cd workspace

git clone https://github.com/cloudfoundry/cf-release.git
cd cf-release
sudo ./scripts/update

cd ~/workspace
sudo gem install bundler

# need manifest file uploaded to ~/

cd ~/workspace/cf-release

sudo  ./scripts/generate-bosh-lite-dev-manifest ~/cf-stub-aws_temp.yml

cd ~/workspace
bosh upload stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent

cd ~/workspace/cf-release
sudo bosh upload release releases/cf-246.yml

export BOSH_AWS_ACCESS_KEY_ID=vBOSH_AWS_ACCESS_KEY_ID
export BOSH_AWS_SECRET_ACCESS_KEY=vBOSH_AWS_SECRET_ACCESS_KEY
export BOSH_VPC_DOMAIN=vBOSH_VPC_DOMAIN
export BOSH_VPC_SUBDOMAIN=vBOSH_VPC_SUBDOMAIN
export BOSH_AWS_REGION=vBOSH_AWS_REGION
export BOSH_VPC_SECONDARY_AZ=vBOSH_VPC_SECONDARY_AZ
export BOSH_VPC_PRIMARY_AZ=vBOSH_VPC_PRIMARY_AZ

bosh deploy

echo "Set cf api with username admin and password admin, then do cf login
    "
cf api --skip-ssl-validation https://$vBOSH_VPC_DOMAIN

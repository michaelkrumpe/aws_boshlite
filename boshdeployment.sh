## Prefill these values, or be prompted for to enter in temporary memory during run
vBOSH_AWS_ACCESS_KEY_ID=
vBOSH_AWS_SECRET_ACCESS_KEY=
vBOSH_VPC_DOMAIN=
vBOSH_VPC_SUBDOMAIN=
vBOSH_AWS_REGION=us-east-1
vBOSH_VPC_PRIMARY_AZ=us-east-1a
vBOSH_VPC_SECONDARY_AZ=us-east-1d

while true
do
    read -p "Have you uploaded your stub manifest file to your user's root ~/ directory? Y/M" m_answer
    case $m_answer in
        [yY]* ) break;;

        [nN]* ) exit;;

        * );;
    esac
done

while true
do

    if [ z- "$vBOSH_AWS_ACCESS_KEY_ID"]; then
        read -p "AWS ACCESS KEY:" vAWS_ACCESS_KEY
        vBOSH_AWS_ACCESS_KEY_ID=$vAWS_ACCESS_KEY
    else
        echo "AWS ACCESS KEY: $vBOSH_AWS_ACCESS_KEY_ID"
    fi

    if [ z- "$vBOSH_AWS_SECRET_ACCESS_KEY"]; then
        read -p "AWS SECRET KEY:" vAWS_SECRET_KEY
        vBOSH_AWS_SECRET_ACCESS_KEY=$vAWS_SECRET_KEY
    else
        echo "AWS SECRET KEY: $vBOSH_AWS_SECRET_ACCESS_KEY"
    fi

    if [ z- "$vBOSH_VPC_DOMAIN"]; then
        echo "VPC Domain, pointing to CF. If you do not have one use, IP.Address.numbers.xip.io"
        read -p "VPC Domain:" vDomain
        vBOSH_VPC_DOMAIN=$vDomain
    else
        echo "VPC Domain: $vBOSH_VPC_DOMAIN"
    fi

    if [ z- "$vBOSH_VPC_SUBDOMAIN"]; then
        read -p "AWS SUBDOMAIN" vSUBDOMAIN
        vBOSH_VPC_SUBDOMAIN=$vSUBDOMAIN
    else
        echo "AWS SUBDOMAIN: $vBOSH_VPC_SUBDOMAIN"
    fi

    if [ z- "$vBOSH_AWS_REGION"]; then
        read -p "AWS Region to deploy CF (Should be the same as BOSH-LITE)" vREGION
        vBOSH_AWS_REGION=vREGION
    else
        echo "AWS Region: $vBOSH_AWS_REGION"
    fi

    if [ z- "$vBOSH_VPC_PRIMARY_AZ"]; then
        read -p "VPC Primary Domain" vPRIMARY
        vBOSH_VPC_PRIMARY_AZ=vPRIMARY
    else
        echo "VPC Primary Domain: $vBOSH_VPC_PRIMARY_AZ"
    fi

    if [ z- "$vBOSH_VPC_SECONDARY_AZ"]; then
        read -p "VPC Secondary Domain" vSECONDARY
        vBOSH_VPC_SECONDARY_AZ=vSECONDARY
    else
        echo "VPC Secondary Domain: $vBOSH_VPC_SECONDARY_AZ"
    fi

    read -p "Confirm values? [Y]es or [N]o?" answer
    case $answer in
        [yY]* ) break;;

        [nN]* ) exit;;

        * )     echo "Please reconfirm values.";;

    esac
done

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

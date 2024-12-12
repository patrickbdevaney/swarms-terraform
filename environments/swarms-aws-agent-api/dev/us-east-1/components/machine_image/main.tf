
provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Ubuntu's account ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "swarms_server_test_instance" {
  count = var.test_server_count
  ami   = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  
  user_data = <<-EOF
#!/bin/bash
sudo apt update
sudo apt install -y git virtualenv
rm -rf ./src/swarms
if [ ! -d "/opt/swarms/" ];
  then
  git clone https://github.com/jmikedupont2/swarms "/opt/swarms/"
fi    
cd "/opt/swarms/" || exit 1 # "we need swarms"
export BRANCH=feature/ec2
git checkout --force  $BRANCH
bash -x /opt/swarms/api/install.sh
              EOF
  tags = {
    Name = "Swarms Server"
  }
}

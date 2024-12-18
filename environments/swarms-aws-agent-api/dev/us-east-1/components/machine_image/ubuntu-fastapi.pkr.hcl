packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu-swarms-{{timestamp}}"
  instance_type = "t2.medium"
  region        = "us-east-2"
  source_ami    = "ami-0325b9a2dfb474b2d" # Ubuntu 20.04 LTS
  ssh_username  = "ubuntu"
  
}

build {
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3 python3-pip git",
      "export HOME=/root",
      "sudo apt-get install -y ec2-instance-connect git virtualenv",
      "sudo git clone https://github.com/jmikedupont2/swarms '/opt/swarms/'",
      "cd /opt/swarms/; sudo git checkout --force feature/ec2",
      "sudo bash -x /opt/swarms/api/install.sh"
    ]
  }

  sources = ["source.amazon-ebs.ubuntu"]
}

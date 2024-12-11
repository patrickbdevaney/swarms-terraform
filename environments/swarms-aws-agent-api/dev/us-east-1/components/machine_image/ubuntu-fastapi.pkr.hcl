packer {
  required_plugins {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu-fastapi-{{timestamp}}"
  instance_type = "t2.micro" 
  region        = "us-east-1" 
  source_ami    = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS
  ssh_username  = "ubuntu"
  
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3 python3-pip git",
      "pip3 install fastapi uvicorn", 
      "git clone https://github.com/yourusername/your-fastapi-module.git /app"
    ]
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]
}

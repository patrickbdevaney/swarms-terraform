provider "aws" {
  region = "us-east-1"
}

locals {
  ami = "ami-0e2c8caa4b6378d8c"
  name   = "swarms"
  region = "us-east-1"
  ec2_subnet_id = "subnet-057c90cfe7b2e5646"
  vpc_id = "vpc-04f28c9347af48b55"
  iam_instance_profile_name = "swarms-20241213150629570500000003"
  tags = {
    project="swarms"
  }
}

resource "aws_launch_template" "ec2_launch_template" {
  name_prefix           = "${local.name}-launch-template-"
  image_id              = local.ami
  instance_type        = "t3.large"
  #associate_public_ip_address = true
  
  iam_instance_profile {
    name = local.iam_instance_profile_name #aws_iam_instance_profile.ec2_instance_profile.name
  }

#  key_name = "your-key-pair" # Replace with your key pair name

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
      encrypted   = true
    }
  }

  # GPT:TASK base64gz this  user data
  #│ Error: creating EC2 Launch Template (swarms-launch-template-20241213192904511200000001): operation error EC2: CreateLaunchTemplate, https response error StatusCode: 400, RequestID: 6533fb57-90af-4a5a-9e63-3f995bc64672, api error InvalidUserData.Malformed: Invalid BASE64 encoding of user data.
  user_data = base64encode(<<-EOF
  #!/bin/bash
  export HOME=/root
  apt update
  apt-get install -y ec2-instance-connect git virtualenv

  if [ ! -d "/opt/swarms/" ]; then
    git clone https://github.com/jmikedupont2/swarms "/opt/swarms/"
  fi
  cd "/opt/swarms/" || exit 1
  export BRANCH=feature/ec2
  git checkout --force $BRANCH
  bash -x /opt/swarms/api/install.sh
  EOF
    )
  tags = local.tags  
}


output "lt" {
  value = resource.aws_launch_template.ec2_launch_template
}

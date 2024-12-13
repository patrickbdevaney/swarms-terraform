
resource "aws_launch_template" "ec2_launch_template" {
  name_prefix           = "${local.name}-launch-template-"
  image_id              = local.ami
  instance_type        = "t3.large"
  associate_public_ip_address = true
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  key_name = "your-key-pair" # Replace with your key pair name

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

  user_data = <<-EOF
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

  tags = local.tags  
}

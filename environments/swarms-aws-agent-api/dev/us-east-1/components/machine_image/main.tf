
# outputs
# default_network_acl_id = "acl-032756394b24c5d7a"
# default_route_table_id = "rtb-014dd7a2bcfc284ec"
# default_security_group_id = "sg-0273ddcb04d73df49"
# nat_ids = []
# nat_public_ips = tolist([])
# natgw_ids = []
# private_ipv6_egress_route_ids = []
# private_nat_gateway_route_ids = []
# private_route_table_association_ids = []
# private_route_table_ids = []
# private_subnet_arns = []
# private_subnets = []
# private_subnets_cidr_blocks = tolist([])
# private_subnets_ipv6_cidr_blocks = tolist([])
# public_route_table_association_ids = []
# public_route_table_ids = []
# public_subnet_arns = []
# public_subnets = []
# public_subnets_cidr_blocks = tolist([])
# public_subnets_ipv6_cidr_blocks = tolist([])
# this_customer_gateway = {}
# vpc_arn = "arn:aws:ec2:us-east-1:767503528736:vpc/vpc-04f28c9347af48b55"
# vpc_cidr_block = "10.0.0.0/16"
# vpc_enable_dns_hostnames = true
# vpc_enable_dns_support = true
# vpc_flow_log_cloudwatch_iam_role_arn = ""
# vpc_flow_log_destination_arn = ""
# vpc_flow_log_destination_type = "cloud-watch-logs"

# vpc_instance_tenancy = "default"
# vpc_ipv6_association_id = ""
# vpc_ipv6_cidr_block = ""
# vpc_main_route_table_id = "rtb-014dd7a2bcfc284ec"
# vpc_owner_id = "767503528736"
# vpc_secondary_cidr_blocks = tolist([])

provider "aws" {
  region = "us-east-1"
}

locals {
  ami = "ami-0e2c8caa4b6378d8c"
  name   = "swarms"
  region = "us-east-1"
  ec2_subnet_id = "subnet-057c90cfe7b2e5646"
  vpc_id = "vpc-04f28c9347af48b55"
  tags = {
    project="swarms"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Ubuntu's account ID
  filter {
    name   = "name"
    values = [
      #"ubuntu/images/hvm-ssd/ubuntu*24*amd64-server*"
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*",
    ]

# from https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#AMICatalog:https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#AMICatalog:    
# ubuntu (2 filtered, 8 unfiltered)
# Free tier eligible
# Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
# ami-0e2c8caa4b6378d8c (64-bit (x86)) / ami-0932ffb346ea84d48 (64-bit (Arm))
# Platform: ubuntu
# Root device type: ebs
# Virtualization: hvm
# ENA enabled: Yes
# Select
# 64-bit (x86)
# 64-bit (Arm)
# Ubuntu


# ami-005fc0f236362e99f (64-bit (x86)) / ami-07ee04759daf109de (64-bit (Arm))
# Ubuntu Server 22.04 LTS (HVM),EBS General Purpose (SSD) Volume Type. 
# Platform: ubuntu
# Root device type: ebs
# Virtualization: hvm
# ENA enabled: Yes
# Select
# 64-bit (x86)
#   64-bit (Arm)
  
    #"ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-20240823",
    #"ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-minimal-20240824",
    #"ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-20240813",
  }
}

module "security_group_instance" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  name        = "${local.name}-ec2"
  description = "Security Group for EC2 Instance"
  vpc_id = local.vpc_id
  #ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
     {
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       cidr_blocks = "0.0.0.0/0"
     },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  #egress_rules = ["https-443-tcp"]
  egress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.tags
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  associate_public_ip_address = true # for now
  name =  local.name
  ami   = local.ami # data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  vpc_security_group_ids = [module.security_group_instance.security_group_id]

  root_block_device = [
    {

      # best practice is encrypted at rest
      encrypted   = true
      volume_size = 30
      volume_type           = "gp3"
    }
  ]

  user_data = <<-EOF
#!/bin/bash
export HOME=/root
apt update
apt-get install -y ec2-instance-connect git virtualenv

if [ ! -d "/opt/swarms/" ];
  then
  git clone https://github.com/jmikedupont2/swarms "/opt/swarms/"
fi    
cd "/opt/swarms/" || exit 1 # "we need swarms"
export BRANCH=feature/ec2
git checkout --force  $BRANCH
bash -x /opt/swarms/api/install.sh
              EOF
  tags = local.tags  
  create_spot_instance = true
  subnet_id     = local.ec2_subnet_id
  #instance_market_options {    market_type = "spot"    spot_options {      #max_price = 0.0031
  #}
#}
}


# module "vpc_endpoints" {
#   source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#   version = "~> 5.0"

#   vpc_id = module.vpc.vpc_id

#   endpoints = { for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
#     replace(service, ".", "_") =>
#     {
#       service             = service
#       subnet_ids          = module.vpc.intra_subnets
#       private_dns_enabled = true
#       tags                = { Name = "${local.name}-${service}" }
#     }
#   }

#   create_security_group      = true
#   security_group_name_prefix = "${local.name}-vpc-endpoints-"
#   security_group_description = "VPC endpoint security group"
#   security_group_rules = {
#     ingress_https = {
#       description = "HTTPS from subnets"
#       cidr_blocks = #module.vpc.intra_subnets_cidr_blocks
#     }
#   }

#   tags = local.tags
# }

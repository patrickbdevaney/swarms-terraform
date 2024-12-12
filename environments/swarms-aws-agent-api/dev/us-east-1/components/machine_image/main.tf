
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
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
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
  #     cidr_blocks = "10.10.0.0/16"
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
  ami   = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  vpc_security_group_ids = [module.security_group_instance.security_group_id]

  user_data = <<-EOF
#!/bin/bash
apt update
apt-get install ec2-instance-connect
apt install -y git virtualenv

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

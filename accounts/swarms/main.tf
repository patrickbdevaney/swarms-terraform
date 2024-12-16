locals {
 dns = "api.swarms.ai"

}
provider aws {
  region = "us-east-2"
}
output dns {
  value = local.dns
}

output profile {
  value = "swarms"
}

output account {
  value = "916723593639"
}

output region {
  value = "us-east-2"
}

module "swarms_api" {
  source = "../../environments/swarms-aws-agent-api/dev/us-east-1"
  domain = local.dns
}


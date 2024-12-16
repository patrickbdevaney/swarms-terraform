output dns {
  value = "api.swarms.ai"
}

output profile {
  value = "swarms"
}

output account {
  value = "916723593639"
}

module "swarms_api" {
  source = "../../environments/swarms-aws-agent-api/dev/us-east-1"
}

#   variable "provider_alias" {
#     type = any
#   }

variable  name    {} #   = local.name
variable  domain_name    {} #   = local.name
variable  vpc_id  {}  #= module.vpc.vpc_id
#variable  subnets {} #= module.vpc.public_subnets
variable  public_subnets {} #= module.vpc.public_subnets

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-alb"
  }
}

##################################################################
# Application Load Balancer
##################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.12.0"
  name    = var.name # local.name
  vpc_id  = var.vpc_id # module.vpc.vpc_id
  subnets = var.public_subnets # module.vpc.public_subnets

  # For example only
  #enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80      
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/32" #module.vpc.vpc_cidr_block
    }
  }
  client_keep_alive = 7200
  target_groups = {
    # ex-swarms-instance = {
    #   name_prefix                       = "swarms"
    #   protocol                          = "HTTP"
    #   port                              = 80
    #   target_type                       = "instance"
    #   #deregistration_delay              = 10
    #   #load_balancing_algorithm_type     = "weighted_random"
    #   #load_balancing_anomaly_mitigation = "on"
    #   #load_balancing_cross_zone_enabled = false
    #   #protocol_version = "HTTP1"
    #   #target_id        = "aws_instance.this.id"
    #   #tags = {
    #   #  InstanceTargetGroupTag = "swarms"
    #   #}
    # }
  }
  # listeners = {
  #   ex-https = {
  #     #}
  #   }
  # }
  tags = local.tags
}

#  access_logs = {
#    bucket = module.log_bucket.s3_bucket_id
#    prefix = "access-logs"
#  }

#  connection_logs = {
#    bucket  = module.log_bucket.s3_bucket_id
#    enabled = true
#    prefix  = "connection-logs"
#  }

    # ex-http-https-redirect = {
    #   port     = 80
    #   protocol = "HTTP"
    #   redirect = {
    #     port        = "443"
    #     protocol    = "HTTPS"
    #     status_code = "HTTP_301"
    #   }
    # }
      #     rules = {
  #       ex-fixed-response = {
  #         priority = 3
  #         actions = [{
  #           type         = "fixed-response"
  #           content_type = "text/plain"
  #           status_code  = 200
  #           message_body = "This is a fixed response"
  #         }]
  #         conditions = [{
  #           http_header = {
  #             http_header_name = "x-Gimme-Fixed-Response"
  #             values           = ["yes", "please", "right now"]
  #           }
  #         }]
  #       }
  #       ex-weighted-forward = {
  #         priority = 4
  #         actions = [{
  #           type = "weighted-forward"
  #           target_groups = [
  #             {
  #               target_group_key = "ex-lambda-with-trigger"
  #               weight           = 2
  #             },
  #             {
  #               target_group_key = "ex-instance"
  #               weight           = 1
  #             }
  #           ]
  #           stickiness = {
  #             enabled  = true
  #             duration = 3600
  #           }
  #         }]
  #         conditions = [{
  #           query_string = {
  #             key   = "weighted"
  #             value = "true"
  #           }
  #         }]
  #       }
  #       ex-redirect = {
  #         priority = 5000
  #         actions = [{
  #           type        = "redirect"
  #           status_code = "HTTP_302"
  #           host        = "www.youtube.com"
  #           path        = "/watch"
  #           query       = "v=dQw4w9WgXcQ"
  #           protocol    = "HTTPS"
  #         }]
  #         conditions = [{
  #           query_string = [{
  #             key   = "video"
  #             value = "random"
  #             },
  #             {
  #               key   = "image"
  #               value = "next"
  #           }]
  #         }]
  #       }
  #     }
  #   }
  #   ex-http-weighted-target = {
  #     port     = 81
  #     protocol = "HTTP"
  #     weighted_forward = {
  #       target_groups = [
  #         {
  #           target_group_key = "ex-lambda-with-trigger"
  #           weight           = 60
  #         },
  #         {
  #           target_group_key = "ex-instance"
  #           weight           = 40
  #         }
  #       ]
  #     }
  #   }
  #   ex-fixed-response = {
  #     port     = 82
  #     protocol = "HTTP"
  #     fixed_response = {
  #       content_type = "text/plain"
  #       message_body = "Fixed message"
  #       status_code  = "200"
  #     }
  #   }
  #     rules = {
  #       ex-cognito = {
  #         actions = [
  #           {
  #             type                       = "authenticate-cognito"
  #             on_unauthenticated_request = "authenticate"
  #             session_cookie_name        = "session-${local.name}"
  #             session_timeout            = 3600
  #             user_pool_arn              = aws_cognito_user_pool.this.arn
  #             user_pool_client_id        = aws_cognito_user_pool_client.this.id
  #             user_pool_domain           = aws_cognito_user_pool_domain.this.domain
  #           },
  #           {
  #             type             = "forward"
  #             target_group_key = "ex-instance"
  #           }
  #         ]
  #         conditions = [{
  #           path_pattern = {
  #             values = ["/some/auth/required/route"]
  #           }
  #         }]
  #       }
  #       ex-fixed-response = {
  #         priority = 3
  #         actions = [{
  #           type         = "fixed-response"
  #           content_type = "text/plain"
  #           status_code  = 200
  #           message_body = "This is a fixed response"
  #         }]
  #         conditions = [{
  #           http_header = {
  #             http_header_name = "x-Gimme-Fixed-Response"
  #             values           = ["yes", "please", "right now"]
  #           }
  #         }]
  #       }
  #       ex-weighted-forward = {
  #         priority = 4
  #         actions = [{
  #           type = "weighted-forward"
  #           target_groups = [
  #             {
  #               target_group_key = "ex-instance"
  #               weight           = 2
  #             },
  #             {
  #               target_group_key = "ex-lambda-with-trigger"
  #               weight           = 1
  #             }
  #           ]
  #           stickiness = {
  #             enabled  = true
  #             duration = 3600
  #           }
  #         }]
  #         conditions = [{
  #           query_string = {
  #             key   = "weighted"
  #             value = "true"
  #           },
  #           path_pattern = {
  #             values = ["/some/path"]
  #           }
  #         }]
  #       }
  #       ex-redirect = {
  #         priority = 5000
  #         actions = [{
  #           type        = "redirect"
  #           status_code = "HTTP_302"
  #           host        = "www.youtube.com"
  #           path        = "/watch"
  #           query       = "v=dQw4w9WgXcQ"
  #           protocol    = "HTTPS"
  #         }]
  #         conditions = [{
  #           query_string = {
  #             key   = "video"
  #             value = "random"
  #           }
  #         }]
  #       }
  #     }
  #   ex-cognito = {
  #     port            = 444
  #     protocol        = "HTTPS"
  #     certificate_arn = module.acm.acm_certificate_arn
  #     authenticate_cognito = {
  #       authentication_request_extra_params = {
  #         display = "page"
  #         prompt  = "login"
  #       }
  #       on_unauthenticated_request = "authenticate"
  #       session_cookie_name        = "session-${local.name}"
  #       session_timeout            = 3600
  #       user_pool_arn              = aws_cognito_user_pool.this.arn
  #       user_pool_client_id        = aws_cognito_user_pool_client.this.id
  #       user_pool_domain           = aws_cognito_user_pool_domain.this.domain
  #     }
  #     forward = {
  #       target_group_key = "ex-instance"
  #     }
  #     rules = {
  #       ex-oidc = {
  #         priority = 2
  #         actions = [
  #           {
  #             type = "authenticate-oidc"
  #             authentication_request_extra_params = {
  #               display = "page"
  #               prompt  = "login"
  #             }
  #             authorization_endpoint = "https://${var.domain_name}/auth"
  #             client_id              = "client_id"
  #             client_secret          = "client_secret"
  #             issuer                 = "https://${var.domain_name}"
  #             token_endpoint         = "https://${var.domain_name}/token"
  #             user_info_endpoint     = "https://${var.domain_name}/user_info"
  #           },
  #           {
  #             type             = "forward"
  #             target_group_key = "ex-lambda-with-trigger"
  #           }
  #         ]
  #         conditions = [{
  #           host_header = {
  #             values = ["foobar.com"]
  #           }
  #         }]
  #       }
  #     }
  #   }
  #   ex-oidc = {
  #     port            = 445
  #     protocol        = "HTTPS"
  #     certificate_arn = module.acm.acm_certificate_arn
  #     action_type     = "authenticate-oidc"
  #     authenticate_oidc = {
  #       authentication_request_extra_params = {
  #         display = "page"
  #         prompt  = "login"
  #       }
  #       authorization_endpoint = "https://${var.domain_name}/auth"
  #       client_id              = "client_id"
  #       client_secret          = "client_secret"
  #       issuer                 = "https://${var.domain_name}"
  #       token_endpoint         = "https://${var.domain_name}/token"
  #       user_info_endpoint     = "https://${var.domain_name}/user_info"
  #     }
  #     forward = {
  #       target_group_key = "ex-instance"
  #     }
  #   }
  # }
  #     target_group_health = {
  #       dns_failover = {
  #         minimum_healthy_targets_count = 2
  #       }
  #       unhealthy_state_routing = {
  #         minimum_healthy_targets_percentage = 50
  #       }
  #     }
  #     health_check = {
  #       enabled             = true
  #       interval            = 30
  #       path                = "/healthz"
  #       port                = "traffic-port"
  #       healthy_threshold   = 3
  #       unhealthy_threshold = 3
  #       timeout             = 6
  #       protocol            = "HTTP"
  #       matcher             = "200-399"
  #     }	 
  #   ex-lambda-with-trigger = {
  #     name_prefix                        = "l1-"
  #     target_type                        = "lambda"
  #     lambda_multi_value_headers_enabled = true
  #     target_id                          = module.lambda_with_allowed_triggers.lambda_function_arn
  #   }
  #   ex-lambda-without-trigger = {
  #     name_prefix              = "l2-"
  #     target_type              = "lambda"
  #     target_id                = module.lambda_without_allowed_triggers.lambda_function_arn
  #     attach_lambda_permission = true
  #   }
  # }
  # additional_target_group_attachments = {
  #   ex-instance-other = {
  #     target_group_key = "ex-instance"
  #     target_type      = "instance"
  #     target_id        = aws_instance.other.id
  #     port             = "80"
  #   }
  # }
  # # Route53 Record(s)
  # route53_records = {
  #   A = {
  #     name    = local.name
  #     type    = "A"
  #     zone_id = data.aws_route53_zone.this.id
  #   }
  #   AAAA = {
  #     name    = local.name
  #     type    = "AAAA"
  #     zone_id = data.aws_route53_zone.this.id
  #   }
  # }


#module "alb_disabled" {
#  source = "../../"#
#
#  create = false
#}

# ################################################################################
# # Using packaged function from Lambda module
# ################################################################################

# locals {
#   package_url = "https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-lambda/master/examples/fixtures/python3.8-zip/existing_package.zip"
#   downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
# }

# resource "null_resource" "download_package" {
#   triggers = {
#     downloaded = local.downloaded
#   }

#   provisioner "local-exec" {
#     command = "curl -L -o ${local.downloaded} ${local.package_url}"
#   }
# }

# module "lambda_with_allowed_triggers" {
#   source  = "terraform-aws-modules/lambda/aws"
#   version = "~> 6.0"

#   function_name = "${local.name}-with-allowed-triggers"
#   description   = "My awesome lambda function (with allowed triggers)"
#   handler       = "index.lambda_handler"
#   runtime       = "python3.8"

#   publish                = true
#   create_package         = false
#   local_existing_package = local.downloaded

#   allowed_triggers = {
#     AllowExecutionFromELB = {
#       service    = "elasticloadbalancing"
#       source_arn = module.alb.target_groups["ex-lambda-with-trigger"].arn
#     }
#   }

#   depends_on = [null_resource.download_package]
# }

# module "lambda_without_allowed_triggers" {
#   source  = "terraform-aws-modules/lambda/aws"
#   version = "~> 6.0"

#   function_name = "${local.name}-without-allowed-triggers"
#   description   = "My awesome lambda function (without allowed triggers)"
#   handler       = "index.lambda_handler"
#   runtime       = "python3.8"

#   publish                = true
#   create_package         = false
#   local_existing_package = local.downloaded

#   # Allowed triggers will be managed by ALB module
#   allowed_triggers = {}

#   depends_on = [null_resource.download_package]
# }

# ################################################################################
# # Supporting resources
# ################################################################################

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 5.0"

#   name = local.name
#   cidr = local.vpc_cidr

#   azs             = local.azs
#   private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
#   public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

#   tags = local.tags
# }

# module "wildcard_cert" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 4.0"

#   domain_name = "*.${var.domain_name}"
#   zone_id     = data.aws_route53_zone.this.id
# }

# data "aws_ssm_parameter" "al2" {
#   name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
# }

# resource "aws_instance" "this" {
#   ami           = data.aws_ssm_parameter.al2.value
#   instance_type = "t3.nano"
#   subnet_id     = element(module.vpc.private_subnets, 0)
# }

# resource "aws_instance" "other" {
#   ami           = data.aws_ssm_parameter.al2.value
#   instance_type = "t3.nano"
#   subnet_id     = element(module.vpc.private_subnets, 0)
# }

# ##################################################################
# # AWS Cognito User Pool
# ##################################################################

# resource "aws_cognito_user_pool" "this" {
#   name = "user-pool-${local.name}"
# }

# resource "aws_cognito_user_pool_client" "this" {
#   name                                 = "user-pool-client-${local.name}"
#   user_pool_id                         = aws_cognito_user_pool.this.id
#   generate_secret                      = true
#   allowed_oauth_flows                  = ["code", "implicit"]
#   callback_urls                        = ["https://${var.domain_name}/callback"]
#   allowed_oauth_scopes                 = ["email", "openid"]
#   allowed_oauth_flows_user_pool_client = true
# }

# resource "random_string" "this" {
#   length  = 5
#   upper   = false
#   special = false
# }

# resource "aws_cognito_user_pool_domain" "this" {
#   domain       = "${local.name}-${random_string.this.result}"
#   user_pool_id = aws_cognito_user_pool.this.id
# }

#module#  "log_bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "~> 3.0"

#   bucket_prefix = "${local.name}-logs-"
#   acl           = "log-delivery-write"

#   # For example only
#   force_destroy = true

#   control_object_ownership = true
#   object_ownership         = "ObjectWriter"

#   attach_elb_log_delivery_policy = true # Required for ALB logs
#   attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

#   attach_deny_insecure_transport_policy = true
#   attach_require_latest_tls_policy      = true
#   tags = local.tags
#}


resource "aws_route53_zone" "primary" {
   name = var.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  domain_name = var.domain_name
  zone_id     = aws_route53_zone.primary.zone_id
}

## now we just lift the listener code
resource "aws_lb_listener" "this" {
  port                        = 443
  protocol                    = "HTTPS"
  ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn             = module.acm.acm_certificate_arn
  load_balancer_arn = module.alb.arn
  #additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]
  #     #forward = {
  #       #target_group_key = "ex-swarms-instance"
  # 	target_group_arn = "ex-swarms-instance"
  # 	#target_group = []

  default_action {
    target_group_arn =aws_lb_target_group.this.arn
    #module.alb.target_groups["ex-lambda-with-trigger"].arn
    #length(try(default_action.value.target_groups, [])) > 0 ? null : try(default_action.value.arn, aws_lb_target_group.this[default_action.value.target_group_key].arn, null)
    type             = "forward"
  }

  # dynamic "default_action" {
  #   for_each = try([each.value.weighted_forward], [])
  #   content {
  #     forward {
  #       dynamic "target_group" {
  #         for_each = try(default_action.value.target_groups, [])
  #         content {
  #           arn    = try(target_group.value.arn, aws_lb_target_group.this[target_group.value.target_group_key].arn, null)
  #           weight = try(target_group.value.weight, null)
  #         }
  #       }
  #       dynamic "stickiness" {
  #         for_each = try([default_action.value.stickiness], [])
  #         content {
  #           duration = try(stickiness.value.duration, 60)
  #           enabled  = try(stickiness.value.enabled, null)
  #         }
  #       }
  #     }
  #     order = try(default_action.value.order, null)
  #     type  = "forward"
  #   }
  # }
  # dynamic "default_action" {
  #   for_each = try([each.value.redirect], [])
  #   content {
  #     order = try(default_action.value.order, null)
  #     redirect {
  #       host        = try(default_action.value.host, null)
  #       path        = try(default_action.value.path, null)
  #       port        = try(default_action.value.port, null)
  #       protocol    = try(default_action.value.protocol, null)
  #       query       = try(default_action.value.query, null)
  #       status_code = default_action.value.status_code
  #     }
  #     type = "redirect"
  #   }
  # } 
#  load_balancer_arn        = aws_lb.this[0].arn
#  port                     = try(each.value.port, var.default_port)
#  protocol                 = try(each.value.protocol, var.default_protocol)
#  ssl_policy               = contains(["HTTPS", "TLS"], try(each.value.protocol, var.default_protocol)) ? try(each.value.ssl_policy, "ELBSecurityPolicy-TLS13-1-2-Res-2021-06") : try(each.value.ssl_policy, null)
#  tcp_idle_timeout_seconds = try(each.value.tcp_idle_timeout_seconds, null)
#  tags                     = merge(local.tags, try(each.value.tags, {}))
}



resource "aws_lb_target_group" "this" {
  name_prefix                       = "swarms"
  protocol                          = "HTTP"
  port                              = 80
  target_type                       = "instance"
  vpc_id = var.vpc_id
  deregistration_delay              = 10
  load_balancing_algorithm_type     = "weighted_random"
  load_balancing_anomaly_mitigation = "on"
  load_balancing_cross_zone_enabled = false
  protocol_version = "HTTP1"
  #   #target_id        = "aws_instance.this.id"
  #   #tags = {
  #   #  InstanceTargetGroupTag = "swarms"
  #   #}
  # }
  
#  for_each = { for k, v in var.target_groups : k => v if local.create }
#  connection_termination = try(each.value.connection_termination, null)
#  deregistration_delay   = try(each.value.deregistration_delay, null)

  # dynamic "health_check" {
  #   for_each = try([each.value.health_check], [])

  #   content {
  #     enabled             = try(health_check.value.enabled, null)
  #     healthy_threshold   = try(health_check.value.healthy_threshold, null)
  #     interval            = try(health_check.value.interval, null)
  #     matcher             = try(health_check.value.matcher, null)
  #     path                = try(health_check.value.path, null)
  #     port                = try(health_check.value.port, null)
  #     protocol            = try(health_check.value.protocol, null)
  #     timeout             = try(health_check.value.timeout, null)
  #     unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
  #   }
  # }

  # ip_address_type                    = try(each.value.ip_address_type, null)
  # lambda_multi_value_headers_enabled = try(each.value.lambda_multi_value_headers_enabled, null)
  # load_balancing_algorithm_type      = try(each.value.load_balancing_algorithm_type, null)
  # load_balancing_anomaly_mitigation  = try(each.value.load_balancing_anomaly_mitigation, null)
  # load_balancing_cross_zone_enabled  = try(each.value.load_balancing_cross_zone_enabled, null)
  # name                               = try(each.value.name, null)
  # name_prefix                        = try(each.value.name_prefix, null)
  # port                               = try(each.value.target_type, null) == "lambda" ? null : try(each.value.port, var.default_port)
  # preserve_client_ip                 = try(each.value.preserve_client_ip, null)
  # protocol                           = try(each.value.target_type, null) == "lambda" ? null : try(each.value.protocol, var.default_protocol)
  # protocol_version                   = try(each.value.protocol_version, null)
  # proxy_protocol_v2                  = try(each.value.proxy_protocol_v2, null)
  # slow_start                         = try(each.value.slow_start, null)

  # dynamic "stickiness" {
  #   for_each = try([each.value.stickiness], [])

  #   content {
  #     cookie_duration = try(stickiness.value.cookie_duration, null)
  #     cookie_name     = try(stickiness.value.cookie_name, null)
  #     enabled         = try(stickiness.value.enabled, true)
  #     type            = var.load_balancer_type == "network" ? "source_ip" : stickiness.value.type
  #   }
  # }

  # dynamic "target_failover" {
  #   for_each = try(each.value.target_failover, [])

  #   content {
  #     on_deregistration = target_failover.value.on_deregistration
  #     on_unhealthy      = target_failover.value.on_unhealthy
  #   }
  # }

  # dynamic "target_group_health" {
  #   for_each = try([each.value.target_group_health], [])

  #   content {

  #     dynamic "dns_failover" {
  #       for_each = try([target_group_health.value.dns_failover], [])

  #       content {
  #         minimum_healthy_targets_count      = try(dns_failover.value.minimum_healthy_targets_count, null)
  #         minimum_healthy_targets_percentage = try(dns_failover.value.minimum_healthy_targets_percentage, null)
  #       }
  #     }

  #     dynamic "unhealthy_state_routing" {
  #       for_each = try([target_group_health.value.unhealthy_state_routing], [])

  #       content {
  #         minimum_healthy_targets_count      = try(unhealthy_state_routing.value.minimum_healthy_targets_count, null)
  #         minimum_healthy_targets_percentage = try(unhealthy_state_routing.value.minimum_healthy_targets_percentage, null)
  #       }
  #     }
  #   }
  # }

  # dynamic "target_health_state" {
  #   for_each = try([each.value.target_health_state], [])
  #   content {
  #     enable_unhealthy_connection_termination = try(target_health_state.value.enable_unhealthy_connection_termination, true)
  #     unhealthy_draining_interval             = try(target_health_state.value.unhealthy_draining_interval, null)
  #   }
  # }

  # target_type = try(each.value.target_type, null)
  # vpc_id      = try(each.value.vpc_id, var.vpc_id)

  # tags = merge(local.tags, try(each.value.tags, {}))

  # lifecycle {
  #   create_before_destroy = true
  # }
}





output zone_id {
  value = aws_route53_zone.primary.zone_id
}

output zone {
  value = aws_route53_zone.primary
}
output alb_target_group_arn {
  value = aws_lb_target_group.this.arn
}



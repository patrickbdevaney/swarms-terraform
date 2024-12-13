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
  launch_template_id = "lt-042e08d77d0fe4376"
}


# lt = {
#   "arn" = "arn:aws:ec2:us-east-1:767503528736:launch-template/lt-042e08d77d0fe4376"
#   "block_device_mappings" = tolist([
#     {
#       "device_name" = "/dev/xvda"
#       "ebs" = tolist([
#         {
#           "delete_on_termination" = ""
#           "encrypted" = "true"
#           "iops" = 0
#           "kms_key_id" = ""
#           "snapshot_id" = ""
#           "throughput" = 0
#           "volume_size" = 30
#           "volume_type" = "gp3"
#         },
#       ])
#       "no_device" = ""
#       "virtual_name" = ""
#     },
#   ])
#   "capacity_reservation_specification" = tolist([])
#   "cpu_options" = tolist([])
#   "credit_specification" = tolist([])
#   "default_version" = 1
#   "description" = ""
#   "disable_api_stop" = false
#   "disable_api_termination" = false
#   "ebs_optimized" = ""
#   "elastic_gpu_specifications" = tolist([])
#   "elastic_inference_accelerator" = tolist([])
#   "enclave_options" = tolist([])
#   "hibernation_options" = tolist([])
#   "iam_instance_profile" = tolist([
#     {
#       "arn" = ""
#       "name" = "swarms-20241213150629570500000003"
#     },
#   ])

#   "image_id" = "ami-0e2c8caa4b6378d8c"
#   "instance_initiated_shutdown_behavior" = ""
#   "instance_market_options" = tolist([])
#   "instance_requirements" = tolist([])
#   "instance_type" = "t3.large"
#   "kernel_id" = ""
#   "key_name" = ""
#   "latest_version" = 1
#   "license_specification" = toset([])
#   "maintenance_options" = tolist([])
#   "metadata_options" = tolist([])
#   "monitoring" = tolist([])
#   "name" = "swarms-launch-template-20241213193104143500000001"
#   "name_prefix" = "swarms-launch-template-"
#   "network_interfaces" = tolist([])
#   "placement" = tolist([])
#   "private_dns_name_options" = tolist([])
#   "ram_disk_id" = ""
#   "security_group_names" = toset([])
#   "tag_specifications" = tolist([])
#   "tags" = tomap({
#     "project" = "swarms"
#   })
#   "tags_all" = tomap({
#     "project" = "swarms"
#   })
#   "update_default_version" = tobool(null)
#   "user_data" = "IyEvYmluL2Jhc2gKZXhwb3J0IEhPTUU9L3Jvb3QKYXB0IHVwZGF0ZQphcHQtZ2V0IGluc3RhbGwgLXkgZWMyLWluc3RhbmNlLWNvbm5lY3QgZ2l0IHZpcnR1YWxlbnYKCmlmIFsgISAtZCAiL29wdC9zd2FybXMvIiBdOyB0aGVuCiAgZ2l0IGNsb25lIGh0dHBzOi8vZ2l0aHViLmNvbS9qbWlrZWR1cG9udDIvc3dhcm1zICIvb3B0L3N3YXJtcy8iCmZpCmNkICIvb3B0L3N3YXJtcy8iIHx8IGV4aXQgMQpleHBvcnQgQlJBTkNIPWZlYXR1cmUvZWMyCmdpdCBjaGVja291dCAtLWZvcmNlICRCUkFOQ0gKYmFzaCAteCAvb3B0L3N3YXJtcy9hcGkvaW5zdGFsbC5zaAo="
#   "vpc_security_group_ids" = toset([])
# }

resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  desired_capacity     = 1
  max_size             = 5
  min_size             = 1

  launch_template {
    id      = local.launch_template_id #<aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [local.ec2_subnet_id]


}

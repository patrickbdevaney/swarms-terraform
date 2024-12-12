# Plan
## Phase 1

1. create minimal ec2 instance in machine_image

terraform  (later packer) for ubuntu python uvicorn fastapi nginx systemd server with custom git modules

2. create minimal ec2 ami from instance in machine_image
3. create autoscaling_group of size 1 for image
4. create application load balancer

send users back to server via sticky sessions or some id.

5. create dns_entry
6. create cognito user pool for login
7. create work_queue
8. create lambda_workers on queue
9. create resource_launchers to create new resources.

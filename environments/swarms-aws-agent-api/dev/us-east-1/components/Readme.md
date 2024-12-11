# Plan
## Phase 1
1. create minimal ec2 instance in machine_image
2. create minimal ec2 ami from instance in machine_image
3. create autoscaling_group of size 1 for image
4. create application_load_balancer  
5. create dns_entry             
6. create cognito_user_pool   for login
7. create work_queue
8. create lambda_workers on queue 
9. create resource_launchers to create new resources.


# Three Tiered architecture utilizing Elastic Container Service
This project covers the core concepts of platform engineering by adopting multiple principles to create a highly available and resilient three tier architecture that runs a custom containered NextJS application in an Elastic Container cluster running on EC2 instances.

# Project Visual Diagram and walkthrough

![Three-tier-architecture drawio](https://github.com/user-attachments/assets/f1d20100-18dd-4411-9b6a-c3bdb0a4d807)


- The continuous deployment process was done through the use of Github actions workflows.
- The Infrastructure as code tool used to create the cloud resources for this application to be hosted was done with Terraform.
- The application is hosted in a VPC network with multiple subnets. The application runs as a container, which is hosted within a container cluster across multiple availabilty zones.
- The network is made up of multiple subnets with attached route tables to route to the internet gateway for public subnets.
- A security group is used to ensure secure access between subnets, while also making use of multiple iAM roles for secure access to other required services.
- An auto scaling group is used to ensure that the EC2 instance used to serve as the capacity provider for the Elastic Container Cluster is high available and resilient.
- The state file of the terraform configruation is stored in a remote S3 bucket.


## Major Components and Technologies used
- Deployment - Github Actions
- Infrastructure as Code - Terraform
- Cloud Services - AWS VPC, AWS EC2, AWS S3, AWS ECS, AWS IAM, AWS S3
- Containerisation - Docker
- Container Orchestration - Elastic Container Service


## Lessons Learned 
-  Authenticating into aws by using the OIDC and iam role method to gain access to aws services.
- Appropriate CIDR blocks for both private and public subnets.
- Spinning up an ECS cluster takes time through the use of terraform.
- Creating an IAM Role with least privilege permission to allow the GitHub action server to run the terraform commands in the workflow.
- Utilizing ECS and an auto sclaing group to make container available through the service load balancer.

### Future additions
- [ ]  Make better security groups
- [ ]  Put instances in private subnet and divert traffic to nat gateway following this approach: https://www.google.com/search?q=how+to+connect+ec2+instance+to+nat+gateway+in+terraform&rlz=1C5CHFA_enGB996GB997&oq=how+to+connect+ec2+instance+to+nat+gateway+in+terraform+&gs_lcrp=EgZjaHJvbWUyCQgAEEUYORifBTIHCAEQIRigATIHCAIQIRigATIHCAMQIRigATIHCAQQIRigAdIBCDg5MjRqMGoxqAIAsAIA&sourceid=chrome&ie=UTF-8 by adding a new route table and diverting the route to `0.0.0.0:0`  with the nat gateway as the `gateway_id`
- [ ]  Add blue/green deployment by following this: https://developer.hashicorp.com/terraform/tutorials/aws/blue-green-canary-tests-deployments
- [ ]  Add RDS instance in private subnet

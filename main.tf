# This block specifies the Terraform configuration. It declares the required provider, AWS, and its version.

terraform {
  required_providers {
    aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0.0"
    }
  }
}

# This block defines the AWS provider configuration. It specifies the AWS region as eu-central-1.

provider "aws" {
  region = "eu-central-1"
 }

# This block retrieves information about the most recent Ubuntu Amazon Machine Image (AMI) that matches the specified filters.
# It searches for an AMI with a specific name and virtualization type, owned by the specified AWS account ID.

 data "aws_ami" "ubuntu" {
   most_recent = true
 
   filter {
     name = "name"
     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
   }
 
   filter {
     name = "virtualization-type"
     values = ["hvm"]
   }
 
   owners = ["099720109477"]
 }

# This block retrieves information about the default Amazon Virtual Private Cloud (VPC) in the specified region.

 data "aws_vpc" "default" {
  default = true
 }

# This block creates an AWS security group named "security_az" with specific inbound and outbound rules.
# Inbound rules allow traffic on ports 80 (HTTP) and 22 (SSH) from any IP address.
# Outbound rules allow all traffic to any destination IP address.

 resource "aws_security_group" "security_az" {
   name = "security_az"
   vpc_id = data.aws_vpc.default.id
   description = "security group for high az server"
 
   ingress {
     from_port = 80
     to_port = 80
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   
   ingress {
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
 
   egress {
     from_port = 0
     to_port = 65535
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
 
   tags = {
     Name = "security_az"
   }
 }

# This block retrieves information about the previously created security group, "security_az," for later use.

data "aws_security_group" "security_az"{
  name = aws_security_group.security_az.name
  vpc_id= data.aws_vpc.default.id
}

# This block creates an AWS Launch Template, specifying the Ubuntu AMI, security group, instance type, key pair, and user data script.
# The lifecycle block ensures that the old template is created before the new one is destroyed during updates.

 resource "aws_launch_template" "launch_template" {
   image_id = data.aws_ami.ubuntu.id
   vpc_security_group_ids = [aws_security_group.security_az.id]
   instance_type = "t2.micro"
   key_name = "key_pair"
   user_data = filebase64("script.sh")
 
   lifecycle {
       create_before_destroy = true
   }
 }

# This block creates an AWS Auto Scaling Group (ASG) named "ag_terraform" in the specified availability zones.
# The ASG is configured to have a desired capacity of 1 instance, with a maximum of 2 instances and a minimum of 1 instance.
# It uses the previously defined Launch Template and is associated with an Elastic Load Balancer (ELB).
# The lifecycle block ensures that the old ASG is created before the new one is destroyed during updates.

 resource "aws_autoscaling_group" "asg" {
  name = "ag_terraform"
   availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
   desired_capacity = 2
   max_size = 3
   min_size = 1
   launch_template {
     id = aws_launch_template.launch_template.id
     version = "$Latest"
   }
   load_balancers = [aws_elb.ELB.id]
 
   lifecycle {
       create_before_destroy = true
   }
 }

# This block creates an AWS Elastic Load Balancer (ELB) named "ELB" in the specified availability zones.
# It associates the previously created security group, defines a listener for HTTP traffic, and configures health checks.
# Additional settings such as cross-zone load balancing, idle timeout, and connection draining are also specified.
# Tags are added to the ELB for identification.

 resource "aws_elb" "ELB" {
   name = "ELB"
   availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
   security_groups = [aws_security_group.security_az.id]
 
   listener {
     instance_port = 80
     instance_protocol = "http"
     lb_port = 80
     lb_protocol = "http"
   }
 
   health_check {
     healthy_threshold = 2
     unhealthy_threshold = 2
     timeout = 3
     target = "HTTP:80/"
     interval = 30
   }
   
   cross_zone_load_balancing = true
   idle_timeout = 400
   connection_draining = true
   connection_draining_timeout = 400
 
   tags = {
     Name = "ELB"
   }
 }

# Schedule for turning on and turning off instances launched by Auto Scaling Group

 resource "aws_autoscaling_schedule" "turn_on" {
  scheduled_action_name = "turn_on"
  min_size = 1
  max_size = 3
  desired_capacity = 2
  recurrence = "0 8 * * *"
  autoscaling_group_name = aws_autoscaling_group.asg.name
   
 }

 resource "aws_autoscaling_schedule" "turn_off" {
  scheduled_action_name = "turn_off"
  min_size = 0
  max_size = 1
  desired_capacity = 0
  recurrence = "0 20 * * *"
  autoscaling_group_name = aws_autoscaling_group.asg.name
   
 }

# This block defines an output variable that exposes the DNS name of the ELB created earlier.
# The value can be accessed after applying the Terraform configuration.

 output "elb_dns_name" {
 value = "Your DNS http://${aws_elb.ELB.dns_name}"
 }
 
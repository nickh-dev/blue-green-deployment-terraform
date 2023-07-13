# High availability zone server deployment with Terraform and AWS
The Terraform configuration provided in this repository enables the deployment of infrastructure on Amazon Web Services (AWS). With this code, you can easily create and manage a scalable and highly available environment consisting of an EC2 instance, an Auto Scaling Group (ASG), and an Elastic Load Balancer (ELB) on AWS.

The configuration script leverages Terraform, an open-source infrastructure as code (IaC) tool, to define and provision the necessary AWS resources. By following the instructions outlined in this documentation, you will be able to deploy a robust infrastructure that can handle varying levels of traffic and ensure high availability.

# Key Features:
1. AWS Provider Configuration: The script specifies the required AWS provider configuration, allowing you to set the desired AWS region for deploying your infrastructure.
2. Ubuntu Amazon Machine Image (AMI) Selection: The code retrieves information about the most recent Ubuntu AMI that meets specific criteria, ensuring that you have access to the latest version for your EC2 instance.
3. Security Group Configuration: A custom security group named "security_az" is created with predefined inbound and outbound rules. These rules allow incoming traffic on ports 80 (HTTP) and 22 (SSH) from any IP address while permitting all outbound traffic.
4. Launch Template Definition: The script creates an AWS Launch Template, which specifies the chosen Ubuntu AMI, security group, instance type, key pair, and user data script. This Launch Template serves as a blueprint for the creation of EC2 instances within the Auto Scaling Group.
5. Auto Scaling Group (ASG) Configuration: An Auto Scaling Group named "ag_terraform" is defined, ensuring the desired capacity of 1 EC2 instance with a maximum of 2 instances and a minimum of 1 instance. This ASG utilizes the previously defined Launch Template and is associated with the ELB for load balancing and high availability.
6. Elastic Load Balancer (ELB) Setup: The configuration includes the creation of an Elastic Load Balancer named "ELB" across multiple availability zones. It associates the custom security group and configures the necessary listener for HTTP traffic. Health checks are implemented to ensure the availability and proper functioning of the instances.

# Getting Started:
To deploy this infrastructure on AWS, follow the steps outlined below:
1. Ensure you have Terraform installed on your local machine. You can download and install the latest version from the official Terraform website (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
2. Clone this repository to your local environment or download the provided code.
3. Navigate to the project directory using the command line interface.
4. Customize the Terraform variables and configuration parameters in the code according to your requirements. Pay special attention to variables such as region, AMI filters, security group rules, instance type, and ELB settings.
5. Initialize the Terraform project by running the command terraform init. This will download the required provider plugins and prepare your environment for deployment.
6. Preview the changes that Terraform will apply to your infrastructure using the command terraform plan. Review the planned resources and ensure they align with your expectations.
7. Deploy the infrastructure by executing the command terraform apply. Confirm the deployment when prompted. Terraform will create the specified AWS resources according to the defined configuration.

# Conclusion:
By utilizing this Terraform configuration, you can easily provision a scalable and resilient infrastructure on AWS. The provided code automates the deployment of an EC2 instance, an Auto Scaling Group, and an Elastic Load Balancer, setting the foundation for a robust and highly available environment. Feel free to customize the configuration to fit your specific needs and leverage the power of infrastructure as code with Terraform.

#  GCP-Terraform-ClusterOrchestrator 🐱‍🏍

Table of Contents
==================

- [GCP-Terraform-ClusterOrchestrator 🐱‍🏍](#gcp-terraform-clusterorchestrator-)
- [Table of Contents](#table-of-contents)
  - [Description 🧐](#description-)
  - [Technologies Used](#technologies-used)
  - [Project Workflow](#project-workflow)
  - [Prerequisites](#prerequisites)
  - [Usage 🚀](#usage-)
    - [cloning the Project](#cloning-the-project)
    - [Terraform Backend Initializing](#terraform-backend-initializing)
    - [Initialize Terraform in the project directory](#initialize-terraform-in-the-project-directory)
  - [Creating Workspaces](#creating-workspaces)
  - [Managing Variables](#managing-variables)
  - [Executing Local Provisioner](#executing-local-provisioner)
  - [Jenkins Integration](#jenkins-integration)
    - [jenkins server deployment using docker](#jenkins-server-deployment-using-docker)
    - [Jenkinsfile \& stages](#jenkinsfile--stages)
      - [before pipeline stages](#before-pipeline-stages)
      - [stage one](#stage-one)
      - [stage two](#stage-two)
      - [stage three](#stage-three)
      - [stage four](#stage-four)
    - [jenkins Pipeline execution](#jenkins-pipeline-execution)
  - [Email Notifications with AWS SES](#email-notifications-with-aws-ses)
  - [lambda function](#lambda-function)
  - [Event notifiction in s3 bucket](#event-notifiction-in-s3-bucket)
  - [Getting an email notifiction](#getting-an-email-notifiction)
  



## Description 🧐
This project is focused on the creation of a Google Cloud Platform (GCP) infrastructure using Terraform. The infrastructure encompasses various components, including service accounts, a Virtual Private Cloud (VPC), subnets, firewall rules, a Network Address Translation (NAT) gateway, virtual machines (VMs), a Google Kubernetes Engine (GKE) standard cluster, and an Artifact Registry repository. Additionally, the project deploys a MongoDB replica set spanning three zones, containerizes and deploys a Node.js web application that connects to the replica set, and exposes the web application using a load balancer.

## Technologies Used

We've utilized a wide range of technologies to develop this project, including:

*    terraform
*    nodejs
*    express framework
*    docker
*    GCP
*    bash
*    k8s

## Project Workflow
![Blank diagram(2)](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/d4e38dd2-a8dd-47aa-a1ef-2c4777de0126)
## Prerequisites

Before getting started, ensure you have the following prerequisites in place:

* Terraform installed on your Jenkins server.
* AWS CLI configured with necessary credentials and permissions.
* S3 bucket for storing Terraform state files.
* dynamodb talbe configured for state lock
* AWS lambda configured for using ses service.
* AWS SES configured for sending email notifications (if applicable).
* Jenkins server with necessary plugins (if applicable).

## Usage 🚀
### cloning the Project

1. Clone this repository to your Jenkins server or local machine:
```bash
git clone https://github.com/abdalla-abdelsalam/InfraControl
```

```bash
cd  InfraControl
```
### Terraform Backend Initializing
You can use the below script to create the necessary terraform backend (s3 bucket for storing the state and dynamodb table for state locking)
![Screenshot from 2023-10-02 17-22-16](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/f315ebab-c8dd-4e4e-b8a2-ac6e8c20ab3c)

### Initialize Terraform in the project directory

```bash
terraform init
```

## Creating Workspaces

This project includes two predefined workspaces: dev and prod. 
You can create them using the following commands:

For dev workspace:
```bash
terraform workspace new dev
```
For prod workspace:

```bash
terraform workspace new prod
```


## Managing Variables

Customize the variable values in the dev.tfvars and prod.tfvars files to match your specific environment requirements.

Select the appropriate workspace for the environment you want to create:

```bash
terraform workspace select dev
```
OR
```bash
terraform workspace select prod
```

Apply the Terraform configuration to create the infrastructure:

```bash
terraform apply -var-file=dev.tfvars
```
dev.tfvars file
```
cidr_block = "10.0.0.0/16"
ami_id = "ami-053b0d53c279acc90"
instance_type = "t2.micro"
subnets_pub_cidr = ["10.0.1.0/24","10.0.2.0/24"]
subnets_priv_cidr = ["10.0.3.0/24","10.0.4.0/24"]
region = "us-east-1"
subnets_azs = ["us-east-1a","us-east-1b"]
```
OR
```bash
terraform apply -var-file=prod.tfvars
```
prod.tfvars file
```
cidr_block     = "172.0.0.0/16"
ami_id        = "ami-04e601abe3e1a910f"
instance_type = "t2.micro"
subnets_pub_cidr = ["172.0.1.0/24", "172.0.2.0/24"]
subnets_priv_cidr = ["172.0.3.0/24", "172.0.4.0/24"]
region        = "eu-central-1"
subnets_azs   = ["eu-central-1a", "eu-central-1b"]

```

## Executing Local Provisioner

After creating the infrastructure, the local-exec provisioner will print the public IP of the Bastion EC2 instance in the specified environment and saving the value into an inventory file. This is automatically done as part of the Terraform apply process.

```
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > inventory"
  }
```
## Jenkins Integration

This project integrates Jenkins for continuous deployment. The Jenkins pipeline configured to accept an env-param, which determines which Terraform environment to apply changes to (dev or prod), also there is an optional param if you want to destroy the infrastructure
### jenkins server deployment using docker 

You can use this dockerfile for building docker image that includes jenkins server and terrform will be also installed
![Screenshot from 2023-10-02 16-31-55](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/d008a33d-971d-4214-b069-fce8bb8caa62)
Run the follwoing command to build the image
```
docker build -t jenkins-with-terraform .
```
Run the following command to start a container from the image
```
docker run -d -p 8080:8080 -p 50000:50000 --name jenkins-with-terraform jenkins-with-terraform
```
### Jenkinsfile & stages
#### before pipeline stages
you should add aws credentials that includes:
* aws_access_key
* aws_secrets_access_key
  
to jenkins server as secrets file or text
![Screenshot from 2023-10-02 16-39-45](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/9bbc3068-3e8e-4ef8-9b57-d1a1ff798c91)

we will reference these secrests in the jenkinsfile and expose them as environment variables to make terraform able to access aws.

in the image below we also configure 2 parameters to pass to jenkins pipeline before executing :
* environment (dev or prod)
* boolean for the destroying option
![Screenshot from 2023-10-02 16-32-30](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/92a55549-ade2-422f-9c49-4ae4ff79a2c3)
#### stage one
Intializing terraform and selecting the desired workspace, 
also create the workspace if not exsits.
![Screenshot from 2023-10-02 16-32-56](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/e0dbe84e-4067-4d88-9385-940b0a9d77fe)
#### stage two 
Terraform apply stage with passing the necessary evn variable file and also archieving the inventory file that contains the public ip of the bastian host

![Screenshot from 2023-10-02 16-33-04](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/241784c7-de3a-491a-a7dc-94d42ecdb25a)

#### stage three
This stage is responsible for printing the public ip address of the bastian host
![Screenshot from 2023-10-02 16-33-08](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/b4d091a9-1c56-4102-8256-9ae0ba70d18c)

#### stage four
This is the destroy stage (only executed if the destroy option is set to true)

![Screenshot from 2023-10-02 16-33-26](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/8a4d5f58-ddf7-4e72-ac25-718aa6af26c7)

### jenkins Pipeline execution 
when applying terraform 
![Screenshot from 2023-10-02 17-46-47](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/69e11502-678a-435d-b1cf-f2f73cbcaa54)

![Screenshot from 2023-10-02 04-45-16](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/34fbcda3-29cb-4b84-8bd1-903a10350dce)

Getting the public ip of the bastion host
![Screenshot from 2023-10-02 04-45-58](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/4ee5347a-216c-4303-a481-78d400f74fe7)

The ip matches the one from the aws console

![Screenshot from 2023-10-02 04-46-43](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/03d5c3ab-2e42-46a8-b61a-819b4e83eeb0)

when destroying terrform resources
![Screenshot from 2023-10-02 04-50-56](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/87a1c14d-bb82-4c2c-8953-dca350116f7d)

## Email Notifications with AWS SES
Before using an email address in your Lambda function to send email notifications, it must be verified in AWS SES (Simple Email Service). Follow the verification steps in the AWS SES console to ensure the email address is authorized to send emails.
![Screenshot from 2023-10-02 05-03-39](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/af46e473-1021-4001-991b-b4fa15b9ef54)

## lambda function
This project includes a Lambda function that sends email notifications using AWS SES when the Terraform state in the S3 bucket is updated.

Also don't forget to give the lambda the necessary permissions to access ses service.

![Screenshot from 2023-10-02 05-10-59](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/3ab57340-be9b-4445-a5bd-c88230a92e18)

## Event notifiction in s3 bucket
Configure an S3 event notification that watches for changes to the Terraform state file in your S3 bucket. When the state file is updated, this event will automatically invoke a Lambda function, enabling real-time responses to state changes and allowing for actions like sending notifications .
![Screenshot from 2023-10-02 17-29-10](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/92b0dedc-c683-4c0f-b3fe-87fc9f372994)

## Getting an email notifiction 
when an update happens to terraform state file in s3 bucket an email notificdtion sent to indicate that a change in the state happened
![Screenshot from 2023-10-02 05-23-48](https://github.com/abdalla-abdelsalam/InfraControl/assets/51873396/896f29cd-2b04-4a86-9c21-3dca1d7a6d64)# GCP-Terraform-ClusterOrchestrator

# GCP-Terraform-ClusterOrchestrator 🐱‍🏍

Table of Contents
=================

- [GCP-Terraform-ClusterOrchestrator 🐱‍🏍](#gcp-terraform-clusterorchestrator-)
- [Table of Contents](#table-of-contents)
  - [Description 🧐](#description-)
  - [Technologies Used](#technologies-used)
  - [Project diagram](#project-diagram)
  - [Infrastructure Components](#infrastructure-components)
    - [Service Accounts](#service-accounts)
    - [Network](#network)
    - [Compute](#compute)
    - [Storage](#storage)
  - [Access Control and Connectivity](#access-control-and-connectivity)
  - [Prerequisites](#prerequisites)
  - [Deploying infrastrucutre 🚀](#deploying-infrastrucutre-)
    - [cloning the Project](#cloning-the-project)
    - [Initialize Terraform in the project directory](#initialize-terraform-in-the-project-directory)
    - [Deploy the infrastructure by running Terraform command.](#deploy-the-infrastructure-by-running-terraform-command)
  - [Accessing the managment instance](#accessing-the-managment-instance)
    - [After the Completion we move to the management instance](#after-the-completion-we-move-to-the-management-instance)
    - [Copy the k8s bash script file provided above in the repo then execute it](#copy-the-k8s-bash-script-file-provided-above-in-the-repo-then-execute-it)
    - [Wait until mongodb pods are running](#wait-until-mongodb-pods-are-running)
  - [Project-specific deployment steps for MongoDB replicaset](#project-specific-deployment-steps-for-mongodb-replicaset)
    - [Exec into mongodb-0 pod](#exec-into-mongodb-0-pod)
    - [Create user for accessing the app with minimum permissions](#create-user-for-accessing-the-app-with-minimum-permissions)
    - [Create admin user to initiate the replicaset](#create-admin-user-to-initiate-the-replicaset)
    - [After that we apply the statefulset-after.yaml file](#after-that-we-apply-the-statefulset-afteryaml-file)
    - [exec again into mongodb-0 pod (authentication is required)](#exec-again-into-mongodb-0-pod-authentication-is-required)
    - [Initiate the mongodb replicaset](#initiate-the-mongodb-replicaset)
    - [Getting the status of the replica](#getting-the-status-of-the-replica)
    - [Mongodb-0 pod is the primary replica](#mongodb-0-pod-is-the-primary-replica)
  - [App deployment and load balancer](#app-deployment-and-load-balancer)
    - [Deploying app yaml file](#deploying-app-yaml-file)
    - [App deployment pod is up and running](#app-deployment-pod-is-up-and-running)
    - [Getting the external ip of the load balancer](#getting-the-external-ip-of-the-load-balancer)
    - [Accessing the ip of the loadbalancer](#accessing-the-ip-of-the-loadbalancer)
  - [Simulate Primary Node Failure](#simulate-primary-node-failure)
    - [Use the kubectl delete pod command to delete the "mongodb-0" pod. This simulates a failure of the primary replica pod](#use-the-kubectl-delete-pod-command-to-delete-the-mongodb-0-pod-this-simulates-a-failure-of-the-primary-replica-pod)
    - [Accessing the load balancer again (data still persistent)](#accessing-the-load-balancer-again-data-still-persistent)
    - [Mongodb-1 has been elected as the new primary.](#mongodb-1-has-been-elected-as-the-new-primary)

## Description 🧐

This project is focused on the creation of a Google Cloud Platform (GCP) infrastructure using Terraform. The infrastructure encompasses various components, including service accounts, a Virtual Private Cloud (VPC), subnets, firewall rules, a Network Address Translation (NAT) gateway, virtual machines (VMs), a Google Kubernetes Engine (GKE) standard cluster, and an Artifact Registry repository. Additionally, the project deploys a MongoDB replica set spanning three zones, containerizes and deploys a Node.js web application that connects to the replica set, and exposes the web application using a load balancer.

## Technologies Used

We've utilized a wide range of technologies to develop this project, including:

* terraform
* nodejs
* express framework
* docker
* GCP
* bash
* k8s

## Project diagram

![Screenshot from 2023-10-23 22-11-21](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/c247a28b-73cf-4432-ae9a-d9e71979dabb)

## Infrastructure Components

### Service Accounts

The project includes two service accounts with an arbitrary number of associated roles. These service accounts are used to manage access control and permissions for various GCP resources.

### Network

* VPC: A Virtual Private Cloud is set up to provide network isolation for the project's components.
* 2 Subnets: Two subnets are created within the VPC to segregate the network resources.
* Firewall Rules: The project defines multiple firewall rules to control inbound and outbound traffic.
* NAT: A Network Address Translation (NAT) gateway is established to allow the management VM to access the internet while keeping the GKE cluster isolated.

### Compute

* Private VM: A single private virtual machine is provisioned, accessible only through the NAT gateway. This VM serves as a management instance for cluster operations, image pushing, and Artifact Registry interactions.
* GKE Standard Cluster: A GKE standard cluster spanning three zones is deployed. The GKE cluster is set to be private, ensuring it does not have direct internet access. It will be used to run containerized applications, including the Node.js web app and the MongoDB replica set.

### Storage

* Artifact Registry Repository: An Artifact Registry repository is created to store container images. All images deployed within the project are required to be stored in this repository.

## Access Control and Connectivity

* Management VM Access: Only the private management VM has access to the internet through the NAT gateway. This VM serves as the control center for cluster management and image operations.

* GKE Cluster Isolation: The GKE cluster is isolated from the internet to enhance security. It does not have direct internet access but can communicate internally within the GCP infrastructure.

* Artifact Registry Integration: All deployed container images must be stored in the Artifact Registry repository, ensuring a centralized and controlled image management process.

## Prerequisites

Before getting started, ensure you have the following prerequisites in place:

To deploy this project, follow the steps below:

* Set up your Google Cloud Platform account and configure your credentials.
* Install Terraform and ensure it is configured to access your GCP account.
* Clone this project repository to your local machine.
* Modify the Terraform configuration files to suit your specific requirements, such as changing project-specific variables and credentials.

## Deploying infrastrucutre 🚀

### cloning the Project

1. Clone this repository to  local machine:

```bash
git clone https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator.git
```

```bash
cd  GCP-Terraform-ClusterOrchestrator
```

### Initialize Terraform in the project directory

```bash
terraform init
```

### Deploy the infrastructure by running Terraform command.

```bash
terraform apply --auto-approve
```

![Screenshot from 2023-10-23 20-15-28](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/9ae4bbd9-1ddb-447a-b56a-fc36db6ce638)

## Accessing the managment instance

### After the Completion we move to the management instance

![Screenshot from 2023-10-23 20-52-19](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/1284af0a-201e-4216-b202-61c15a937cf2)

### Copy the k8s bash script file provided above in the repo then execute it

* the script deploys configmaps, secrets and necessary services yaml files
![Screenshot from 2023-10-23 21-02-44](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/a8dc8bc3-0489-4d63-8d41-d2688d10ee93)

### Wait until mongodb pods are running

![Screenshot from 2023-10-23 21-12-09](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/7cb15ec5-f0a6-436c-98d8-28f4ee41bbc5)

## Project-specific deployment steps for MongoDB replicaset

### Exec into mongodb-0 pod

![Screenshot from 2023-10-23 21-26-09](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/fd75acd4-40b8-4034-ab3a-99432b6dfe3d)

### Create user for accessing the app with minimum permissions

![Screenshot from 2023-10-23 21-26-37](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/248b3ce8-71a3-4dfc-8ff8-676cd947e7ad)

### Create admin user to initiate the replicaset

![Screenshot from 2023-10-23 21-27-19](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/e567328c-9119-4261-b575-9ed80d60839c)

### After that we apply the statefulset-after.yaml file

![Screenshot from 2023-10-23 21-28-47](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/96a00971-3ebb-47c4-922b-58d4e8912ea8)

### exec again into mongodb-0 pod (authentication is required)

![Screenshot from 2023-10-23 21-29-36](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/bc883244-4613-41d0-9f5a-541eb95ae5a3)

### Initiate the mongodb replicaset

![Screenshot from 2023-10-23 21-30-07](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/031274a5-c45d-4d8a-a333-a6a716acdcee)

### Getting the status of the replica

![Screenshot from 2023-10-23 21-32-38](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/ce00c835-8113-4cda-9fec-39fc52852a0a)

### Mongodb-0 pod is the primary replica

![Screenshot from 2023-10-23 21-53-50](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/7e4dfc21-3513-419a-bcfa-4e9d3118bfd6)

## App deployment and load balancer

### Deploying app yaml file

![Screenshot from 2023-10-23 21-33-17](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/c3942a2a-452c-4b36-bfcf-07404f447202)

### App deployment pod is up and running

![Screenshot from 2023-10-23 21-37-53](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/f477a8d3-ff7c-43fe-a0e2-4d1bb1364042)

### Getting the external ip of the load balancer

![Screenshot from 2023-10-23 21-38-04](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/1c0a03b2-8feb-40d4-9147-a2d63e88dcc1)

### Accessing the ip of the loadbalancer

![Screenshot from 2023-10-23 21-38-53](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/2d60432b-94cc-42a2-b952-024af0446daf)

## Simulate Primary Node Failure

### Use the kubectl delete pod command to delete the "mongodb-0" pod. This simulates a failure of the primary replica pod

![Screenshot from 2023-10-23 21-41-39](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/dfd64744-4d77-4c33-89b4-5e870b2fcc18)

### Accessing the load balancer again (data still persistent)

![Screenshot from 2023-10-23 21-41-55](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/85e2837c-f1a3-4afd-98cb-e693e0abca5f)

### Mongodb-1 has been elected as the new primary.

![Screenshot from 2023-10-23 21-45-11](https://github.com/abdalla-abdelsalam/GCP-Terraform-ClusterOrchestrator/assets/51873396/73f8e352-0476-4070-a8a6-de1fa3f4ded0)

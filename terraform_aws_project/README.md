# AWS Infrastructure Provisioning using Terraform

This project provisions a basic AWS cloud infrastructure using Terraform. It sets up networking components, EC2 instances, security configurations, and an S3 bucket in an automated and repeatable way.

---

## 🚀 Infrastructure Components

The following AWS resources are created:

- Virtual Private Cloud (VPC)
- Public Subnet
- Internet Gateway
- Route Table and Route Table Association
- Security Group allowing SSH access (port 22)
- EC2 instances (using for_each)
- EC2 Key Pair (from existing public key)
- Root EBS volumes
- S3 Bucket with random name
- Random ID resources for uniqueness

---

## 🏗 Architecture Overview

- A custom VPC is created using a user-defined CIDR block.
- A public subnet is carved from the VPC CIDR.
- Internet Gateway is attached to the VPC.
- Route table routes internet traffic (0.0.0.0/0) via the Internet Gateway.
- EC2 instances are launched in the public subnet with public IPs.
- SSH access is enabled via a security group.
- An S3 bucket is created for storage or future use (artifacts/state).

---

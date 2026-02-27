# 94. AWS VPC Creation Using Terraform

This repository contains a minimal Terraform configuration that creates an AWS Virtual Private Cloud (VPC) named `devops-vpc` in the `us-east-1` region. It's intended for incremental cloud migration as part of the Nautilus DevOps team's phased approach.

---

## What this configuration creates
- VPC Name: `devops-vpc`
- CIDR Block: `10.0.0.0/16`
- DNS support: enabled
- DNS hostnames: enabled
- Region: `us-east-1`

---

## Files
- `main.tf` — Terraform configuration defining the AWS provider and the `aws_vpc` resource.

---

## Prerequisites
- Terraform v1.0+ installed: https://www.terraform.io/downloads
- AWS CLI installed and configured with credentials (`aws configure`) or environment variables set (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION).
- IAM user/role with permissions to create VPC resources (ec2:CreateVpc, ec2:DescribeVpcs, etc.).

---

## Quick start

1. Change into the Terraform directory:
   ```bash
   cd /home/bob/terraform
   ```

2. Initialize the working directory (downloads providers and sets up the backend):
   ```bash
   terraform init
   ```

3. Preview the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration to create the VPC:
   ```bash
   terraform apply -auto-approve
   ```

---

## Notes / Considerations
- The configuration uses the IPv4 CIDR block `10.0.0.0/16`. Adjust the CIDR if this range collides with existing networks.
- DNS support and DNS hostnames are enabled so EC2 instances launched in the VPC can receive public DNS hostnames (useful for many workflows).
- If you need multiple environments (dev/stage/prod), consider parameterizing `main.tf` with variables and using workspaces or separate state backends.

---

## Cleanup
To destroy all resources created by this configuration:
```bash
terraform destroy -auto-approve
```

---

## Helpful links
- Terraform docs: https://www.terraform.io
- AWS provider docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- VPC resource docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

---

## Troubleshooting
- "Insufficient permissions" errors: verify IAM permissions for the credentials in use.
- Provider plugin or init errors: run `terraform init -upgrade`.
- Networking/CIDR conflicts: change the VPC CIDR or ensure there are no overlapping networks with on-prem or other VPCs.

---


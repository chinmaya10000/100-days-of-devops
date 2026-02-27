# Terraform — datacenter-sg (Nautilus DevOps)

This repository contains Terraform configuration to create a security group named `datacenter-sg` in the **default VPC** of the **us-east-1** AWS region for the Nautilus application servers.

## Requirements
- Terraform (compatible version installed locally)
- AWS credentials configured (via environment variables, shared credentials file, or IAM role)
- AWS provider pinned to version `5.91.0`

## What this provisions
- A security group named `datacenter-sg`
- Description: `Security group for Nautilus App Servers`
- Ingress:
  - HTTP (tcp 80) — source `0.0.0.0/0`
  - SSH (tcp 22) — source `0.0.0.0/0`
- Egress: allow all outbound traffic
- Attached to the default VPC in `us-east-1`

## Files
- `main.tf` — Terraform configuration (provider, default VPC resource, security group)

## How to run

1. Change to the Terraform directory:
   ```bash
   cd /home/bob/terraform
   ```

2. Initialize Terraform (downloads provider):
   ```bash
   terraform init
   ```

3. Preview what will be created:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply -auto-approve
   ```

## Verify the resource (example using AWS CLI)
After apply, you can confirm the SG exists and rules are set:

```bash
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=datacenter-sg" \
  --region us-east-1
```

You should see HTTP (80) and SSH (22) allowed from `0.0.0.0/0` and unrestricted outbound rules.

## Notes
- The configuration creates/uses the default VPC with the resource `aws_default_vpc` (this is required because the data source `aws_default_vpc` is not supported in the pinned provider version).
- Provider is pinned exactly to version `5.91.0` as required.
- Opening SSH (22) to 0.0.0.0/0 is permitted here because it was requested; for production you should restrict SSH to known IP ranges.

## Expected outcome
A security group named `datacenter-sg` in `us-east-1` attached to the default VPC with:
- HTTP (80) from `0.0.0.0/0`
- SSH (22) from `0.0.0.0/0`
- All outbound traffic allowed

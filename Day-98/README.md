# AWS Private VPC, Subnet & EC2 Deployment using Terraform

This project provisions a private AWS network and a single EC2 instance inside it using Terraform.  
All resources are private to the VPC — the EC2 instance is only reachable from inside the VPC CIDR.

---

## Project structure

/home/bob/terraform
- main.tf
- variables.tf
- outputs.tf
- README.md

---

## Resources created

| Resource     | Name               | CIDR / Type |
|--------------|--------------------|-------------|
| VPC          | `devops-priv-vpc`  | 10.0.0.0/16 |
| Subnet       | `devops-priv-subnet` | 10.0.1.0/24 |
| EC2 Instance | `devops-priv-ec2`  | t2.micro    |

A Security Group restricts inbound access to the VPC CIDR (10.0.0.0/16) only.

---

## Variables

This project uses (at least) the following variables:

- `KKE_VPC_CIDR` — CIDR block for the VPC (example: `10.0.0.0/16`)
- `KKE_SUBNET_CIDR` — CIDR block for the Subnet (example: `10.0.1.0/24`)

You can provide these via a `terraform.tfvars` file, environment variables, or CLI `-var` flags.

Example `terraform.tfvars` contents:
```hcl
KKE_VPC_CIDR    = "10.0.0.0/16"
KKE_SUBNET_CIDR = "10.0.1.0/24"
```

---

## Outputs

The configuration exposes these outputs:

- `KKE_vpc_name` — VPC Name
- `KKE_subnet_name` — Subnet Name
- `KKE_ec2_private` — EC2 Instance Name

Example output after apply:
```
KKE_vpc_name = devops-priv-vpc
KKE_subnet_name = devops-priv-subnet
KKE_ec2_private = devops-priv-ec2
```

---

## How to run

1. Change into the project directory:
```bash
cd /home/bob/terraform
```

2. Initialize Terraform (downloads providers & sets up backend):
```bash
terraform init
```

3. (Optional) Validate configuration:
```bash
terraform validate
```

4. Preview changes:
```bash
terraform plan -out=tfplan
```

5. Apply the configuration:
```bash
terraform apply -auto-approve
# or, if you used a saved plan:
# terraform apply "tfplan"
```

6. Inspect outputs:
```bash
terraform output
```

7. Confirm nothing is pending:
```bash
terraform plan
# Expected:
# No changes. Infrastructure is up-to-date.
```

---

## Security notes

- The EC2 instance is placed in a private subnet with no public IP. Access is only allowed from inside the VPC CIDR via its security group.
- If you need SSH access, consider using a bastion host in a separate public subnet or AWS Systems Manager Session Manager (recommended for private instances).
- Keep your AWS credentials secure and follow the principle of least privilege for any IAM identities used.

---

## Cleanup

To destroy everything created by this configuration:
```bash
terraform destroy -auto-approve
```

---
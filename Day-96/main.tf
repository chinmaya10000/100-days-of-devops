# Terraform EC2 Deployment

## Overview
This Terraform configuration provisions an Amazon EC2 instance for the Nautilus DevOps team's gradual cloud migration. All resources are defined in a single file: `main.tf`.

What it creates:
- An EC2 instance named `datacenter-ec2`
- Uses Amazon Linux AMI `ami-0c101f26f147fa7fd` (us-east-1)
- Instance type: `t2.micro`
- Generates an RSA key pair named `datacenter-kp`
- Attaches the default security group from the default VPC
- Saves the private key locally as `datacenter-kp.pem` in the module directory

## Project structure
/home/bob/terraform
```
├── main.tf        # Terraform configuration file
└── README.md      # This file
```

## Terraform (main.tf)
The `main.tf` included in this project performs the steps above. Example contents (already present in repo):

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "datacenter_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "datacenter_kp" {
  key_name   = "datacenter-kp"
  public_key = tls_private_key.datacenter_key.public_key_openssh
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_instance" "datacenter_ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.datacenter_kp.key_name

  vpc_security_group_ids = [
    data.aws_security_group.default.id
  ]

  tags = {
    Name = "datacenter-ec2"
  }
}

resource "local_file" "private_key" {
  content  = tls_private_key.datacenter_key.private_key_pem
  filename = "${path.module}/datacenter-kp.pem"
}
```

## Prerequisites
- Terraform installed (run `terraform -version`)
- AWS CLI configured with credentials (`aws configure`) or environment variables set
- IAM permissions allowing: EC2, VPC read, KeyPair create, and S3/local write (as needed)
- Network restrictions: ensure your account has a default VPC and default security group in the target region

## How to deploy
Run the following from the project directory (e.g., `/home/bob/terraform`):

```sh
terraform init
terraform validate
terraform apply -auto-approve
```

After apply completes the private key will be written to `./datacenter-kp.pem`. Restrict its permissions:

```sh
chmod 600 datacenter-kp.pem
```

Use the key to SSH (example; replace PUBLIC_IP with instance IP and ec2-user if Amazon Linux):

```sh
ssh -i datacenter-kp.pem ec2-user@PUBLIC_IP
```

## Destroy resources
To remove everything created by this configuration:

```sh
terraform destroy -auto-approve
```

Important: `terraform destroy` will not automatically delete the locally-written `datacenter-kp.pem` file. Remove it manually if desired:
```sh
rm -f datacenter-kp.pem
```

## Security notes
- The private key is saved locally by `local_file`. Ensure the file is stored securely and file permissions are restricted.
- Consider using a secrets manager (e.g., AWS Secrets Manager or SSM Parameter Store) for production key handling rather than writing private keys to disk.
- Confirm your IAM credentials follow least-privilege principles.

## Troubleshooting
- If `data.aws_vpc.default` fails, ensure a default VPC exists in the selected region.
- If the AMI is not found, the AMI ID may be region-specific or deprecated — replace with a region-appropriate AMI.
- For permission errors, check the IAM policy attached to your AWS credentials.

## License
Add project-specific license info here if required.
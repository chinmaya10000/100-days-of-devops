# IAM Read-Only EC2 Policy (iampolicy_rose)

This Terraform project creates an IAM policy named `iampolicy_rose` that grants read-only permissions for viewing EC2-related resources (instances, AMIs, snapshots, volumes, security groups, VPCs, subnets, etc.).

Location of the Terraform working directory used in examples:
`/home/bob/terraform`

---

## Files

- `main.tf` — Terraform configuration that defines the `iampolicy_rose` IAM policy.
- `README.md` — This file.

---

## Summary of Permissions

The IAM policy grants the following read-only EC2 actions (Resource = "*"):

- `ec2:DescribeInstances`
- `ec2:DescribeImages`
- `ec2:DescribeSnapshots`
- `ec2:DescribeVolumes`
- `ec2:DescribeTags`
- `ec2:DescribeSecurityGroups`
- `ec2:DescribeKeyPairs`
- `ec2:DescribeVpcs`
- `ec2:DescribeSubnets`

This is intended to allow console and API/CLI users to view EC2 resources without granting modification rights.

---

## Prerequisites

- Terraform (recommended >= 1.0.x)
- AWS account and credentials with permissions to create IAM policies
- (Optional) AWS CLI for attaching the created policy to users/groups/roles

Configure AWS credentials using one of:
- Environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` (if needed)
- `~/.aws/credentials` with `aws configure`
- `AWS_PROFILE` to select a specific profile

Note: IAM is a global service. The provider region in `main.tf` does not affect the policy itself, but the example provider in `main.tf` uses `us-east-1`.

---

## How to deploy

1. Open a terminal and change directory to the Terraform working directory:

   cd /home/bob/terraform

2. Initialize Terraform and verify:

   terraform init
   terraform fmt
   terraform validate

3. Preview the changes:

   terraform plan -out=tfplan

4. Apply to create the IAM policy:

   terraform apply -auto-approve

After apply completes, the `iampolicy_rose` IAM policy will exist in your account.

---

## How to attach the policy

You can attach the policy to a user, group, or role via the AWS Console, or with the AWS CLI.

1. Get your account ID (for building the policy ARN):

   aws sts get-caller-identity --query Account --output text

2. Example AWS CLI commands (replace `<ACCOUNT_ID>` and the principal name):

   - Attach to a user:

     aws iam attach-user-policy --user-name alice --policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/iampolicy_rose

   - Attach to a group:

     aws iam attach-group-policy --group-name developers --policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/iampolicy_rose

   - Attach to a role:

     aws iam attach-role-policy --role-name ReadOnlyRole --policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/iampolicy_rose

Alternatively, find the created policy in the IAM Console (Policies → search `iampolicy_rose`) and attach it to the desired principals.

---

## Policy (reference)

The Terraform `main.tf` uses jsonencode to create this policy. The equivalent JSON looks like:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Cleanup

To remove the created policy and any other resources managed by this Terraform configuration:

terraform destroy -auto-approve

If the policy is attached to users/groups/roles, detach it first (via console or `aws iam detach-*` CLI commands), or the `terraform destroy` may fail while attachments exist.

---

## Notes & Best Practices

- Least privilege: Review whether you need all the `Describe*` actions or if scope should be restricted further.
- IAM policies are global — the provider region is incidental for IAM resources.
- If you need console access limited to a specific set of EC2 resources, consider scoping the policy with condition keys or resource ARNs where possible.
- If you want to allow read-only access across other services (S3, RDS, etc.), consider using AWS-managed policies such as `ReadOnlyAccess` or building a broader custom policy.

---

## Troubleshooting

- "Insufficient permissions" errors when running `terraform apply`: ensure your AWS credentials allow `iam:CreatePolicy` and related IAM actions.
- "Policy already exists" on re-apply: either rename the policy or import/align with the existing policy ARN.

---

## Maintainer

- chinamayadevops

---

License: MIT (or choose your preferred license)
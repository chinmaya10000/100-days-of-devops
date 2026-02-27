# DynamoDB + IAM Restricted Access using Terraform

This Terraform project provisions a secure AWS DynamoDB table and enforces fine-grained IAM access control. Only trusted AWS services assuming the created IAM role will have read-only access to the table.

## What this repo creates
- DynamoDB table (PAY_PER_REQUEST)
- IAM Role (trust boundary for a service principal, e.g. Lambda)
- Read-only IAM Policy scoped to the DynamoDB table
- Policy attached to the role

## Project structure
/home/bob/terraform
- main.tf
- variables.tf
- outputs.tf
- terraform.tfvars
- README.md (this file)

## Variables
Defined in `variables.tf`:
- `KKE_TABLE_NAME` - DynamoDB table name
- `KKE_ROLE_NAME` - IAM role name
- `KKE_POLICY_NAME` - IAM policy name

Example `terraform.tfvars`:
```hcl
KKE_TABLE_NAME   = "datacenter-table"
KKE_ROLE_NAME    = "datacenter-role"
KKE_POLICY_NAME  = "datacenter-readonly-policy"
```

## Important files (summary)
- main.tf - resources: `aws_dynamodb_table`, `aws_iam_role`, `aws_iam_policy`, `aws_iam_role_policy_attachment`
- variables.tf - variable declarations
- outputs.tf - outputs for table name, role name, and policy name

## Usage

Prerequisites:
- Terraform 1.x
- AWS CLI credentials configured (or another auth method supported by the AWS provider)
- AWS account with permissions to create DynamoDB and IAM resources

Deployment:
```bash
terraform init
terraform validate
terraform apply -auto-approve
```

Verify (after apply):
```bash
terraform plan
# Expected: "No changes. Your infrastructure matches the configuration."
```

Destroy (cleanup):
```bash
terraform destroy -auto-approve
```

## Security & Notes
- The IAM policy grants only read-only DynamoDB actions:
  - `dynamodb:GetItem`
  - `dynamodb:Scan`
  - `dynamodb:Query`
- The policy Resource is scoped to the table ARN only (least privilege).
- The role's trust policy is currently set to:
  ```json
  "Principal": { "Service": "lambda.amazonaws.com" }
  ```
  Update the `Service` principal in `main.tf` if another AWS service (for example `ecs-tasks.amazonaws.com` or `ec2.amazonaws.com`) needs to assume the role.
- Consider enabling CloudTrail and IAM Access Analyzer for additional audit and anomaly detection.
- If your application needs secondary indexes or additional attributes, extend the `aws_dynamodb_table` resource accordingly.
- If you need programmatic fine-grained access (e.g., attribute or item-level restrictions), create more specific IAM conditions (for example `Condition` with `dynamodb:LeadingKeys`).

## Outputs
`outputs.tf` provides:
- `kke_dynamodb_table` — table name
- `kke_iam_role_name` — role name
- `kke_iam_policy_name` — policy name

## Example: granting read-only access from another account or service (notes)
- To allow cross-account services to assume the role, modify the `assume_role_policy` principal to include the other account's AWS principal or set up a separate role with a trusted external principal.
- For services running in other AWS accounts, prefer using IAM Roles Anywhere, resource-based policies, or cross-account roles with strict conditions.

## Troubleshooting
- "AccessDenied" when assuming the role:
  - Verify the service principal in `assume_role_policy` is correct.
  - Confirm the caller actually uses the role (correct Role ARN) and that STS is allowed.
- DynamoDB permission errors:
  - Ensure the resource ARN in the policy matches the table ARN (including region and account).
  - Use `terraform output` to confirm the exact names/ARNs.

## Next steps / Suggestions
- Add tags to the DynamoDB table and IAM resources for ownership and billing.
- Add automated tests (for example, Terraform Validate in CI).
- If you plan to have more granular access patterns, create separate policies for reads vs writes and attach accordingly.

---
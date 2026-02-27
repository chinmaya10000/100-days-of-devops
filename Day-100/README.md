# Nautilus DevOps – Terraform Deployment

This Terraform project deploys an EC2 instance and a CloudWatch alarm that notifies an existing SNS topic when CPU Utilization is high.

Alarm behavior
- Metric: AWS/EC2 -> CPUUtilization (Average)
- Threshold: >= 90%
- Period: 300 seconds (1 evaluation period = 5 minutes)
- Evaluation periods: 1
- Alarm name: `nautilus-alarm`
- SNS topic used: `nautilus-sns-topic`

---

## Repository layout

/home/bob/terraform
- main.tf
- outputs.tf
- README.md (this file)

---

## Prerequisites

- Terraform 1.0+ (or your team's supported version)
- AWS credentials configured in your environment (AWS CLI configured, or environment variables AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_DEFAULT_REGION)
- IAM permissions to create EC2, CloudWatch alarms and to use the SNS topic (or at least to read the existing SNS topic)
- The SNS topic `nautilus-sns-topic` must already exist in the same AWS account & region

---

## Quick start

1. Change to the terraform folder:
   ```
   cd /home/bob/terraform
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Preview changes:
   ```
   terraform plan
   ```

4. Apply:
   ```
   terraform apply -auto-approve
   ```

5. Validate (after apply):
   ```
   terraform plan
   ```
   Expected: `No changes. Your infrastructure matches the configuration.`

---

## Useful verification commands (AWS CLI)

- Verify alarm exists:
  ```
  aws cloudwatch describe-alarms --alarm-names "nautilus-alarm"
  ```

- Inspect alarm details:
  ```
  aws cloudwatch describe-alarms --alarm-names "nautilus-alarm" --query 'MetricAlarms[0]'
  ```

- Verify the SNS topic (list topics or get attributes for the topic ARN):
  ```
  aws sns list-topics
  # or, if you have the topic ARN:
  aws sns get-topic-attributes --topic-arn <topic-arn>
  ```

- Check EC2 instance:
  ```
  aws ec2 describe-instances --filters "Name=tag:Name,Values=nautilus-ec2"
  ```

---

## How to test the alarm manually

1. SSH into the EC2 instance once it's up:
   ```
   ssh ubuntu@<instance-public-ip-or-dns>
   ```

2. Install a load generator (example using `stress` on Ubuntu):
   ```
   sudo apt-get update
   sudo apt-get install -y stress
   # run CPU load for e.g. 10 minutes:
   sudo stress --cpu 1 --timeout 600
   ```

3. Wait ~5 minutes and check alarm state in CloudWatch or via AWS CLI:
   ```
   aws cloudwatch describe-alarm-history --alarm-names "nautilus-alarm"
   aws cloudwatch describe-alarms --alarm-names "nautilus-alarm"
   ```

Note: Generating sustained >90% CPU on a t2.micro may not be reliable due to burst credits; if you need consistent high CPU for testing, choose a larger instance type.

---

## Known issues & recommended fixes

1. Referencing an existing SNS topic:
   - Your current `main.tf` contains:
     ```hcl
     resource "aws_sns_topic" "sns_topic" {
       name = "nautilus-sns-topic"
     }
     ```
     That block will attempt to create a topic named `nautilus-sns-topic` (and may conflict if the topic already exists). If the topic is pre-existing, use a data source to reference it instead:

     Example replacement:
     ```hcl
     data "aws_sns_topic" "sns_topic" {
       name = "nautilus-sns-topic"
     }

     resource "aws_cloudwatch_metric_alarm" "nautilus_alarm" {
       # ...
       alarm_actions = [data.aws_sns_topic.sns_topic.arn]
       # ...
     }
     ```

2. AMI hardcoding:
   - The `ami = "ami-0c02fb55956c7d316"` is region-specific. Consider using a variable for region or use `data "aws_ami"` to lookup the latest Ubuntu AMI for your region.

3. Provider & Terraform version pinning:
   - Lock provider and required Terraform version in a `terraform { required_providers { ... } required_version = ">= 1.0.0" }` block to ensure reproducibility.

4. Outputs naming:
   - Current outputs are named `KKE_instance_name` and `KKE_alarm_name`. Consider more descriptive output names like `instance_name` and `alarm_name` to match project naming conventions.

---

## Suggested minimal main.tf changes

If you want the minimal safe change to reference the pre-existing SNS topic, replace the SNS `resource` with a `data` block and update the alarm to reference the data resource ARN. Example:

```hcl
# Replace resource "aws_sns_topic" "sns_topic" {...} with:
data "aws_sns_topic" "sns_topic" {
  name = "nautilus-sns-topic"
}

# Then in the alarm:
alarm_actions = [data.aws_sns_topic.sns_topic.arn]
```

---

## Troubleshooting

- "Topic already exists" on apply:
  - You likely have a name conflict. Use the data source approach above to reference the existing topic instead of trying to create it.

- Alarm never enters ALARM state during tests:
  - Confirm the instance is actually the one being alarmed (dimension InstanceId should match the instance ID).
  - Confirm the instance can produce sustained CPU load (t2.micro may not).
  - Check CloudWatch metric data for the instance:
    ```
    aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=<instance-id> --start-time "$(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%SZ)" --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --period 300 --statistics Average
    ```

---

## Next steps / Improvements

- Add variables for AMI, instance_type, region, and alarm thresholds.
- Add a security group for the EC2 instance (SSH only from allowed IPs).
- Pin provider versions and add `terraform fmt` / `terraform validate` as CI steps.
- Consider using CloudWatch Agent for more detailed metrics if needed.

---

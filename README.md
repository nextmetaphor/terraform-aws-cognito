# terraform-aws-cognito

```bash
export AWS_DEFAULT_REGION="us-east-1"
aws configure

terraform validate

terraform plan -out=tfplan

terraform apply tfplan

aws cognito-idp admin-create-user \
  --user-pool-id TODO \
  --username TODO \
  --temporary-password TODO \
  --user-attributes Name=email,Value=whatevs Name=email_verified,Value=True Name=custom:clearance,Value=clearance2
  
terraform show

terraform destroy -auto-approve
```
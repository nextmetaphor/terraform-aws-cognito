# terraform-aws-cognito

```bash
export AWS_DEFAULT_REGION="us-east-1"
aws configure

terraform validate

terraform plan -out=tfplan

terraform apply tfplan

USER_POOL_ID=
USER_NAME=
USER_PASSWORD=
aws cognito-idp admin-create-user \
  --user-pool-id ${USER_POOL_ID} \
  --username ${USER_NAME} \
  --temporary-password ${USER_PASSWORD} \
  --user-attributes Name=email,Value=${USER_NAME}@test.test Name=email_verified,Value=True Name=custom:clearance,Value=security-cleared
  
terraform show

terraform destroy -auto-approve
```
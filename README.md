# terraform-aws-cognito

### init
```bash
export AWS_DEFAULT_REGION="us-east-1"
aws configure

terraform init
```

### standup
```bash
# create stack
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# add s3 files
aws s3 cp _sample_files/public.txt s3://non-secured-bucket-xyz
aws s3 cp _sample_files/role-protection.txt s3://security-clearance-bucket-xyz
aws s3 cp _sample_files/attribute-protection.txt s3://attribute-secured-bucket-xyz

# create cognito user
USER_POOL_ID=
USER_NAME=
USER_PASSWORD=
aws cognito-idp admin-create-user \
  --user-pool-id ${USER_POOL_ID} \
  --username ${USER_NAME} \
  --temporary-password ${USER_PASSWORD} \
  --user-attributes Name=email,Value=${USER_NAME}@test.test Name=email_verified,Value=True Name=custom:clearance,Value=security-cleared Name=custom:department,Value=department1
```

### verify
```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=

aws s3 cp s3://non-secured-bucket-xyz/public.txt .
aws s3 cp s3://security-clearance-bucket-xyz/role-protection.txt .
aws s3 cp s3://attribute-secured-bucket-xyz/attribute-protection.txt .

```

### teardown
```bash
# remove s3 objects
aws s3 rm s3://non-secured-bucket-xyz/public.txt
aws s3 rm s3://security-clearance-bucket-xyz/role-protection.txt
aws s3 rm s3://attribute-secured-bucket-xyz/attribute-protection.txt

# remove stack
terraform destroy -auto-approve
```

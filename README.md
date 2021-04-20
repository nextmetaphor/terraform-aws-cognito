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

export CLIENT_ID=
export CLIENT_SECRET=
export ISSUER_URL=

terraform plan -out=tfplan -var idp_client_id=${CLIENT_ID} -var idp_client_secret=${CLIENT_SECRET} -var issuer_URL=${ISSUER_URL}

terraform apply tfplan 

# add s3 files
aws s3 cp _sample_files/public.txt s3://non-secured-bucket-xyz

# role-based access files
aws s3 cp _sample_files/role-protection.txt s3://security-clearance-bucket-xyz

# attribute-based access files
aws s3 cp _sample_files/department1/dept1-level1.txt s3://attribute-secured-bucket-xyz/department1/dept1-level1.txt
aws s3api put-object-tagging --bucket attribute-secured-bucket-xyz --key department1/dept1-level1.txt --tagging '{"TagSet": [{"Key": "clearance", "Value": "level1"}]}'
aws s3 cp _sample_files/department1/dept1-level2.txt s3://attribute-secured-bucket-xyz/department1/dept1-level2.txt
aws s3api put-object-tagging --bucket attribute-secured-bucket-xyz --key department1/dept1-level2.txt --tagging '{"TagSet": [{"Key": "clearance", "Value": "level2"}]}'

aws s3 cp _sample_files/department2/dept2-level1.txt s3://attribute-secured-bucket-xyz/department2/dept2-level1.txt
aws s3api put-object-tagging --bucket attribute-secured-bucket-xyz --key department2/dept2-level1.txt --tagging '{"TagSet": [{"Key": "clearance", "Value": "level1"}]}'
aws s3 cp _sample_files/department2/dept2-level2.txt s3://attribute-secured-bucket-xyz/department2/dept2-level2.txt
aws s3api put-object-tagging --bucket attribute-secured-bucket-xyz --key department2/dept2-level2.txt --tagging '{"TagSet": [{"Key": "clearance", "Value": "level2"}]}'

# create cognito users
USER_POOL_ID=
USER_NAME=test1
USER_PASSWORD=
aws cognito-idp admin-create-user \
  --user-pool-id ${USER_POOL_ID} \
  --username ${USER_NAME} \
  --temporary-password ${USER_PASSWORD} \
  --user-attributes Name=email,Value=${USER_NAME}@test.test Name=email_verified,Value=True Name=custom:clearance,Value=level1 Name=custom:department,Value=department1


USER_POOL_ID=
USER_NAME=test2
USER_PASSWORD=
aws cognito-idp admin-create-user \
  --user-pool-id ${USER_POOL_ID} \
  --username ${USER_NAME} \
  --temporary-password ${USER_PASSWORD} \
  --user-attributes Name=email,Value=${USER_NAME}@test.test Name=email_verified,Value=True Name=custom:clearance,Value=level2 Name=custom:department,Value=department1

USER_POOL_ID=
USER_NAME=test3
USER_PASSWORD=
aws cognito-idp admin-create-user \
  --user-pool-id ${USER_POOL_ID} \
  --username ${USER_NAME} \
  --temporary-password ${USER_PASSWORD} \
  --user-attributes Name=email,Value=${USER_NAME}@test.test Name=email_verified,Value=True Name=custom:clearance,Value=level1 Name=custom:department,Value=department2

```

### verify
```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=

aws s3 cp s3://non-secured-bucket-xyz/public.txt .
aws s3 cp s3://security-clearance-bucket-xyz/role-protection.txt .

aws s3 cp s3://attribute-secured-bucket-xyz/department1/dept1-level1.txt .
aws s3 cp s3://attribute-secured-bucket-xyz/department1/dept1-level2.txt .
aws s3 cp s3://attribute-secured-bucket-xyz/department2/dept2-level1.txt .
aws s3 cp s3://attribute-secured-bucket-xyz/department2/dept2-level2.txt .

```

### teardown
```bash
# remove s3 objects
aws s3 rm s3://non-secured-bucket-xyz/public.txt
aws s3 rm s3://security-clearance-bucket-xyz/role-protection.txt

aws s3 rm s3://attribute-secured-bucket-xyz/department1/dept1-level1.txt
aws s3 rm s3://attribute-secured-bucket-xyz/department1/dept1-level2.txt
aws s3 rm s3://attribute-secured-bucket-xyz/department2/dept2-level1.txt
aws s3 rm s3://attribute-secured-bucket-xyz/department2/dept2-level2.txt

# remove stack
terraform destroy -auto-approve
```

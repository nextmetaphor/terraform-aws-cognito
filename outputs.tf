output "security_clearance_role" {
  value = aws_iam_role.security_clearance_role
}

output "non_secured_bucket" {
  value = aws_s3_bucket.non_secured_bucket
}

output "security_clearance_bucket" {
  value = aws_s3_bucket.security_clearance_bucket
}

output "user_pool" {
  value = aws_cognito_user_pool.user_pool
}

output "user_pool_client" {
  value = aws_cognito_user_pool_client.user_pool_client
  sensitive = true
}

output "identity_pool" {
  value = aws_cognito_identity_pool.identity_pool
}
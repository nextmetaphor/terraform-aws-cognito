resource "aws_iam_role" "clearance1_role" {
  name = "clearance1_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action: "sts:AssumeRole",
        Principal: {
          Federated: "cognito-identity.amazonaws.com"
        },
        Effect: "Allow",
      },
    ]
  })

  tags = {
  }
}

// TODO needs to include the specific identity provider here
resource "aws_iam_role" "clearance2_role" {
  name = "clearance2_role-xyz"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action: "sts:AssumeRoleWithWebIdentity",
        Principal: {
          Federated: "cognito-identity.amazonaws.com"
        },
        Effect: "Allow",
      },
    ]
  })

  tags = {
  }
}

resource "aws_s3_bucket" "c1_bucket" {
  bucket = "c1-bucket-xyz"
}

resource "aws_s3_bucket" "c2_bucket" {
  bucket = "c2-bucket-xyz"
}

resource "aws_s3_bucket_policy" "clearance2_bucket_policy" {
  bucket = aws_s3_bucket.c2_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id = "clearance2_bucket_policy"
    Statement: [
      {
        Effect: "Deny",
        Principal: "*",
        Action: "s3:GetObject",
        Resource: [
          aws_s3_bucket.c2_bucket.arn,
          "${aws_s3_bucket.c2_bucket.arn}/*",
        ],
        Condition: {
          "StringNotLike": {
            "aws:userId": [
              "${aws_iam_role.clearance2_role.unique_id}:*",
              aws_iam_role.clearance2_role.unique_id,
            ]
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "clearance1_bucket_policy" {
  bucket = aws_s3_bucket.c1_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid = "IPAllow"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = [
          aws_s3_bucket.c1_bucket.arn,
          "${aws_s3_bucket.c1_bucket.arn}/*",
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = "8.8.8.8/32"
          }
        }
      },
    ]
  })
}

resource aws_cognito_user_pool user_pool {
  name = "client-pool"
}

resource aws_cognito_user_pool_client user_pool_client {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name = "user_pool_client"

  explicit_auth_flows = ["USER_PASSWORD_AUTH"]
  generate_secret = false

  callback_urls = ["https://bbc.co.uk/news"]
  logout_urls = ["https://google.com"]
  allowed_oauth_flows = ["implicit"]
  supported_identity_providers = ["COGNITO"]
  allowed_oauth_scopes = ["phone", "email", "openid", "aws.cognito.signin.user.admin", "profile"]
  allowed_oauth_flows_user_pool_client = true
}

resource aws_cognito_user_pool_domain user_pool_domain {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  domain = "brand-new-test-domain"
}

resource aws_cognito_identity_pool identity_pool {
  identity_pool_name = "identity_pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id = aws_cognito_user_pool_client.user_pool_client.id
    provider_name = aws_cognito_user_pool.user_pool.endpoint
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  role_mapping {
    identity_provider         = join(":", [aws_cognito_user_pool.user_pool.endpoint, aws_cognito_user_pool_client.user_pool_client.id])
    type                      = "Rules"
    ambiguous_role_resolution = "Deny"

    mapping_rule {
      claim      = "clearance"
      match_type = "Equals"
      value      = "clearance1"
      role_arn   = aws_iam_role.clearance1_role.arn
    }
  }

  roles = {
    authenticated = aws_iam_role.clearance1_role.arn
  }
}


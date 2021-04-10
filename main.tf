// TODO needs to include the specific identity provider here
resource "aws_iam_role" "security_clearance_role" {
  name = "security_clearance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action: [
          "sts:AssumeRoleWithWebIdentity",
          "sts:TagSession"],
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

resource "aws_s3_bucket" "non_secured_bucket" {
  bucket = "non-secured-bucket-xyz"
}

resource "aws_s3_bucket" "security_clearance_bucket" {
  bucket = "security-clearance-bucket-xyz"
}

resource "aws_s3_bucket_policy" "security_clearance_bucket_policy" {
  bucket = aws_s3_bucket.security_clearance_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id = "security_clearance_bucket_policy"
    Statement: [
      {
        Effect: "Deny",
        Principal: "*",
        Action: "s3:GetObject",
        Resource: [
          aws_s3_bucket.security_clearance_bucket.arn,
          "${aws_s3_bucket.security_clearance_bucket.arn}/*",
        ],
        Condition: {
          "StringNotLike": {
            "aws:userId": [
              "${aws_iam_role.security_clearance_role.unique_id}:*",
              aws_iam_role.security_clearance_role.unique_id,
            ]
          }
        }
      },
      {
        Effect: "Allow",
        Principal: "*",
        Action: "s3:*",
        Resource: [
          aws_s3_bucket.security_clearance_bucket.arn,
          "${aws_s3_bucket.security_clearance_bucket.arn}/*",
        ],
        Condition: {
          "StringLike": {
            "aws:userId": [
              "${aws_iam_role.security_clearance_role.unique_id}:*",
              aws_iam_role.security_clearance_role.unique_id,
            ]
          }
        }
      },
    ]
  })
}

resource "aws_s3_bucket" "attribute_secured_bucket" {
  bucket = "attribute-secured-bucket-xyz"

  tags = {
    clearance = "super-secure"
  }
}

resource "aws_s3_bucket_policy" "attribute_secured_bucket_policy" {
  bucket = aws_s3_bucket.attribute_secured_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id = "attribute_secured_bucket_policy"
    Statement: [
      {
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": [
          aws_s3_bucket.attribute_secured_bucket.arn,
          "${aws_s3_bucket.attribute_secured_bucket.arn}/*",
        ],
        "Condition": {
          "Null": {
            "aws:PrincipalTag/clearance": "true"
          }
        }
      },
      {
        Effect: "Deny",
        Principal: "*",
        Action: "s3:GetObject",
        Resource: [
          aws_s3_bucket.attribute_secured_bucket.arn,
          "${aws_s3_bucket.attribute_secured_bucket.arn}/*",
        ],
        Condition: {
          "StringNotEquals": {
            "s3:ExistingObjectTag/clearance":"$${aws:PrincipalTag/clearance}"
          }
        }
      },
      {
        Effect: "Allow",
        Principal: "*",
        Action: "s3:*",
        Resource: [
          aws_s3_bucket.attribute_secured_bucket.arn,
          "${aws_s3_bucket.attribute_secured_bucket.arn}/*",
        ],
        Condition: {
          "StringEquals": {
            "s3:ExistingObjectTag/clearance": "$${aws:PrincipalTag/clearance}"
          }
        }
      },
    ]
  })
}

resource aws_cognito_user_pool user_pool {
  name = "client-pool"

  schema {
    attribute_data_type = "String"
    name = "clearance"
  }

  schema {
    attribute_data_type = "String"
    name = "department"
  }
}

resource aws_cognito_user_pool_client user_pool_client {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name = "user_pool_client"

  explicit_auth_flows = [
    "USER_PASSWORD_AUTH"]
  generate_secret = false

  callback_urls = [
    "https://bbc.co.uk/news"]
  logout_urls = [
    "https://google.com"]
  allowed_oauth_flows = [
    "implicit"]
  supported_identity_providers = [
    "COGNITO"]
  allowed_oauth_scopes = [
    "phone",
    "email",
    "openid",
    "aws.cognito.signin.user.admin",
    "profile"]
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
    identity_provider = join(":", [
      aws_cognito_user_pool.user_pool.endpoint,
      aws_cognito_user_pool_client.user_pool_client.id])
    type = "Rules"
    ambiguous_role_resolution = "Deny"

    mapping_rule {
      claim = "custom:clearance"
      match_type = "Equals"
      value = "security-cleared"
      role_arn = aws_iam_role.security_clearance_role.arn
    }
  }

  roles = {
    authenticated = aws_iam_role.security_clearance_role.arn
  }
}
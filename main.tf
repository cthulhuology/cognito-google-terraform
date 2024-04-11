# main.tf
# vim: ts=2 tw=80 sw=2 et:
#

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" { }

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.google.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

data "aws_iam_policy_document" "authorized_policy" {
  statement {
    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*",
      "iot:*",
      "kinesisvideo:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "authorized_user_policy" {
  name   = "AuthorizedUser"
  policy = data.aws_iam_policy_document.authorized_policy.json
}

resource "aws_iam_role" "authenticated" {
  name               = "AuthorizedUserRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "authorized_role_policy" {
  role       = aws_iam_role.authenticated.name
  policy_arn = aws_iam_policy.authorized_user_policy.arn
}

resource "aws_cognito_identity_pool" "google" {
  identity_pool_name = "google"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false
  supported_login_providers = {
    "accounts.google.com" = "${local.google_client_id}"
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "google" {
  identity_pool_id = aws_cognito_identity_pool.google.id

  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
  }
}

output "cognito_identity_pool_id"  {
  value = aws_cognito_identity_pool.google.id
}

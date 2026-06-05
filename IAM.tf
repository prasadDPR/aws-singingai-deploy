/*
resource "aws_iam_user" "terraform_user" {
  name = "terraform-user"
}

resource "aws_iam_access_key" "terraform_user_access_key" {
  user = aws_iam_user.terraform_user.name
}

resource "aws_iam_user_policy" "s3_bucket_policy" {
  name   = "s3_bucket_policy"
  user   = aws_iam_user.terraform_user.name
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::error-pages-scctf-bucket"
      }
    ]
  })
}

output "access_key_id" {
  value = aws_iam_access_key.terraform_user_access_key.id
}

output "secret_access_key" {
  value = aws_iam_access_key.terraform_user_access_key.secret
  sensitive = true
}
*/

resource "aws_iam_role" "this" {
  name = "${var.application_name}_role"
  assume_role_policy = jsonencode(
    {
      Version =  "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = "ec2.amazonaws.com"
          },
          Effect = "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.application_name}_instance_profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_policy" "this" {
  name = "${var.application_name}_policy"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "rds:*",
            "ec2:*"
          ],
          Effect = "Allow",
          Resource = "*"
        },
        { Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:Describe*",
          "ec2:Describe*",
          ],
          Effect = "Allow",
        Resource = "*" }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  role = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "iam_for_lambda" {
  name = "anachro_iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

output "iam_lambda_arn" {
  value = "${aws_iam_role.iam_for_lambda.arn}"
}

resource "aws_iam_policy" "read-write-to-ddb" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": "lambda:InvokeFunction",
          "Resource": "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*"
      },
      {
            "Effect": "Allow",
            "Action": [
                "execute-api:Invoke",
                "execute-api:ManageConnections"
            ],
            "Resource": "arn:aws:execute-api:*:${data.aws_caller_identity.current.account_id}:*"
      },
    {
      "Effect": "Allow",
      "Action": [
          "dynamodb:*"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current.account_id}:table/*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "mobiletargeting:SendMessages"
      ],
      "Resource": "arn:aws:mobiletargeting:us-east-1:${data.aws_caller_identity.current.account_id}:apps/*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "write_to_dynamodb_tables" {
  name       = "write_to_dynamodb_tables"
  policy_arn = "${aws_iam_policy.read-write-to-ddb.arn}"
  roles      = ["${aws_iam_role.iam_for_lambda.name}"]
}

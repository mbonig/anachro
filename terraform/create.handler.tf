
resource "aws_lambda_function" "create_event" {
  function_name    = "${var.model_name}-anarcho_create_event"
  handler          = "create.handler"
  filename         = "${data.archive_file.handlers_zip.output_path}"
  source_code_hash = "${data.archive_file.handlers_zip.output_md5}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  runtime          = "nodejs8.10"
  publish          = true
  timeout          = 300

  environment {
    variables {
      EVENT_TABLE_NAME = "${aws_dynamodb_table.events.name}"
      HASH_KEY    = "${aws_dynamodb_table.events.hash_key}"
    }
  }
}

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
      EVENT_TABLE__NAME     = "${aws_dynamodb_table.events.name}"
      EVENT_TABLE__HASH_KEY = "${aws_dynamodb_table.events.hash_key}"
      MODEL_TABLE__NAME     = "${aws_dynamodb_table.model.name}"
      MODEL_TABLE__HASH_KEY = "${aws_dynamodb_table.model.hash_key}"
      NAMESPACE             = "default"
    }
  }
}

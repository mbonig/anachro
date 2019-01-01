resource "aws_lambda_function" "model_updates" {
  function_name    = "${var.model_name}-anarcho_model_updates"
  handler          = "model_updates.handler"
  filename         = "${data.archive_file.handlers_zip.output_path}"
  source_code_hash = "${data.archive_file.handlers_zip.output_md5}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  runtime          = "nodejs8.10"
  publish          = true
  timeout          = 300

  environment {
    variables {
      TABLE_NAME = "${var.model_name}Connections"
    }
  }
}

resource "aws_lambda_event_source_mapping" "process_model_updates" {
  batch_size        = 100
  event_source_arn  = "${aws_dynamodb_table.model.stream_arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.model_updates.arn}"
  starting_position = "LATEST"
}

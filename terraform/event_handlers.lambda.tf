resource "aws_lambda_function" "event_handlers" {
  function_name    = "${var.model_name}-anarcho_event_handlers"
  handler          = "event_handlers.handler"
  filename         = "${data.archive_file.handlers_zip.output_path}"
  source_code_hash = "${data.archive_file.handlers_zip.output_md5}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  runtime          = "nodejs8.10"
  publish          = true
  timeout          = 300

  environment {
    variables {
      EVENT_TABLE_NAME      = "${aws_dynamodb_table.events.name}"
      EVENT_TABLE__HASH_KEY = "${aws_dynamodb_table.events.hash_key}"
      MODEL_TABLE_NAME      = "${aws_dynamodb_table.model.name}"
      MODEL_TABLE__HASH_KEY = "${aws_dynamodb_table.model.hash_key}"
      NAMESPACE             = "default"
    }
  }
}

resource "aws_lambda_event_source_mapping" "process_events_stream" {
  batch_size        = 100
  event_source_arn  = "${aws_dynamodb_table.events.stream_arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.event_handlers.arn}"
  starting_position = "LATEST"
}

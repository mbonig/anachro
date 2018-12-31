output "events_table__name" {
  value = "${aws_dynamodb_table.events.name}"
}

output "events_table__hash_key" {
  value = "${aws_dynamodb_table.events.hash_key}"
}

output "iam_for_lambda__arn" {
  value = "${aws_iam_role.iam_for_lambda.arn}"
}

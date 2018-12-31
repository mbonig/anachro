resource "aws_dynamodb_table" "events" {
  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  hash_key     = "id"
  range_key    = "timestamp"
  name         = "${var.model_name}_events"
  billing_mode = "PAY_PER_REQUEST"

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}

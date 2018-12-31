resource "aws_dynamodb_table" "model" {
  attribute {
    name = "id"
    type = "S"
  }

  hash_key     = "id"
  name         = "${var.model_name}s"
  billing_mode = "PAY_PER_REQUEST"

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}

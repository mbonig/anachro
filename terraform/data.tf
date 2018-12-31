data "archive_file" "handlers_zip" {
  type        = "zip"
  output_path = "${path.module}/files/handlers.zip"
  source_dir  = "${path.module}/../src/handlers"
}

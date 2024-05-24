resource "aws_s3_object" "main" {
  count  = length(var.folder_names)
  bucket = aws_s3_bucket.bucket.id
  key    = "${var.folder_names[count.index]}/.keep"

  server_side_encryption = "aws:kms"
}

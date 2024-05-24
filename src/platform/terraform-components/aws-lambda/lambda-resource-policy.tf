# Allow Any S3 Bucket to invoke the Lambda Function
# Specifying a specific S3 source_arn can create cyclic dependencies.
# E.g., S3 bucket creation depends on Lambda function creation 
# (specifying as an S3 notification event trigger) and vice versa.
resource "aws_lambda_permission" "allow_s3_buckets" {
  statement_id   = "AllowExecutionFromS3Buckets"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.function.arn
  principal      = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.active.account_id
  source_arn     = ""
}

output "pipeline_name" {
  description = "CodePipeline name"
  value       = var.github_repo != "" ? aws_codepipeline.this[0].name : null
}

output "artifact_bucket_name" {
  description = "Artifact S3 bucket name"
  value       = aws_s3_bucket.artifacts.id
}


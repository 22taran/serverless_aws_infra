# S3 Bucket for Artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-${var.environment}-artifacts-${random_id.artifact_suffix.hex}"

  tags = var.tags
}

resource "random_id" "artifact_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CodeBuild Project for Frontend
resource "aws_codebuild_project" "frontend" {
  name          = "${var.project_name}-${var.environment}-frontend-build"
  description   = "Build project for frontend"
  build_timeout = 60
  service_role  = var.cicd_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "S3_BUCKET"
      value = var.s3_bucket_name
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = var.cloudfront_distribution_id
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-frontend.yml"
  }

  tags = var.tags
}

# CodeBuild Project for Backend
resource "aws_codebuild_project" "backend" {
  name          = "${var.project_name}-${var.environment}-backend-build"
  description   = "Build project for backend Lambda functions"
  build_timeout = 60
  service_role  = var.cicd_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "LAMBDA_FUNCTIONS"
      value = join(",", [for k, v in var.lambda_functions : v.function_name])
    }

    environment_variable {
      name  = "API_GATEWAY_ID"
      value = var.api_gateway_id
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-backend.yml"
  }

  tags = var.tags
}


# CodePipeline
resource "aws_codepipeline" "this" {
  count    = var.github_repo != "" ? 1 : 0
  name     = "${var.project_name}-${var.environment}-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github[0].arn
        FullRepositoryId = var.github_repo
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "BuildFrontend"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["frontend_build"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.frontend.name
      }
    }
  }

  stage {
    name = "BuildBackend"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["backend_build"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.backend.name
      }
    }
  }

  stage {
    name = "DeployFrontend"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["frontend_build"]
      version         = "1"

      configuration = {
        BucketName = var.s3_bucket_name
        Extract    = "true"
      }
    }
  }


  tags = var.tags
}

# GitHub Connection (CodeStar Connections)
resource "aws_codestarconnections_connection" "github" {
  count         = var.github_repo != "" ? 1 : 0
  name          = "${var.project_name}-${var.environment}-github"
  provider_type = "GitHub"

  tags = var.tags
}


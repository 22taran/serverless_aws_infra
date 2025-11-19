terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-1763523616"
    key            = "serverless-todo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}


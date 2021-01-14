terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
  access_key = "AKIAJTWHUZ5W4P6PSNOA"
  secret_key = "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"
}

resource "aws_instance" "localhost" {
  ami           = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
}
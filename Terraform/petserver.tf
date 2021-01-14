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
  region  = "us-west-1"
  access_key = "AKIAIAZQETEYOFOF6EEQ"
  secret_key = "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"
}

resource "aws_instance" "localhost" {
  ami           = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
}
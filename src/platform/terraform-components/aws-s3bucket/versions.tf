terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.45.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3.0"
    }
  }
  required_version = ">= 0.13"
}

data "aws_region" "active" {}

locals {
  openaq_api_key_file_path = "../../../data/01_raw/openaq-api-key.txt"
  
  tags = {
    Organisation = "DemoOrg"
    Department   = "DataEngineering"
    Environement = "Sandbox"
    Management   = "Terraform"
  }
}

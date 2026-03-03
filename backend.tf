terraform {
  backend "s3" {
    bucket = "backend-bucket-88" # Replace with your actual S3 bucket name
    key    = "terraform.tfstate"
    region = "ap-south-1" # ap-south-1
  }
}


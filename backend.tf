terraform {
  backend "s3" {
    bucket = "backend8836" # Replace with your actual S3 bucket name
    key    = "terraform.tfstate"
    region = "ap-south-1" # ap-south-1
  }
}

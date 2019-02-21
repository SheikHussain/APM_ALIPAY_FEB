variable "aws_access_key" {
default = "AKIAJ6NLCC67KX4LPFQA"
}
variable "aws_secret_key" {
default = "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"
}
variable "AWS_REGION" {
default = "us-east-1"
}
variable "key_name" {
default = "vasu-key"
}
variable "AMIS"{
type = "map"
default = {
us-east-1 = "ami-011b3ccf1bd6db744"
ap-southeast-1 = "ami-76144b0a"
ap-south-1 = "ami-5b673c34"
}
}
variable "AMI"{
type = "map"
default = {
us-east-1 = "ami-0f9cf087c1f27d9b1"
ap-southeast-1 = "ami-76144b0a"
ap-south-1 = "ami-5b673c34"
}
}
variable "ssh_key_private" {
default = "vasu-key.pem"
}

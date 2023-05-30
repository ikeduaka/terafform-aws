variable "region" {
  type    = string
  default = "us-east-1"
}
variable "ami_id" {
  type = map
  default = {
  us-east-1    = "ami-053b0d53c279acc90"
  }
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_public_key_file" {
  type        = string
  description = "$(terraform import aws_key_pair.New-3tier-key New-3tier-key)"
  default     = null
}
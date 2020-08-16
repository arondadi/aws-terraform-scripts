variable "key_name" {
  type        = string
  description = "eu-west-1 key_name"
  default     = "terraform_ubuntu_test"
}

variable "sec_group" {
  type        = string
  description = "Security group for ssh access"
  default     = "ELB-secgroup"
}

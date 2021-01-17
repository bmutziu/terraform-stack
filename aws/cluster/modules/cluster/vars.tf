variable vpc_id {
  description = "VPC ID from which belongs the subnets"
  type        = string
}

variable "private_subnets" {
  type = list(string)
  description = "List of private subnet IDs."
}

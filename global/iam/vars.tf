variable "user_names" {
  description = "Create new IAM users with these names from a list"
  type = "list"
  default = ["Alice", "Bob", "Charles"]
}

variable "give_alice_cloudwatch_full_access" {
  description = "Give user Alice full access to Cloudwatch"
}



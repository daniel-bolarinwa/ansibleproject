variable "vpc_id" {}

variable "subnet_ids" {type = list(string)}

variable "subnet_id1" {}

variable "subnet_id2" {}

variable "target_group" {}

variable "instance_profile" {}

variable "key_name" { default = "admin-key-pair" }

variable "ports" {
    type = list
    default = ["80", "443"]
}

variable "target_group_arn" {}

variable "user_data" {}
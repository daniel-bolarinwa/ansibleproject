variable "key_name" { default = "admin-key-pair" }

variable "ports" {
    type = list
    default = ["80", "443"]
}
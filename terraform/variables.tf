variable "key_name" { default = "admin-key-pair" }

variable "ports" {
  type    = list(any)
  default = ["80", "443"]
}
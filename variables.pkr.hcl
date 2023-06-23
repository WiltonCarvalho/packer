variable "os_username" {
  type    = string
  default = "ubuntu"
  description = "The username to connect with to the newly delpoyed OS"
}
variable "os_password" {
  type    = string
  default = "passw0rd"
  description = "The password for the OS user to be used when connecting to the deployed VM"
}
variable "os_password_encrypted" {
  type    = string
  default = "$6$pWYmwQhcooGSgwQA$yMObeSmpOdLMMDGL9zF6BnGef1Njta23ZuGlBYcGeS808AwWlXBSEbMtHPysS8B7NNRpmmGDyotjuFKFHodQi1"
  description = "The password for the OS user to be used when connecting to the deployed VM"
}

variable "ssh_private_key_file" {
  type    = string
  default = "~/secrets/wilton.pem"
  description = "The ssh private key used when connecting to the deployed VM"
}

variable "vm_name" {
  type    = string
  default = "ubuntu"
  description = "The name of the VM when building"
}

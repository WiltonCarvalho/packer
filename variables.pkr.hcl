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

variable "ssh_public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFOvXax9dNqU2unqd+AZQ+VSe2cZZbGMVRuzIW4Hl6Ji69R0zkWih0vuP2psRA/uWTg1XqFKisCp9Z1XQcBbH2WLhnIWhykeLOHtBdEQqUApKj+BrKnyDmBbCourUwAcuUQSRPeRBOg5hwReviIebwvELmwc8ab1r0X+nbCDwVdohTpwNnxHp5MTO0WADLdP0oDQy2hhVaiParCWdVvgfDauQ2IpgeN6tE5sUvsDyYLaYp/dIhddA/Dwh9sWEFfN7ERMSHJw/A/3GsQ49a8+w6lamgcfNDKK7hE9F5vn95fzhge0jj6Yl8NTXOzoMfpvPo3Q+uCbu+GRMlRAK3hcHP wilton.pem"
  description = "The ssh public key added to the deployed VM"
}

variable "vm_name" {
  type    = string
  default = "ubuntu"
  description = "The name of the VM when building"
}

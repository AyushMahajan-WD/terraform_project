#Resource Group
variable "rg_name" {
  default = "terraform-provisioned-rg"
}

variable "location" {
  default = "Central India"
}

#Networking

variable "vnet_name" {
  default = "terraform-vnet"
}

variable "address_space" {
  default = { vnet_as = ["10.10.0.0/16"],
    subnet_1 = ["10.10.1.0/24"],
  subnet_2 = ["10.10.2.0/24"] }
}

variable "subnet_name" {
  type    = list(string)
  default = ["terraform-pub-subnet1", "terraform-pvt-subnet2"]
}


variable "lb_name" {
  default = "terraform-pub-lb"
}

variable "linux_vm_ssh_key_name" {
  default = "linux-vm-ssh-key"
}


variable "linux_vm_pvt_ssh_key_name" {
  default = "linux-vm-pvt-ssh-key"
}

variable "jumpserver_linux_vm_name" {
  default = "jumpserver-linux-vm"
}

variable "terraform_pvt_subnet_nsg_name" {
  default = "terraform-pvt-subnet-nsg"

}

variable "jumpserver_nsg_name" {
  default = "jumpserver-nsg"
}

variable "key_vault_keeper" {
  default = "keepit"
}
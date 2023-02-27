locals {
  common_tags = {
    env = var.env
    projects = "roboshop"
    business_unit = "ecommerce"
    owner = "ecommerce-robot"
  }

  all_tags = [
    { key = "env", value = var.env },
    { key = "projects", value = "roboshop" },
    { key = "business_unit", value = "ecommerce" },
    { key = "owner", value = "ecommerce-robot" },
    { key = "name", value = "${var.env}-${var.component}"}
  ]

}
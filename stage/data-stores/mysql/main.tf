terraform  {
  backend "s3" {
    bucket = "terraform-neilrichards-up-and-run"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "mysql" {
  source = "git@github.com:nedster1980/terraformawsmodules.git//data-stores/mysql?ref=v0.0.2"

  db_name = "mysqlstage"
  //Ignore this passing in password in plain text for now
  db_password = "password123"

}

//Added to proxy the values into the tfstate file for access by the webserver-cluster module
output "address" {
  value = "${module.mysql.address}"
}

output "port" {
  value = "${module.mysql.port}"
}




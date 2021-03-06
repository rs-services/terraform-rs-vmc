variable "refresh_token" {
  type = "string"
}

provider "vmc" {
  refresh_token = var.refresh_token
}

data "vmc_org" "my_org" {
  id = "0f599344-e490-43df-8099-d5e9987be36c"
}

data "vmc_connected_accounts" "my_accounts" {
  org_id = data.vmc_org.my_org.id
}

data "vmc_customer_subnets" "my_subnets" {
  org_id               = data.vmc_org.my_org.id
  connected_account_id = data.vmc_connected_accounts.my_accounts.ids[0]
  region               = var.sddc_region
}

resource "vmc_sddc" "sddc_1" {
  org_id = data.vmc_org.my_org.id

  sddc_name           = "rstest"
  vpc_cidr            = var.vpc_cidr
  num_host            = 1
  sddc_type           = "1NODE"
  provider_type       = "AWS"

  region              = data.vmc_customer_subnets.my_subnets.region
  vxlan_subnet        = var.vxlan_subnet
  delay_account_link  = false
  skip_creating_vxlan = false
  sso_domain          = "vmc.local"

  deployment_type = "SingleAZ"

  account_link_sddc_config {
    customer_subnet_ids  = [data.vmc_customer_subnets.my_subnets.ids[0]]
    connected_account_id = data.vmc_connected_accounts.my_accounts.ids[0]
  }
  timeouts {
    create = "300m"
    update = "300m"
    delete = "180m"
  }
}

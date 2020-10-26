resource "ibm_is_vpc" "iac_iks_vpc_1" {
  name = "${var.project_name}-${var.environment}-vpc"
  resource_group = data.ibm_resource_group.group.id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "vpc_address_prefix" {
  count                     = local.max_size
  name                      = "${var.project_name}-${var.environment}-range-${format("%02s", count.index)}"
  zone                      = var.vpc_zone_names[count.index]
  vpc                       = ibm_is_vpc.iac_iks_vpc_1.id
  cidr                      = "172.26.${format("%01s", count.index)}.0/24"
}

resource "ibm_is_subnet" "iac_iks_subnet" {
  count                    = local.max_size
  name                     = "${var.project_name}-${var.environment}-subnet-${format("%02s", count.index)}"
  zone                     = var.vpc_zone_names[count.index]
  vpc                      = ibm_is_vpc.iac_iks_vpc_1.id
  ipv4_cidr_block          = "172.26.${format("%01s", count.index)}.0/26"
  # total_ipv4_address_count = 64
  resource_group           = data.ibm_resource_group.group.id
  public_gateway           = ibm_is_public_gateway.iac_iks_gateway[count.index].id
  
  depends_on  = [ibm_is_vpc_address_prefix.vpc_address_prefix]
}

resource "ibm_is_vpc" "iac_iks_vpc_2" {
  name = "${var.project_name}-${var.environment}-vpc"
  resource_group = data.ibm_resource_group.group.id
  address_prefix_management = "manual"
}

resource "ibm_is_security_group_rule" "iac_iks_security_group_rule_tcp_k8s" {
  count     = local.max_size
  group     = ibm_is_vpc.iac_iks_vpc_1.default_security_group
  direction = "inbound"
  remote    = ibm_is_subnet.iac_iks_subnet[count.index].ipv4_cidr_block

  tcp {
    port_min = 30000
    port_max = 32767
  }

   }
resource "ibm_tg_gateway" "new_tg_gw"{
  name      = "front-office-tg"
  location  = "eu-de"
  global    =  true
  resource_group="6664a071c0b546deb4703269b54a5d9a"
}

resource "ibm_is_public_gateway" "iac_iks_gateway" {
    name  = "${var.project_name}-${var.environment}-gateway-${format("%02s", count.index)}"
    vpc   = ibm_is_vpc.iac_iks_vpc_1.id
    zone  = var.vpc_zone_names[count.index]
    count = local.max_size

    //User can configure timeouts
    timeouts {
        create = "90m"
    }
}

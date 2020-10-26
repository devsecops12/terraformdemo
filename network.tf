resource "ibm_is_vpc" "iac_iks_vpc_1" {
  name = "${var.project_name}-${var.environment}-vpc"
  resource_group = data.ibm_resource_group.group.id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc" "iac_iks_vpc_2" {
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
  
}

module "management_resources" {
  source = "./modules/management_resources"

  count = local.management_resources_enabled ? 1 : 0

  enable_telemetry             = var.enable_telemetry
  management_resource_settings = module.config.management_resource_settings
  tags                         = module.config.tags

  providers = {
    azurerm = azurerm.management
  }
}

module "management_groups" {
  source = "./modules/management_groups"

  count = local.management_groups_enabled ? 1 : 0

  enable_telemetry          = var.enable_telemetry
  management_group_settings = module.config.management_group_settings
  dependencies              = local.management_group_dependencies
}

moved {
  from = module.management_groups
  to   = module.management_groups[0]
}

moved {
  from = module.management_resources
  to   = module.management_resources[0]
}

locals {
  root_management_group_name = yamldecode(file("${path.root}/lib/architecture_definitions/alz.alz_architecture_definition.yaml")).management_groups[0].id

  # root_management_group_name = jsondecode(file("${path.root}/lib/architecture_definitions/alz.alz_architecture_definition.json")).management_groups[0].id
}

module "amba" {
  source  = "Azure/avm-ptn-monitoring-amba-alz/azurerm"
  version = "0.1.1"
  providers = {
    azurerm = azurerm.management
  }
  location                            = var.starter_locations[0]
  root_management_group_name          = local.root_management_group_name
  resource_group_name                 = module.config.custom_replacements.amba_resource_group_name
  user_assigned_managed_identity_name = module.config.custom_replacements.amba_user_assigned_managed_identity_name
}

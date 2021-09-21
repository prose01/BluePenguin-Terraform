# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used 
terraform {
  backend "azurerm" {
  }
}

# Configure the Azure provider
provider "azurerm" {
    skip_provider_registration = true
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
    features {}
}

# Create resource group
resource "azurerm_resource_group" "bluePenguin-group" {
    name     = "BluePenguin-${var.sourceBranchName}"
    location = "${var.location}"

    tags = {
        BluePenguin = "${var.sourceBranchName}"
    }
}

# Create app service plan
resource "azurerm_app_service_plan" "bluePenguin-plan" {
    name                = "BluePenguin-AppServicePlan-${var.sourceBranchName}"
    location            = azurerm_resource_group.bluePenguin-group.location
    resource_group_name = azurerm_resource_group.bluePenguin-group.name
    kind                = "Linux"
    reserved            = true
    
    sku {
        tier = "Standard"
        size = "S1"
    }

    tags = {
        BluePenguin = azurerm_resource_group.bluePenguin-group.tags.BluePenguin
    }
}

# Create app service
resource "azurerm_app_service" "bluePenguin" {
    name                = "BluePenguin-${var.sourceBranchName}"
    location            = azurerm_resource_group.bluePenguin-group.location
    resource_group_name = azurerm_resource_group.bluePenguin-group.name
    app_service_plan_id = azurerm_app_service_plan.bluePenguin-plan.id

    site_config {
        linux_fx_version = "NODE|14-lts"
        app_command_line = "pm2 serve /home/site/wwwroot --no-daemon --spa"
        always_on = "true"
        ftps_state = "FtpsOnly"
        http2_enabled = "true"
        use_32_bit_worker_process = "false"
        min_tls_version = "1.2"
    }

    app_settings = {
        "avalonUrl" = "https://avalon-dev.azurewebsites.net/"
        "artemisUrl" = "https://artemis-87-dev.azurewebsites.net/"
        "junoUrl" = "https://juno-dev.azurewebsites.net/"
        "maxTags" = "10"
        "maxPhotos" = "5"
        "fileSizeLimit" = "2097152"
        "imageMaxWidth" = "1080"
        "imageMaxHeight" = "1350"
        "defaultAge" = "16"
        "WEBSITE_NODE_DEFAULT_VERSION" = "~14"
        # XDT_MicrosoftApplicationInsights_NodeJS         = "1"
    }

    https_only = "true"

    identity {
        type = "SystemAssigned"
    }

    logs {
        http_logs {
            file_system {
                retention_in_mb = 30 # in Megabytes
                retention_in_days = 7 # in days
            }
        }
    }

    tags = {       
        BluePenguin = azurerm_resource_group.bluePenguin-group.tags.BluePenguin
    }
}

# Create app service slot
resource "azurerm_app_service_slot" "bluePenguin-slot" {
    name                = "BluePenguin-staging-${var.sourceBranchName}"
    location            = azurerm_resource_group.bluePenguin-group.location
    resource_group_name = azurerm_resource_group.bluePenguin-group.name
    app_service_plan_id = azurerm_app_service_plan.bluePenguin-plan.id
    app_service_name    = azurerm_app_service.bluePenguin.name

    site_config {
        linux_fx_version = "NODE|14-lts"
        app_command_line = "pm2 serve /home/site/wwwroot --no-daemon --spa"
        always_on = "true"
        ftps_state = "FtpsOnly"
        http2_enabled = "true"
        use_32_bit_worker_process = "false"
        min_tls_version = "1.2"
    }

    app_settings = {
        "avalonUrl" = "https://avalon-dev.azurewebsites.net/"
        "artemisUrl" = "https://artemis-87-dev.azurewebsites.net/"
        "junoUrl" = "https://juno-dev.azurewebsites.net/"
        "maxTags" = "10"
        "maxPhotos" = "5"
        "fileSizeLimit" = "2097152"
        "imageMaxWidth" = "1080"
        "imageMaxHeight" = "1350"
        "defaultAge" = "16"
        "WEBSITE_NODE_DEFAULT_VERSION" = "~14"
        # XDT_MicrosoftApplicationInsights_NodeJS         = "1"
    }

    https_only = "true"

    identity {
        type = "SystemAssigned"
    }

    logs {
        http_logs {
            file_system {
                retention_in_mb = 30 # in Megabytes
                retention_in_days = 7 # in days
            }
        }
    }

    tags = {       
        BluePenguin = azurerm_resource_group.bluePenguin-group.tags.BluePenguin
    }
}

# # Create application insights. Obs! Not working for Linux!
# resource "azurerm_application_insights" "bluePenguin-insights" {
#  name                = "bluePenguin-insights"
#  location            = azurerm_resource_group.bluePenguin-group.location
#  resource_group_name = azurerm_resource_group.bluePenguin-group.name
#  application_type    = "web"
#  disable_ip_masking  = false
#  retention_in_days   = 30

#  tags = {       
#         BluePenguin = azurerm_resource_group.bluePenguin-group.tags.BluePenguin
#     }
# }
// Creates an Azure Container Registry
@description('Name of the Azure Container Registry')
param name string

@description('Primary location for the Container Registry')
param location string = resourceGroup().location

@description('Enable admin user for the Container Registry')
param acrAdminUserEnabled bool = true

@description('SKU tier for the Container Registry')
param sku string = 'Basic'

@description('Tags to be applied to the Container Registry')
param tags object = {}

// Create the Azure Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
  }
}

// Outputs
@description('The resource ID of the Container Registry')
output id string = containerRegistry.id

@description('The name of the Container Registry')
output name string = containerRegistry.name

@description('The login server URL of the Container Registry')
output loginServer string = containerRegistry.properties.loginServer

@description('The admin username of the Container Registry')
output adminUsername string = acrAdminUserEnabled ? containerRegistry.listCredentials().username : ''

@description('The admin password of the Container Registry')
@secure()
output adminPassword string = acrAdminUserEnabled ? containerRegistry.listCredentials().passwords[0].value : '' 

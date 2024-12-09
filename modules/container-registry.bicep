@description('The name of the Azure Container Registry')
param name string

@description('The location for the Azure Container Registry')
param location string

@description('Enable admin user for the Azure Container Registry')
param acrAdminUserEnabled bool = true

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic' // You can change this to 'Standard' or 'Premium' as needed
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

output loginServer string = acr.properties.loginServer

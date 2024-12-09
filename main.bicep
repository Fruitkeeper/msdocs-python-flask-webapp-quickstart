@description('The location for all resources')
param location string = resourceGroup().location

@description('The name prefix for all resources')
param namePrefix string

// Container Registry
var acrName = '${namePrefix}acr'
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
  }
}

// App Service Plan
var appServicePlanName = '${namePrefix}-asp'
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: appServicePlanName
    location: location
  }
}

// Web App
var webAppName = '${namePrefix}-app'
module webApp 'modules/app-service.bicep' = {
  name: 'webApp'
  params: {
    name: webAppName
    location: location
    appServicePlanName: appServicePlan.outputs.name
    containerRegistryName: acrName
    containerRegistryImageName: 'your-image-name'
    containerRegistryImageVersion: 'latest'
  }
  dependsOn: [
    containerRegistry
    appServicePlan
  ]
}

// Outputs
output webAppHostName string = webApp.outputs.defaultHostName
output acrLoginServer string = containerRegistry.outputs.loginServer 

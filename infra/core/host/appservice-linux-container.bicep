// Creates an Azure Web App for Linux containers
@description('Name of the Azure Web App')
param name string

@description('Primary location for the Web App')
param location string = resourceGroup().location

@description('Kind of the Web App')
param kind string = 'app'

@description('Resource ID of the App Service Plan')
param serverFarmResourceId string

@description('Site configuration for the Web App')
param siteConfig object

@description('App settings key-value pairs')
param appSettingsKeyValuePairs object = {}

@description('Tags to be applied to the Web App')
param tags object = {}

// Convert appSettingsKeyValuePairs object to array format expected by Azure
var appSettingsArray = [for key in items(appSettingsKeyValuePairs): {
  name: key.key
  value: key.value
}]

// Create the Azure Web App for Linux containers
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  kind: kind
  tags: tags
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: union(siteConfig, {
      appSettings: appSettingsArray
    })
    httpsOnly: true
    clientAffinityEnabled: false
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Configure the site config separately to ensure proper deployment
resource webAppConfig 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'web'
  properties: siteConfig
}

// Configure app settings separately to ensure proper deployment
resource webAppAppSettings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'appsettings'
  properties: appSettingsKeyValuePairs
  dependsOn: [
    webAppConfig
  ]
}

// Outputs
@description('The resource ID of the Web App')
output id string = webApp.id

@description('The name of the Web App')
output name string = webApp.name

@description('The default hostname of the Web App')
output defaultHostname string = webApp.properties.defaultHostName

@description('The principal ID of the system assigned identity')
output principalId string = webApp.identity.principalId

@description('The URL of the Web App')
output uri string = 'https://${webApp.properties.defaultHostName}' 

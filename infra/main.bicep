targetScope = 'subscription'

// The main bicep module to provision Azure resources for Flask containerized application.
// This file orchestrates the deployment of Azure Container Registry, App Service Plan, and Web App.

@minLength(1)
@maxLength(64)
@description('Name of the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Optional parameters to override the default azd resource naming conventions
param resourceGroupName string = ''
param containerRegistryName string = ''
param appServicePlanName string = ''
param webAppName string = ''

// Container image parameters
@description('Name of the container image')
param containerRegistryImageName string = 'flask-app'

@description('Version/tag of the container image')
param containerRegistryImageVersion string = 'latest'

var abbrs = loadJsonContent('./abbreviations.json')

// Tags that should be applied to all resources
var tags = {
  'azd-env-name': environmentName
  'project': 'flask-webapp'
  'environment': environmentName
}

// Generate a unique token to be used in naming resources
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Azure Container Registry
module containerRegistry './core/host/containerregistry.bicep' = {
  name: 'containerRegistry'
  scope: rg
  params: {
    name: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    acrAdminUserEnabled: true
    tags: union(tags, { 'azd-service-name': 'container-registry' })
  }
}

// App Service Plan for Linux
module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appServicePlan'
  scope: rg
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    kind: 'Linux'
    reserved: true
    tags: union(tags, { 'azd-service-name': 'app-service-plan' })
  }
}

// Web App for Linux containers
module webApp './core/host/appservice-linux-container.bicep' = {
  name: 'webApp'
  scope: rg
  params: {
    name: !empty(webAppName) ? webAppName : '${abbrs.webSitesAppService}${resourceToken}'
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.outputs.loginServer}/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      use32BitWorkerProcess: false
      webSocketsEnabled: false
      managedPipelineMode: 'Integrated'
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: true
        }
      ]
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
      DOCKER_REGISTRY_SERVER_URL: containerRegistry.outputs.loginServer
      DOCKER_REGISTRY_SERVER_USERNAME: containerRegistry.outputs.adminUsername
      DOCKER_REGISTRY_SERVER_PASSWORD: containerRegistry.outputs.adminPassword
      WEBSITES_PORT: '5000'
      FLASK_ENV: 'production'
      PYTHONUNBUFFERED: '1'
    }
    tags: union(tags, { 'azd-service-name': 'web-app' })
  }
  dependsOn: [
    containerRegistry
    appServicePlan
  ]
}

// Outputs for use in other deployments or local development
@description('Primary location for all resources')
output AZURE_LOCATION string = location

@description('The tenant ID')
output AZURE_TENANT_ID string = tenant().tenantId

@description('The resource group name')
output AZURE_RESOURCE_GROUP string = rg.name

@description('Container Registry name')
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name

@description('Container Registry login server')
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer

@description('App Service Plan name')
output AZURE_APP_SERVICE_PLAN_NAME string = appServicePlan.outputs.name

@description('Web App name')
output AZURE_WEB_APP_NAME string = webApp.outputs.name

@description('Web App URL')
output AZURE_WEB_APP_URI string = webApp.outputs.uri

@description('Web App default hostname')
output AZURE_WEB_APP_HOSTNAME string = webApp.outputs.defaultHostname


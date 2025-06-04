# Infrastructure Documentation

This document describes the Azure infrastructure setup for the Flask containerized application using BICEP templates.

## 🏗️ Architecture Overview

The infrastructure consists of three main Azure services:

1. **Azure Container Registry (ACR)** - Stores the Docker images
2. **Azure App Service Plan** - Linux-based hosting plan
3. **Azure Web App** - Linux container hosting the Flask application

## 📁 File Structure

```
infra/
├── main.bicep                              # Main orchestrator template
├── main.parameters.json                    # Parameters file
├── abbreviations.json                      # Resource naming abbreviations
└── core/
    └── host/
        ├── containerregistry.bicep          # Container Registry module
        ├── appserviceplan.bicep            # App Service Plan module
        └── appservice-linux-container.bicep # Web App module

.github/workflows/
├── deploy-infrastructure.yml              # Infrastructure deployment workflow
└── build-and-deploy.yml                  # Application build and deployment workflow
```

## 🎯 Resources Deployed

### Azure Container Registry
- **Purpose**: Store and manage Docker container images
- **SKU**: Basic tier
- **Features**: 
  - Admin user enabled
  - Basic policies configured
  - Public network access enabled

### Azure App Service Plan
- **Purpose**: Provide compute resources for the web application
- **SKU**: B1 (Basic tier)
- **Configuration**:
  - Linux-based
  - 1 instance capacity
  - Reserved instances enabled

### Azure Web App
- **Purpose**: Host the containerized Flask application
- **Configuration**:
  - Linux container support
  - Docker image deployment
  - HTTPS enforcement
  - System-assigned managed identity
  - Custom app settings for Flask/Docker

## 🔧 Configuration Parameters

### Main Parameters

| Parameter | Description | Default Value | Required |
|-----------|-------------|---------------|----------|
| `environmentName` | Environment identifier | - | ✅ |
| `location` | Azure region | - | ✅ |
| `resourceGroupName` | Target resource group | `aguadamillas_students_1` | ❌ |
| `containerRegistryImageName` | Docker image name | `flask-app` | ❌ |
| `containerRegistryImageVersion` | Image tag/version | `latest` | ❌ |

### App Settings

The Web App is configured with the following environment variables:

| Setting | Value | Purpose |
|---------|-------|---------|
| `WEBSITES_ENABLE_APP_SERVICE_STORAGE` | `false` | Disable App Service storage |
| `DOCKER_REGISTRY_SERVER_URL` | ACR login server | Registry authentication |
| `DOCKER_REGISTRY_SERVER_USERNAME` | ACR admin username | Registry authentication |
| `DOCKER_REGISTRY_SERVER_PASSWORD` | ACR admin password | Registry authentication |
| `WEBSITES_PORT` | `5000` | Application port |
| `FLASK_ENV` | `production` | Flask environment |
| `PYTHONUNBUFFERED` | `1` | Python output buffering |

## 🚀 Deployment Process

### Prerequisites

1. **Azure Service Principal** with the following permissions:
   - Contributor access to the subscription or resource group
   - Required for GitHub Actions authentication

2. **GitHub Secrets** configured:
   - `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
   - `AZURE_TENANT_ID`: Your Azure tenant ID
   - `AZURE_CLIENT_ID`: Service principal client ID
   - `AZURE_CLIENT_SECRET`: Service principal client secret

### Step 1: Infrastructure Deployment

The infrastructure deployment is triggered by:
- Push to `main` or `practical` branches (changes in `infra/**`)
- Manual workflow dispatch
- Pull requests (validation only)

```bash
# Manual deployment using Azure CLI
az deployment sub create \
  --location eastus \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.parameters.json \
  --parameters environmentName=dev-001 \
  --parameters location=eastus
```

### Step 2: Application Deployment

The application deployment is triggered by:
- Push to `main` or `practical` branches (application code changes)
- Manual workflow dispatch

The workflow:
1. Builds the Docker image
2. Pushes to Azure Container Registry
3. Deploys to Azure Web App
4. Validates the deployment

## 🔄 Workflows

### Infrastructure Deployment Workflow

**File**: `.github/workflows/deploy-infrastructure.yml`

**Jobs**:
1. **Validate**: Validates BICEP templates
2. **Deploy**: Deploys infrastructure resources
3. **Cleanup**: Provides cleanup instructions on failure

**Outputs**:
- Resource group name
- Container registry details
- Web app information

### Application Deployment Workflow

**File**: `.github/workflows/build-and-deploy.yml`

**Jobs**:
1. **Build**: Builds and pushes Docker image
2. **Deploy**: Deploys to Azure Web App

**Features**:
- Docker layer caching
- Automatic health checks
- Deployment validation

## 🌐 Resource Naming Convention

Resources follow Azure naming conventions using abbreviations:

| Resource Type | Abbreviation | Example |
|---------------|--------------|---------|
| Resource Group | `rg-` | `rg-dev-001` |
| Container Registry | `cr` | `crdev001` |
| App Service Plan | `plan-` | `plan-dev001` |
| Web App | `app-` | `app-dev001` |

## 🔒 Security Features

### Container Registry
- Admin user enabled for GitHub Actions deployment
- Network access from Azure services
- Basic security policies

### Web App
- HTTPS enforcement
- System-assigned managed identity
- Minimum TLS version 1.2
- Disabled FTP access
- Modern authentication only

### App Service Plan
- Reserved instances for consistent performance
- Linux-based for container compatibility

## 📊 Monitoring and Diagnostics

### Built-in Monitoring
- Application Insights (optional)
- App Service logs
- Container logs
- Health checks via Docker

### Health Checks
- HTTP endpoint monitoring
- Automatic restart on failures
- Custom health check endpoints

## 🛠️ Troubleshooting

### Common Issues

1. **Container Registry Authentication**
   ```bash
   # Check ACR credentials
   az acr credential show --name <registry-name>
   
   # Test registry access
   docker login <registry>.azurecr.io
   ```

2. **Web App Container Issues**
   ```bash
   # Check app logs
   az webapp log tail --name <app-name> --resource-group <rg-name>
   
   # Check container settings
   az webapp config show --name <app-name> --resource-group <rg-name>
   ```

3. **Deployment Failures**
   ```bash
   # Check deployment status
   az deployment group show --name <deployment-name> --resource-group <rg-name>
   
   # View deployment operations
   az deployment operation group list --name <deployment-name> --resource-group <rg-name>
   ```

### Debug Commands

```bash
# List all resources in the resource group
az resource list --resource-group aguadamillas_students_1 --output table

# Check Web App configuration
az webapp show --name <app-name> --resource-group aguadamillas_students_1

# View container logs
az webapp log download --name <app-name> --resource-group aguadamillas_students_1

# Test connectivity
curl -I https://<app-name>.azurewebsites.net
```

## 🧹 Cleanup

To remove all deployed resources:

```bash
# Delete the entire resource group (if dedicated to this project)
az group delete --name aguadamillas_students_1 --yes --no-wait

# Or delete individual resources
az webapp delete --name <app-name> --resource-group aguadamillas_students_1
az appservice plan delete --name <plan-name> --resource-group aguadamillas_students_1
az acr delete --name <registry-name> --resource-group aguadamillas_students_1
```

## 📈 Scaling and Performance

### App Service Plan Scaling
- Manual scaling: Increase instance count
- Auto-scaling: Configure based on metrics
- Scale up: Move to higher SKU tiers

### Container Optimization
- Multi-stage Docker builds
- Layer caching optimization
- Minimal base images

### Performance Monitoring
- Application Insights integration
- Custom metrics and alerts
- Performance counters

## 🔄 CI/CD Integration

The infrastructure supports continuous integration and deployment:

1. **Infrastructure as Code**: All infrastructure defined in BICEP
2. **Automated Validation**: Template validation on pull requests
3. **Environment Separation**: Support for dev/staging/prod environments
4. **Rollback Capability**: Version-controlled infrastructure changes
5. **Security Scanning**: Automated security validation

For more details on the application configuration, see the [Gunicorn Configuration Guide](./GUNICORN_CONFIG.md). 
# 🚀 Quick Deployment Guide

This guide provides step-by-step instructions to deploy your Flask application to Azure using the BICEP infrastructure.

## 📋 Prerequisites Checklist

Before deploying, ensure you have:

- [ ] Azure subscription with appropriate permissions
- [ ] Azure Service Principal created
- [ ] GitHub repository with the code
- [ ] GitHub Secrets configured

## 🛠️ Azure Service Principal Setup

1. **Create Service Principal**:
```bash
az ad sp create-for-rbac --name "flask-app-deployment" --role contributor \
  --scopes /subscriptions/{subscription-id} --sdk-auth
```

2. **Note down the output** for GitHub Secrets:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "your-client-secret",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

## 🔑 GitHub Secrets Configuration

In your GitHub repository, go to **Settings > Secrets and variables > Actions** and add:

| Secret Name | Description | Value |
|-------------|-------------|--------|
| `AZURE_CREDENTIALS` | Complete JSON output from service principal creation | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` |
| `AZURE_CLIENT_ID` | Service principal client ID (for Docker registry) | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_CLIENT_SECRET` | Service principal client secret (for Docker registry) | `your-client-secret` |

**Important**: Make sure the `AZURE_CREDENTIALS` JSON is properly formatted without any trailing commas.

## 📁 Files Created/Modified

### Infrastructure Files
```
infra/
├── main.bicep                               ✅ Created - Main orchestrator
├── main.parameters.json                     ✅ Updated - Added parameters
├── abbreviations.json                       ✅ Existing - Resource naming
└── core/host/
    ├── containerregistry.bicep              ✅ Created - ACR module
    ├── appserviceplan.bicep                 ✅ Existing - App Service Plan
    └── appservice-linux-container.bicep     ✅ Created - Web App module
```

### Application Files
```
├── Dockerfile                               ✅ Created - Docker configuration
├── .dockerignore                           ✅ Created - Docker ignore rules
├── requirements.txt                        ✅ Updated - Flask 3.1.1
├── gunicorn.conf.py                        ✅ Created - Gunicorn config
├── run.sh                                  ✅ Created - Startup script
├── GUNICORN_CONFIG.md                      ✅ Created - Gunicorn docs
└── INFRASTRUCTURE.md                       ✅ Created - Infrastructure docs
```

### CI/CD Files
```
.github/workflows/
└── deploy.yml                              ✅ Created - Unified deployment workflow
```

## 🎯 Deployment Steps

### Step 1: Deploy via Single Workflow

The unified workflow handles both infrastructure and application deployment:

1. **Push to trigger deployment**:
```bash
git add .
git commit -m "Add BICEP infrastructure and Docker configuration"
git push origin main
```

2. **Or manually trigger** via GitHub Actions:
   - Go to **Actions** tab in GitHub
   - Select **Deploy Flask Application** workflow
   - Click **Run workflow**
   - Choose options:
     - **Environment**: dev/staging/prod
     - **Skip infrastructure deployment**: Leave unchecked for first deployment

### Step 2: Workflow Features

The single workflow provides:

- **Infrastructure Deployment**: Creates all Azure resources
- **Application Build**: Builds and pushes Docker image
- **Application Deployment**: Deploys to Azure Web App
- **Health Checks**: Validates deployment success
- **Skip Options**: Can skip infrastructure for app-only deployments

### Step 3: Verify Deployment

The workflow will create:
- ✅ **Resource Group**: `aguadamillas_students_1`
- ✅ **Container Registry**: `cr{uniqueToken}`
- ✅ **App Service Plan**: `plan-{uniqueToken}`
- ✅ **Web App**: `app-{uniqueToken}`

### Step 4: Access Your Application

After successful deployment:
- **Web App URL**: `https://app-{uniqueToken}.azurewebsites.net`
- **Health Check**: Available via the URL above
- **Logs**: Available in Azure Portal → Web App → Log stream

## 🔍 Verification Commands

```bash
# List all resources in the resource group
az resource list --resource-group aguadamillas_students_1 --output table

# Check Web App status
az webapp show --name <app-name> --resource-group aguadamillas_students_1 --query "state"

# View logs
az webapp log tail --name <app-name> --resource-group aguadamillas_students_1

# Test the application
curl https://<app-name>.azurewebsites.net
```

## 🎉 Success Indicators

You'll know the deployment is successful when:

1. ✅ **Infrastructure job** completes without errors
2. ✅ **Build and Deploy job** completes without errors
3. ✅ **Web App** responds to HTTP requests
4. ✅ **Container logs** show Gunicorn starting successfully
5. ✅ **Health check** returns 200 OK

## 🚨 Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```
   Error: Login failed with Error: Ensure 'subscription-id' is supplied
   ```
   **Solution**: 
   - Verify `AZURE_CREDENTIALS` secret is correctly formatted JSON
   - Ensure no trailing commas in the JSON
   - Check that the service principal has contributor permissions

2. **Invalid JSON Format**
   ```
   Error: SyntaxError: Expected double-quoted property name in JSON at position 240
   ```
   **Solution**: 
   - Verify `AZURE_CREDENTIALS` JSON format
   - Remove any trailing commas
   - Ensure all property names are double-quoted

3. **Resource Group Not Found**
   - Ensure `aguadamillas_students_1` resource group exists
   - Update `main.parameters.json` if using different resource group

4. **Container Build Failures**
   - Check Dockerfile syntax
   - Verify all required files are present

5. **Application Not Starting**
   - Check Web App logs in Azure Portal
   - Verify Gunicorn configuration
   - Ensure port 5000 is properly exposed

### Fixed Issues

✅ **Azure CLI Action Fixed**: Now using `azure/cli@v2` instead of the invalid `azure/setup-cli@v1`
✅ **Single Workflow**: Simplified from 2 separate workflows to 1 unified workflow
✅ **Service Principal Authentication**: Using proven `creds` method like your working workflow
✅ **Proper Dependencies**: Infrastructure deploys first, then application deployment follows

### Getting Help

1. **Check workflow logs** in GitHub Actions
2. **View Azure Portal** for resource status
3. **Use Azure CLI** for detailed diagnostics
4. **Review documentation**:
   - [Infrastructure Documentation](./INFRASTRUCTURE.md)
   - [Gunicorn Configuration Guide](./GUNICORN_CONFIG.md)

## 🧹 Cleanup

To remove all resources:

```bash
az group delete --name aguadamillas_students_1 --yes --no-wait
```

## 📚 Next Steps

After successful deployment:

1. **Configure custom domain** (optional)
2. **Set up Application Insights** for monitoring
3. **Configure auto-scaling** based on load
4. **Set up backup and disaster recovery**
5. **Implement blue-green deployment** for zero-downtime updates

## 🔄 Deployment Options

### Full Deployment (Default)
- Deploys infrastructure and application
- Use when setting up for the first time

### Application-Only Deployment
- Run workflow manually
- Check "Skip infrastructure deployment"
- Use for application updates only

### Environment-Specific Deployment
- Choose dev/staging/prod environment
- Each gets unique resource names
- Supports parallel environments

## 🔒 Authentication Method

This setup uses **Service Principal + Secret** authentication (same as your working workflow). This is:
- ✅ **Simpler** to set up (no OIDC configuration needed)
- ✅ **Proven** to work with your current setup
- ✅ **Compatible** with your existing secrets

If you want to upgrade to OIDC authentication later for enhanced security, you can follow Azure's OIDC documentation.

---

🎉 **Congratulations!** Your Flask application is now running on Azure with enterprise-grade infrastructure!

For technical details, see [INFRASTRUCTURE.md](./INFRASTRUCTURE.md) and [GUNICORN_CONFIG.md](./GUNICORN_CONFIG.md). 
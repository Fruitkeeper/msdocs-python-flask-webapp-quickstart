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

2. **Note down these values** for GitHub Secrets:
   - `clientId` → `AZURE_CLIENT_ID`
   - `clientSecret` → `AZURE_CLIENT_SECRET`
   - `subscriptionId` → `AZURE_SUBSCRIPTION_ID`
   - `tenantId` → `AZURE_TENANT_ID`

## 🔑 GitHub Secrets Configuration

In your GitHub repository, go to **Settings > Secrets and variables > Actions** and add:

| Secret Name | Description | Value |
|-------------|-------------|--------|
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Your Azure tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_CLIENT_ID` | Service principal client ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_CLIENT_SECRET` | Service principal client secret | `your-client-secret` |

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
├── deploy-infrastructure.yml               ✅ Created - Infrastructure deployment
└── build-and-deploy.yml                   ✅ Created - Application deployment
```

## 🎯 Deployment Steps

### Step 1: Deploy Infrastructure

1. **Push to trigger deployment**:
```bash
git add .
git commit -m "Add BICEP infrastructure and Docker configuration"
git push origin main
```

2. **Or manually trigger** via GitHub Actions:
   - Go to **Actions** tab in GitHub
   - Select **Deploy Infrastructure** workflow
   - Click **Run workflow**
   - Choose environment (dev/staging/prod)

### Step 2: Verify Infrastructure Deployment

The workflow will create:
- ✅ **Resource Group**: `aguadamillas_students_1`
- ✅ **Container Registry**: `cr{uniqueToken}`
- ✅ **App Service Plan**: `plan-{uniqueToken}`
- ✅ **Web App**: `app-{uniqueToken}`

### Step 3: Application Deployment

1. **Automatic deployment**: Application deploys automatically after infrastructure
2. **Manual deployment**: Use **Build and Deploy Application** workflow

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

1. ✅ **Infrastructure workflow** completes without errors
2. ✅ **Build and Deploy workflow** completes without errors
3. ✅ **Web App** responds to HTTP requests
4. ✅ **Container logs** show Gunicorn starting successfully
5. ✅ **Health check** returns 200 OK

## 🚨 Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify GitHub Secrets are correctly set
   - Check Service Principal permissions

2. **Resource Group Not Found**
   - Ensure `aguadamillas_students_1` resource group exists
   - Update `main.parameters.json` if using different resource group

3. **Container Build Failures**
   - Check Dockerfile syntax
   - Verify all required files are present

4. **Application Not Starting**
   - Check Web App logs in Azure Portal
   - Verify Gunicorn configuration
   - Ensure port 5000 is properly exposed

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

---

🎉 **Congratulations!** Your Flask application is now running on Azure with enterprise-grade infrastructure!

For technical details, see [INFRASTRUCTURE.md](./INFRASTRUCTURE.md) and [GUNICORN_CONFIG.md](./GUNICORN_CONFIG.md). 
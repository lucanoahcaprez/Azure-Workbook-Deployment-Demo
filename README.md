# Azure Workbook Deployment Demo

This repository demonstrates how to deploy Azure Workbooks using ARM templates and GitHub Actions CI/CD pipelines.

## 📁 Repository Structure

```
├── demo-workbook-1.json                 # Original workbook JSON export
├── demo-armtemplate-1.json             # ARM template for workbook deployment
├── demo-armtemplate-1.parameters.json  # Parameters file for ARM template
├── .github/workflows/
│   ├── deploy-arm-template.yml         # Main deployment pipeline
│   └── combine-workbook-into-arm.yml   # Utility pipeline (if exists)
└── README.md                           # This file
```

## 🚀 Quick Start

### Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **Service Principal** with the following roles:
   - `Contributor` on the target resource group/subscription
   - `Workbook Contributor` (if using custom roles)

### GitHub Secrets Configuration

Set up the following repository secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AZURE_CLIENT_ID` | Service Principal Application ID | `12345678-1234-1234-1234-123456789012` |
| `AZURE_TENANT_ID` | Azure AD Tenant ID | `87654321-4321-4321-4321-210987654321` |
| `AZURE_SUBSCRIPTION_ID` | Target Azure Subscription ID | `11111111-2222-3333-4444-555555555555` |

## 📋 ARM Template Parameters

The ARM template accepts the following parameters:

| Parameter | Type | Description | Default Value |
|-----------|------|-------------|---------------|
| `workbookDisplayName` | string | Display name for the workbook | `Sample Dashboard WPNinjas 2025` |
| `workbookType` | string | Workbook category | `workbook` |
| `workbookSourceId` | string | Associated resource ID | `azure monitor` |
| `workbookId` | string | Unique workbook identifier | `[newGuid()]` |
| `location` | string | Azure region | `[resourceGroup().location]` |
| `resourceTags` | object | Tags to apply to resources | See parameters file |

## 🔄 Deployment Methods

### Method 1: GitHub Actions (Recommended)

The repository includes an automated CI/CD pipeline that:

1. **Validates** the ARM template on every push/PR
2. **Deploys** to Azure on main branch commits
3. **Tests** the deployment to ensure success

#### Trigger Deployment

- **Automatic**: Push changes to `main` branch
- **Manual**: Use "Run workflow" in GitHub Actions tab

#### Manual Workflow Inputs

- `resourceGroupName`: Target resource group (default: `rg-azure-workbook-demo`)
- `location`: Azure region for deployment

### Method 2: Azure CLI

```bash
# Login to Azure
az login

# Create resource group
az group create \
  --name "rg-azure-workbook-demo" \
  --location "West Europe"

# Deploy ARM template
az deployment group create \
  --resource-group "rg-azure-workbook-demo" \
  --template-file "./demo-armtemplate-1.json" \
  --parameters "@demo-armtemplate-1.parameters.json"
```

### Method 3: Azure PowerShell

```powershell
# Login to Azure
Connect-AzAccount

# Create resource group
New-AzResourceGroup -Name "rg-azure-workbook-demo" -Location "West Europe"

# Deploy ARM template
New-AzResourceGroupDeployment `
  -ResourceGroupName "rg-azure-workbook-demo" `
  -TemplateFile "./demo-armtemplate-1.json" `
  -TemplateParameterFile "./demo-armtemplate-1.parameters.json"
```

## 📊 Workbook Content

The deployed workbook includes:

- **Parameters Section**: Time ranges, subscriptions, Log Analytics workspaces
- **Navigation Tabs**: Multiple dashboard views
- **KPI Tiles**: 
  - Active Intune Devices count
  - Device compliance metrics
  - OS update benchmarks
  - Driver update benchmarks
  - Application installation metrics
- **Data Sources**: 
  - Log Analytics queries (KQL)
  - Microsoft Graph API calls
  - External API integrations

### Key Features

- 🔄 **Dynamic Parameters**: Filters for OS, time ranges, and workspaces
- 📈 **Visual Metrics**: Statistical tiles with color-coded thresholds
- 🔗 **Multiple Data Sources**: Combines logs, Graph API, and external data
- 🎨 **Custom Styling**: Professional dashboard appearance
- 📱 **Responsive Design**: Works across different screen sizes

## 🔧 Customization

### Modifying the Workbook

1. **Edit the source**: Modify `demo-workbook-1.json`
2. **Update ARM template**: The workbook content is embedded in `variables.workbookContent`
3. **Test locally**: Use Azure CLI to validate before committing
4. **Deploy**: Push to main branch or trigger manual deployment

### Adding New Queries

To add new KQL queries to the workbook:

1. Export your workbook from Azure Portal
2. Copy the new query sections
3. Update the ARM template's `workbookContent` variable
4. Test the deployment

### Environment-Specific Deployments

Create different parameter files for different environments:

```
demo-armtemplate-1.dev.parameters.json
demo-armtemplate-1.staging.parameters.json
demo-armtemplate-1.prod.parameters.json
```

## 🔍 Troubleshooting

### Common Issues

1. **Permission Errors**
   - Ensure service principal has adequate permissions
   - Check Azure RBAC assignments

2. **Template Validation Failures**
   - Verify JSON syntax in ARM template
   - Check parameter types and constraints

3. **Workbook Not Visible**
   - Confirm resource group and subscription
   - Check workbook permissions in Azure Portal

### Debugging Steps

1. Check GitHub Actions logs for detailed error messages
2. Validate ARM template locally: `az deployment group validate`
3. Review Azure Activity Log for deployment events
4. Verify service principal permissions

## 📚 Additional Resources

- [Azure Workbooks Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/workbooks-overview)
- [ARM Template Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- [GitHub Actions for Azure](https://github.com/Azure/actions)
- [KQL Query Language Reference](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note**: This is a demonstration repository. Customize the workbook content, queries, and deployment parameters according to your specific requirements.
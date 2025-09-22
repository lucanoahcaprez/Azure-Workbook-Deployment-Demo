# Azure Workbook Deployment Demo

This repository demonstrates how to deploy Azure Workbooks using ARM templates and GitHub Actions CI/CD pipelines.

## 📁 Repository Structure

```
├── demo-workbook-1.json                 # Original workbook JSON export
├── demo-armtemplate-1.json             # ARM template for workbook deployment
├── demo-armtemplate-1.parameters.json  # Parameters file for ARM template
├── combine-workbook.sh                 # Local combination script (Bash)
├── combine-workbook.ps1                # Local combination script (PowerShell)
├── .github/workflows/
│   ├── deploy-arm-template.yml         # Main deployment pipeline
│   └── combine-workbook-into-arm.yml   # Workbook combination pipeline
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

The repository includes two automated CI/CD pipelines:

#### 🔄 Workbook Combination Pipeline
**File**: `.github/workflows/combine-workbook-into-arm.yml`

Automatically combines `demo-workbook-1.json` content into `demo-armtemplate-1.json`:

- **Triggers**: Changes to `demo-workbook-1.yml`, `demo-workbook-1.json`, or manual dispatch
- **Features**: JSON validation, content hashing, PR creation or direct commits
- **Output**: Updated ARM template with embedded workbook content

#### 🚀 Deployment Pipeline  
**File**: `.github/workflows/deploy-arm-template.yml`

Validates and deploys the ARM template to Azure:

1. **Validates** the ARM template on every push/PR
2. **Deploys** to Azure on main branch commits  
3. **Tests** the deployment to ensure success

#### Workflow Sequence
1. Modify `demo-workbook-1.json` with your workbook changes
2. Push to main branch → Combination pipeline embeds content into ARM template
3. Updated ARM template → Deployment pipeline deploys to Azure

#### Manual Workflow Triggers

- **Combination**: Use "Run workflow" on combine-workbook-into-arm.yml
- **Deployment**: Use "Run workflow" on deploy-arm-template.yml

#### Manual Workflow Inputs

- `resourceGroupName`: Target resource group (default: `rg-azure-workbook-demo`)
- `location`: Azure region for deployment

### Method 2: Local Scripts

#### PowerShell (Windows)
```powershell
# Combine workbook content into ARM template
./combine-workbook.ps1

# Then deploy using Azure PowerShell
Connect-AzAccount
New-AzResourceGroup -Name "rg-azure-workbook-demo" -Location "West Europe"
New-AzResourceGroupDeployment `
  -ResourceGroupName "rg-azure-workbook-demo" `
  -TemplateFile "./demo-armtemplate-1.json" `
  -TemplateParameterFile "./demo-armtemplate-1.parameters.json"
```

#### Bash (Linux/macOS)
```bash
# Combine workbook content into ARM template
chmod +x combine-workbook.sh
./combine-workbook.sh

# Then deploy using Azure CLI
az login
az group create --name "rg-azure-workbook-demo" --location "West Europe"
az deployment group create \
  --resource-group "rg-azure-workbook-demo" \
  --template-file "./demo-armtemplate-1.json" \
  --parameters "@demo-armtemplate-1.parameters.json"
```

### Method 3: Azure CLI

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

### Method 4: Azure PowerShell

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

#### Automated Workflow (Recommended)
1. **Edit the source**: Modify `demo-workbook-1.json` with your changes
2. **Commit changes**: Push to repository → Combination pipeline automatically updates ARM template
3. **Deploy**: ARM template is automatically deployed via deployment pipeline

#### Local Development
1. **Edit workbook**: Modify `demo-workbook-1.json`
2. **Run combination script**: 
   - Windows: `./combine-workbook.ps1`
   - Linux/macOS: `./combine-workbook.sh`
3. **Review changes**: Check the generated `demo-armtemplate-1.json`
4. **Test locally**: Validate with Azure CLI before committing
5. **Deploy**: Push to main branch or deploy manually

### Workbook Content Management

#### Automated Embedding Process
The combination pipeline/scripts automatically:
- Validates JSON syntax of the workbook
- Calculates content hash for change tracking
- Escapes special characters for ARM template embedding
- Generates metadata (size, timestamp, hash)
- Updates the ARM template with proper structure

#### Content Validation
Each combination includes:
- **JSON Validation**: Ensures workbook content is valid
- **Size Checks**: Warns if approaching ARM template 4MB limit
- **Hash Tracking**: Detects content changes
- **Template Validation**: Verifies generated ARM template syntax

### Adding New Queries

To add new KQL queries to the workbook:

1. **Azure Portal Method**:
   - Edit workbook in Azure Portal
   - Export as JSON
   - Replace content in `demo-workbook-1.json`
   - Use combination pipeline/script to update ARM template

2. **Direct Edit Method**:
   - Modify `demo-workbook-1.json` directly
   - Add new query sections to appropriate workbook parts
   - Test combination and deployment

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
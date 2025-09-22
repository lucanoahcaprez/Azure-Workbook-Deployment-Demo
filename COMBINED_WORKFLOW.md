# Combined Workbook Template Deployment Workflow

## Overview
The two separate workflows have been combined into a single, streamlined workflow with 4 sequential steps. The workflow runs each step in order and fails immediately if any step fails, preventing unnecessary execution.

## New Workflow Structure

### Single Action: `Workbook Template Deployment`
**File:** `.github/workflows/workbook-deployment.yml`

### 4 Sequential Steps:

#### **Step 1: Generate ARM Template**
- **Purpose**: Generate ARM template from workbook JSON using PowerShell script
- **Actions**:
  - Checkout code
  - Install PowerShell
  - Run `combine-workbook.ps1` script
  - Validate generated ARM template structure
  - Check for changes
  - Commit and push updated ARM template (if changes detected)
- **Outputs**: `has_changes`, `template_generated`
- **Failure Behavior**: If this step fails, the entire workflow stops

#### **Step 2: Validate ARM Template** 
- **Purpose**: Validate ARM template with Azure Resource Manager
- **Dependencies**: Requires Step 1 to succeed (`template_generated == 'true'`)
- **Actions**:
  - Checkout latest code (including any commits from Step 1)
  - Azure login
  - Create resource group for validation
  - Validate ARM template syntax and structure with Azure
- **Failure Behavior**: If validation fails, deployment steps (3-4) won't run

#### **Step 3: Deploy to Azure**
- **Purpose**: Deploy the workbook template to Azure
- **Dependencies**: Requires Step 2 to succeed, only runs on main branch or manual dispatch
- **Environment**: `production` (requires approval if configured)
- **Actions**:
  - Checkout latest code
  - Azure login
  - Deploy ARM template to Azure
  - Verify deployment succeeded
- **Failure Behavior**: If deployment fails, verification step won't run

#### **Step 4: Verify Deployment**
- **Purpose**: Verify the workbook template was deployed correctly
- **Dependencies**: Requires Step 3 to succeed
- **Actions**:
  - Azure login
  - Check deployed resources in resource group
  - Verify workbook template resource exists
  - Generate comprehensive deployment summary
- **Failure Behavior**: Marks deployment as failed if verification fails

## Key Features

### ✅ **Sequential Execution**
- Each step runs only after the previous step succeeds
- Uses `needs:` dependencies to enforce order
- No parallel execution - clear linear flow

### ✅ **Fail-Fast Behavior**
- If any step fails, subsequent steps are skipped
- Immediate feedback on issues
- No wasted compute time on failed pipelines

### ✅ **Smart Triggering**
- **Push to main**: When `demo-workbook-1.json` changes
- **Pull requests**: For validation of workbook changes
- **Manual dispatch**: With customizable parameters

### ✅ **Flexible Parameters**
- Force update option (bypass change detection)
- Customizable resource group name
- Selectable Azure region
- All parameters available in manual dispatch

### ✅ **Comprehensive Outputs**
- Step-by-step progress tracking
- Detailed deployment summary
- Links to Azure Portal resources
- Clear status indicators for each step

## Workflow Triggers

### Automatic Triggers
```yaml
on:
  push:
    branches: [ main ]
    paths: [ 'demo-workbook-1.json', 'demo-armtemplate-1.json', '.github/workflows/workbook-deployment.yml' ]
  pull_request:
    branches: [ main ]
    paths: [ 'demo-workbook-1.json', 'demo-armtemplate-1.json', '.github/workflows/workbook-deployment.yml' ]
```

### Manual Trigger
```yaml
workflow_dispatch:
  inputs:
    force_update: boolean
    resourceGroupName: string
    location: choice
```

## Benefits of Combined Approach

### 🎯 **Simplified Management**
- Single workflow file to maintain
- One action to monitor in GitHub Actions
- Consistent naming and structure

### 🔄 **Better Flow Control**
- Clear dependencies between steps
- Logical progression from generation to verification
- No race conditions or timing issues

### 📊 **Enhanced Visibility**
- Single workflow run shows complete pipeline status
- Step-by-step progress tracking
- Comprehensive final summary

### 🛡️ **Improved Reliability**
- Fail-fast behavior prevents invalid deployments
- Each step validates previous step's output
- Clear error boundaries and reporting

### 🚀 **Easier Debugging**
- All logs in one workflow run
- Clear step-by-step execution order
- Easier to identify which step failed

## Usage Examples

### Automatic Deployment
1. Update `demo-workbook-1.json`
2. Commit and push to main branch
3. Watch single workflow execute all 4 steps automatically

### Manual Deployment
1. Go to GitHub Actions
2. Select "Workbook Template Deployment"
3. Click "Run workflow"
4. Provide optional parameters
5. Monitor 4-step execution

The combined workflow provides a cleaner, more reliable, and easier-to-manage deployment pipeline!
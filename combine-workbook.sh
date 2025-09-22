#!/bin/bash

# combine-workbook.sh
# Script to combine workbook content into ARM template locally

set -e

echo "🔧 Combining Workbook Content into ARM Template"
echo "==============================================="

# Check if required files exist
if [ ! -f "demo-workbook-1.json" ]; then
    echo "❌ Error: demo-workbook-1.json not found"
    exit 1
fi

# Validate source workbook JSON
echo "📋 Validating source workbook JSON..."
if ! jq empty demo-workbook-1.json; then
    echo "❌ Error: demo-workbook-1.json is not valid JSON"
    exit 1
fi

# Read and process workbook content
echo "📄 Reading workbook content..."
WORKBOOK_CONTENT=$(jq -c . demo-workbook-1.json)
CONTENT_SIZE=$(echo "$WORKBOOK_CONTENT" | wc -c)
CONTENT_HASH=$(echo "$WORKBOOK_CONTENT" | sha256sum | cut -d' ' -f1)

echo "   Size: $CONTENT_SIZE characters"
echo "   Hash: $CONTENT_HASH"

# Escape content for JSON embedding
echo "🔧 Escaping content for ARM template..."
ESCAPED_CONTENT=$(echo "$WORKBOOK_CONTENT" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create ARM template
echo "🏗️  Generating ARM template..."
cat > demo-armtemplate-1.json << EOF
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "description": "ARM Template for deploying Azure Workbook - Sample Dashboard WPNinjas 2025",
    "lastUpdated": "$TIMESTAMP",
    "workbookContentHash": "$CONTENT_HASH",
    "generatedBy": "Local combine-workbook.sh script",
    "workbookSize": $CONTENT_SIZE
  },
  "parameters": {
    "workbookDisplayName": {
      "type": "string",
      "defaultValue": "Sample Dashboard WPNinjas 2025",
      "metadata": {
        "description": "The friendly name for the workbook that is used in the Gallery or Saved List."
      }
    },
    "workbookType": {
      "type": "string",
      "defaultValue": "workbook",
      "metadata": {
        "description": "The gallery that the workbook will been shown under. Supported values include workbook, tsg, etc."
      }
    },
    "workbookSourceId": {
      "type": "string",
      "defaultValue": "azure monitor",
      "metadata": {
        "description": "The id of resource instance to which the workbook will be associated"
      }
    },
    "workbookId": {
      "type": "string",
      "defaultValue": "[newGuid()]",
      "metadata": {
        "description": "The unique guid for this workbook instance"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for all resources."
      }
    },
    "resourceTags": {
      "type": "object",
      "defaultValue": {
        "Environment": "Demo",
        "Project": "Azure-Workbook-Deployment-Demo",
        "CreatedBy": "ARM Template"
      },
      "metadata": {
        "description": "Tags to apply to the workbook resource"
      }
    }
  },
  "variables": {
    "workbookContentFromFile": "$ESCAPED_CONTENT"
  },
  "resources": [
    {
      "type": "microsoft.insights/workbooks",
      "name": "[parameters('workbookId')]",
      "location": "[parameters('location')]",
      "apiVersion": "2022-04-01",
      "kind": "shared",
      "tags": "[parameters('resourceTags')]",
      "properties": {
        "displayName": "[parameters('workbookDisplayName')]",
        "serializedData": "[variables('workbookContentFromFile')]",
        "version": "1.0",
        "sourceId": "[parameters('workbookSourceId')]",
        "category": "[parameters('workbookType')]"
      }
    }
  ],
  "outputs": {
    "workbookId": {
      "type": "string",
      "value": "[resourceId( 'microsoft.insights/workbooks', parameters('workbookId'))]"
    },
    "workbookName": {
      "type": "string", 
      "value": "[parameters('workbookDisplayName')]"
    },
    "workbookContentHash": {
      "type": "string",
      "value": "$CONTENT_HASH"
    }
  }
}
EOF

# Validate generated ARM template
echo "🔍 Validating generated ARM template..."
if ! jq empty demo-armtemplate-1.json; then
    echo "❌ Error: Generated ARM template is not valid JSON"
    exit 1
fi

# Check template size
TEMPLATE_SIZE=$(wc -c < demo-armtemplate-1.json)
if [ $TEMPLATE_SIZE -gt 4194304 ]; then  # 4MB limit
    echo "⚠️  Warning: ARM template size ($TEMPLATE_SIZE bytes) is approaching the 4MB limit"
fi

echo "✅ ARM template generated successfully!"
echo "   Template size: $TEMPLATE_SIZE bytes"
echo "   Content hash: $CONTENT_HASH"
echo "   Updated: $TIMESTAMP"
echo ""
echo "🚀 Next steps:"
echo "   1. Review the generated demo-armtemplate-1.json"
echo "   2. Test the deployment locally or commit to trigger CI/CD"
echo "   3. The template is ready for Azure deployment"
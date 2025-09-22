# combine-workbook.ps1
# PowerShell script to combine workbook content into ARM template locally

[CmdletBinding()]
param()

Write-Host "🔧 Combining Workbook Content into ARM Template" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Check if required files exist
if (-not (Test-Path "demo-workbook-1.json")) {
    Write-Host "❌ Error: demo-workbook-1.json not found" -ForegroundColor Red
    exit 1
}

try {
    # Validate source workbook JSON
    Write-Host "📋 Validating source workbook JSON..." -ForegroundColor Yellow
    $workbookContent = Get-Content "demo-workbook-1.json" -Raw | ConvertFrom-Json
    
    # Read and process workbook content
    Write-Host "📄 Reading workbook content..." -ForegroundColor Yellow
    $workbookJson = Get-Content "demo-workbook-1.json" -Raw
    $contentSize = $workbookJson.Length
    
    # Calculate hash
    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($workbookJson)
    $writer.Flush()
    $stringAsStream.Position = 0
    $contentHash = Get-FileHash -InputStream $stringAsStream -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    $stringAsStream.Close()
    
    Write-Host "   Size: $contentSize characters" -ForegroundColor Green
    Write-Host "   Hash: $contentHash" -ForegroundColor Green
    
    # Escape content for JSON embedding
    Write-Host "🔧 Escaping content for ARM template..." -ForegroundColor Yellow
    $escapedContent = $workbookJson -replace '\\', '\\\\' -replace '"', '\"'
    
    # Generate timestamp
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    # Create ARM template content
    Write-Host "🏗️  Generating ARM template..." -ForegroundColor Yellow
    
    $armTemplate = @{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        metadata = @{
            description = "ARM Template for deploying Azure Workbook - Sample Dashboard WPNinjas 2025"
            lastUpdated = $timestamp
            workbookContentHash = $contentHash
            generatedBy = "Local combine-workbook.ps1 script"
            workbookSize = $contentSize
        }
        parameters = @{
            workbookDisplayName = @{
                type = "string"
                defaultValue = "Sample Dashboard WPNinjas 2025"
                metadata = @{
                    description = "The friendly name for the workbook that is used in the Gallery or Saved List."
                }
            }
            workbookType = @{
                type = "string"
                defaultValue = "workbook"
                metadata = @{
                    description = "The gallery that the workbook will been shown under. Supported values include workbook, tsg, etc."
                }
            }
            workbookSourceId = @{
                type = "string"
                defaultValue = "azure monitor"
                metadata = @{
                    description = "The id of resource instance to which the workbook will be associated"
                }
            }
            workbookId = @{
                type = "string"
                defaultValue = "[newGuid()]"
                metadata = @{
                    description = "The unique guid for this workbook instance"
                }
            }
            location = @{
                type = "string"
                defaultValue = "[resourceGroup().location]"
                metadata = @{
                    description = "Location for all resources."
                }
            }
            resourceTags = @{
                type = "object"
                defaultValue = @{
                    Environment = "Demo"
                    Project = "Azure-Workbook-Deployment-Demo"
                    CreatedBy = "ARM Template"
                }
                metadata = @{
                    description = "Tags to apply to the workbook resource"
                }
            }
        }
        variables = @{
            workbookContentFromFile = $escapedContent
        }
        resources = @(
            @{
                type = "microsoft.insights/workbooks"
                name = "[parameters('workbookId')]"
                location = "[parameters('location')]"
                apiVersion = "2022-04-01"
                kind = "shared"
                tags = "[parameters('resourceTags')]"
                properties = @{
                    displayName = "[parameters('workbookDisplayName')]"
                    serializedData = "[variables('workbookContentFromFile')]"
                    version = "1.0"
                    sourceId = "[parameters('workbookSourceId')]"
                    category = "[parameters('workbookType')]"
                }
            }
        )
        outputs = @{
            workbookId = @{
                type = "string"
                value = "[resourceId( 'microsoft.insights/workbooks', parameters('workbookId'))]"
            }
            workbookName = @{
                type = "string"
                value = "[parameters('workbookDisplayName')]"
            }
            workbookContentHash = @{
                type = "string"
                value = $contentHash
            }
        }
    }
    
    # Convert to JSON and save
    $armJson = $armTemplate | ConvertTo-Json -Depth 10 -Compress:$false
    $armJson | Set-Content "demo-armtemplate-1.json" -Encoding UTF8
    
    # Validate generated ARM template
    Write-Host "🔍 Validating generated ARM template..." -ForegroundColor Yellow
    $null = Get-Content "demo-armtemplate-1.json" -Raw | ConvertFrom-Json
    
    # Check template size
    $templateSize = (Get-Item "demo-armtemplate-1.json").Length
    if ($templateSize -gt 4194304) {  # 4MB limit
        Write-Host "⚠️  Warning: ARM template size ($templateSize bytes) is approaching the 4MB limit" -ForegroundColor Yellow
    }
    
    Write-Host "✅ ARM template generated successfully!" -ForegroundColor Green
    Write-Host "   Template size: $templateSize bytes" -ForegroundColor Green
    Write-Host "   Content hash: $contentHash" -ForegroundColor Green
    Write-Host "   Updated: $timestamp" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Review the generated demo-armtemplate-1.json" -ForegroundColor White
    Write-Host "   2. Test the deployment locally or commit to trigger CI/CD" -ForegroundColor White
    Write-Host "   3. The template is ready for Azure deployment" -ForegroundColor White
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
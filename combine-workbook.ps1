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
    Write-Host "🔧 Preparing workbook content for template data..." -ForegroundColor Yellow
    # For templateData, we need the actual JSON object, not escaped string
    $templateDataContent = $workbookContent
    
    # Generate timestamp
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    # Create ARM template content with proper ordering
    Write-Host "🏗️  Generating ARM template for workbook template..." -ForegroundColor Yellow
    
    $armTemplate = [ordered]@{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        metadata = @{
            description = "ARM Template for deploying Azure Workbook Template - Sample Dashboard WPNinjas 2025"
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
                    description = "The friendly name for the workbook template that is used in the Gallery or Saved List."
                }
            }
            templateName = @{
                type = "string"
                defaultValue = "A Workbook Template"
                metadata = @{
                    description = "The name for the workbook template in the gallery."
                }
            }
            templateCategory = @{
                type = "string"
                defaultValue = "Deployed Templates"
                metadata = @{
                    description = "The category for the workbook template in the gallery."
                }
            }
            workbookId = @{
                type = "string"
                defaultValue = "[newGuid()]"
                metadata = @{
                    description = "The unique guid for this workbook template instance"
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
            # No variables needed for workbook template approach
        }
        resources = @(
            @{
                type = "microsoft.insights/workbooktemplates"
                name = "[parameters('workbookId')]"
                location = "[parameters('location')]"
                apiVersion = "2020-11-20"
                kind = "shared"
                tags = "[parameters('resourceTags')]"
                properties = @{
                    galleries = @(
                        @{
                            name = "[parameters('templateName')]"
                            category = "[parameters('templateCategory')]"
                            order = 100
                            type = "workbook"
                            resourceType = "Azure Monitor"
                        }
                    )
                    templateData = $templateDataContent
                }
            }
        )
        outputs = @{
            workbookTemplateId = @{
                type = "string"
                value = "[resourceId('microsoft.insights/workbooktemplates', parameters('workbookId'))]"
            }
            workbookTemplateName = @{
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
    $armJson = $armTemplate | ConvertTo-Json -Depth 25 -Compress:$false
    
    # Ensure proper encoding and clean formatting
    $armJson = $armJson -replace '\r\n', "`n" -replace '\r', "`n"
    $armJson | Set-Content "demo-armtemplate-1.json" -Encoding UTF8 -NoNewline
    
    # Validate generated ARM template
    Write-Host "🔍 Validating generated ARM template..." -ForegroundColor Yellow
    try {
        $null = Get-Content "demo-armtemplate-1.json" -Raw | ConvertFrom-Json
        Write-Host "   JSON syntax: ✅ Valid" -ForegroundColor Green
    } catch {
        Write-Host "   JSON syntax: ❌ Invalid - $($_.Exception.Message)" -ForegroundColor Red
        throw "Generated ARM template has invalid JSON syntax"
    }
    
    # Additional Azure ARM template validation
    $templateContent = Get-Content "demo-armtemplate-1.json" -Raw
    if (-not $templateContent.StartsWith('{')) {
        throw "ARM template must start with opening brace"
    }
    if (-not $templateContent.Contains('"$schema"')) {
        throw "ARM template must contain $schema property"
    }
    
    # Check template size
    $templateSize = (Get-Item "demo-armtemplate-1.json").Length
    if ($templateSize -gt 4194304) {  # 4MB limit
        Write-Host "⚠️  Warning: ARM template size ($templateSize bytes) is approaching the 4MB limit" -ForegroundColor Yellow
    }
    
    Write-Host "✅ ARM template with workbook template generated successfully!" -ForegroundColor Green
    Write-Host "   Template size: $templateSize bytes" -ForegroundColor Green
    Write-Host "   Content hash: $contentHash" -ForegroundColor Green
    Write-Host "   Updated: $timestamp" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Review the generated demo-armtemplate-1.json (now uses workbook templates)" -ForegroundColor White
    Write-Host "   2. Test the deployment locally or commit to trigger CI/CD" -ForegroundColor White
    Write-Host "   3. The template will create a workbook template in Azure Monitor gallery" -ForegroundColor White
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
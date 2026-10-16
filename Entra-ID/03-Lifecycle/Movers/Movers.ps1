# Connect first if required
# Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All"

# ========================================
# Configuration
# ========================================

$CsvPath = "C:\Temp\JML\Movers_Auto.csv"

# Set to $true for testing
# Set to $false to make changes
$WhatIf = $true

# ========================================
# Validation
# ========================================

if (-not (Test-Path $CsvPath))
{
    Write-Host "CSV file not found: $CsvPath" -ForegroundColor Red
    exit
}

$Users = Import-Csv $CsvPath

Write-Host "Rows Loaded: $($Users.Count)" -ForegroundColor Cyan

# Cache all users once
$AllUsers = Get-MgUser -All

# ========================================
# Processing
# ========================================

$Audit = foreach ($User in $Users)
{
    $DisplayName = [string]$User.DisplayName
    $ManagerName = [string]$User.ManagerName
    $JobTitle    = [string]$User.JobTitle
    $Department  = [string]$User.Department

    $DisplayName = $DisplayName.Trim()
    $ManagerName = $ManagerName.Trim()
    $JobTitle    = $JobTitle.Trim()
    $Department  = $Department.Trim()

    try
    {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor DarkCyan
        Write-Host "Processing $DisplayName" -ForegroundColor Cyan

        # Find User
        $EntraUser = $AllUsers | Where-Object {
            $_.DisplayName -eq $DisplayName
        }

        if (-not $EntraUser)
        {
            throw "User not found"
        }

        if (($EntraUser | Measure-Object).Count -gt 1)
        {
            throw "Multiple users found"
        }

        Write-Host "User Found: $($EntraUser.DisplayName)" -ForegroundColor Gray

        $ChangesMade = @()

        # ========================================
        # Manager Update
        # ========================================

        if (-not [string]::IsNullOrWhiteSpace($ManagerName))
        {
            Write-Host "Searching for Manager: $ManagerName" -ForegroundColor Gray

            $EntraManager = $AllUsers | Where-Object {
                $_.DisplayName -eq $ManagerName
            }

            if (-not $EntraManager)
            {
                throw "Manager not found"
            }

            if (($EntraManager | Measure-Object).Count -gt 1)
            {
                throw "Multiple managers found"
            }

            Write-Host "Manager Found: $($EntraManager.DisplayName)" -ForegroundColor Gray

           $ManagerRef = @{
				"@odata.id" = "https://graph.microsoft.com/v1.0/users/$($EntraManager.Id)"
			}

            if ($WhatIf)
            {
                Write-Host "WHATIF: Manager would be updated" -ForegroundColor Yellow
            }
            else
            {
                Set-MgUserManagerByRef `
                    -UserId $EntraUser.Id `
                    -BodyParameter $ManagerRef

                Write-Host "Manager updated" -ForegroundColor Green
            }

            $ChangesMade += "Manager"
        }
        else
        {
            Write-Host "Manager empty - skipped" -ForegroundColor Yellow
        }

        # ========================================
        # Job Title / Department Update
        # ========================================

        $UpdateParams = @{}

        if (-not [string]::IsNullOrWhiteSpace($JobTitle))
        {
            $UpdateParams.JobTitle = $JobTitle

            Write-Host "Updating Job Title to '$JobTitle'" -ForegroundColor Gray

            $ChangesMade += "Job Title"
        }
        else
        {
            Write-Host "Job Title empty - skipped" -ForegroundColor Yellow
        }

        if (-not [string]::IsNullOrWhiteSpace($Department))
        {
            $UpdateParams.Department = $Department

            Write-Host "Updating Department to '$Department'" -ForegroundColor Gray

            $ChangesMade += "Department"
        }
        else
        {
            Write-Host "Department empty - skipped" -ForegroundColor Yellow
        }

        if ($UpdateParams.Count -gt 0)
        {
            if ($WhatIf)
            {
                Write-Host "WHATIF: User attributes would be updated" -ForegroundColor Yellow
            }
            else
            {
                Update-MgUser `
                    -UserId $EntraUser.Id `
                    -BodyParameter $UpdateParams

                Write-Host "User attributes updated" -ForegroundColor Green
            }
        }

        if ($ChangesMade.Count -eq 0)
        {
            Write-Host "No changes supplied" -ForegroundColor Yellow

            [PSCustomObject]@{
                DisplayName = $DisplayName
                ManagerName = $ManagerName
                JobTitle    = $JobTitle
                Department  = $Department
                Status      = "Skipped"
                Changes     = ""
                Error       = ""
                Timestamp   = Get-Date
            }

            continue
        }

        Write-Host "SUCCESS: $($ChangesMade -join ', ')" -ForegroundColor Green
		if ($WhatIf)
			{
				$Status = "WhatIf"
			}
				else
			{
				$Status = "Success"
			}
			[PSCustomObject]@{
				DisplayName = $DisplayName
				ManagerName = $ManagerName
				JobTitle    = $JobTitle
				Department  = $Department
				Status      = $Status
				Changes     = ($ChangesMade -join ", ")
				Error       = ""
				Timestamp   = Get-Date
}
				    }
			catch
			{
				Write-Host "FAILED: $DisplayName" -ForegroundColor Red
				Write-Host $_.Exception.Message -ForegroundColor Yellow

				[PSCustomObject]@{
					DisplayName = $DisplayName
					ManagerName = $ManagerName
					JobTitle    = $JobTitle
					Department  = $Department
					Status      = "Failed"
					Changes     = ""
					Error       = $_.Exception.Message
					Timestamp   = Get-Date
				}
			}
		}
		$Audit = foreach ($User in $Users)
		{

		}

				$Audit | Export-Csv `
					"C:\Temp\JML\Audits\EmployeeMoverAudit.csv" `
					-NoTypeInformation

				Write-Host ""
				Write-Host "Completed." -ForegroundColor Cyan
				Write-Host "Audit File: C:\Temp\EmployeeMoverAudit.csv" -ForegroundColor Cyan
				Write-Host "WhatIf Mode: $WhatIf" -ForegroundColor Cyan
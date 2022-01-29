#==============================================================================
# To_do.ps1
# 
# Version: 0.1
# Created: 31/12/2021
# Modified: 31/12/2021
# Author: James D. Britton. [JDB]
# Purpose:  Cheesy todo list that's way overcomplicated. 
#==============================================================================
#Note: To remove from array :: $Items | Where-Object { $_ -ne $Items[0]}
# $error[0].exception.GetType().fullname

$OldTitle = $host.UI.RawUI.WindowTitle
$host.UI.RawUI.WindowTitle = "JDB's To-Do List."
$Options = "____________________`nOptions:`n1. New Item.`n2. View Items.`n3. Search Items (By Content)`n4. Sort Items (Creation Time)`n5. View Specific Item`n6. Delete Item by Index`n7. Save Items (Overwrite Existing Save)`n8. Load Items (Clears Existing Items)`n9. Quit`nH. Display these options`n____________________"
$Items = @()


Function Show-Options {
    Write-Host "$Options" -ForegroundColor (Get-Random -Minimum 1 -Maximum 15) 
}

Function Show-Title {
    Clear-Host
    Write-Host "
  __________        ____  ____     __    _______________
 /_  __/ __ \      / __ \/ __ \   / /   /  _/ ___/_  __/
  / / / / / /_____/ / / / / / /  / /    / / \__ \ / /   
 / / / /_/ /_____/ /_/ / /_/ /  / /____/ / ___/ // /    
/_/  \____/     /_____/\____/  /_____/___//____//_/
By James Britton, 2022." -ForegroundColor (Get-Random -Minimum 1 -Maximum 15)
}

Show-Title

While (($Option = Read-Host -Prompt "Selection") -ne "9") {
    Switch ($Option) {
        {($_ -eq 1) -or ($_ -eq "new")} {
            Show-Title
            Write-Host "New item --" -ForegroundColor Green
            $NewItem = [PSCustomObject]@{
                Title        = Read-Host -Prompt "Provide title"
                CreationTime = Get-Date -Format "dd/MM/yy HH:mm:ss"
                Content      = Read-Host -Prompt "Content of todo note"
            }
            $Items += $NewItem
            Write-Host "Item created.`n" -ForegroundColor Green
            Show-Options
        }

        2 {
            Show-Title
            Write-Host "Listing all items --`n====================" -ForegroundColor Green
            Foreach ($item in $Items) {
                Write-Output "`nIndex number: $($Items.IndexOf($item))"; $item | Format-Table -Wrap -HideTableHeaders
            }
            Write-Host "All items listed above.`n====================" -ForegroundColor Green
            Show-Options
        }

        3 {
            Show-Title
            $SearchTerm = Read-Host "Provide your search term"
            Write-Host "Search results:`n===== vvv vvv vvv =====" -ForegroundColor Green
            Foreach ($item in ($Items | Where-Object Content -like "*$SearchTerm*")) {
                '----------' * 4; Write-Output "Index number: $($Items.IndexOf($item))"; $Item | Format-Table -Wrap -HideTableHeaders; '----------' * 4
            }
            Write-Host "===== ^^^ ^^^ ^^^ =====" -ForegroundColor Green
            Show-Options
        }

        4 {
            Show-Title
            Write-Host "Ordering items by date:"
            $Items | Sort-Object CreationTime | Format-Table -Wrap -HideTableHeaders
            Write-Host "^^^ Results ^^^`n" -ForegroundColor Green
            Show-Options
        }

        5 {
            Show-Title
            Try {
                [int]$Index = Read-Host "Provide index number" -ErrorAction Stop
            }
            Catch [System.Management.Automation.RuntimeException] {
                Write-Warning "Invalid data entered. Must be an integer."
            }
            Finally {
                $Result = $Items[[string]$Index]
            }
            Write-Host "===== vvv vvv vvv =====" -ForegroundColor Green
            $Result | Format-List
            Write-Host "===== ^^^ Results ^^^ =====`n" -ForegroundColor Green
            Show-Options
        }

        6 {
            Show-Title
            Write-Host "Delete item ..." -ForegroundColor Red
            Try {
                [int]$Index = Read-Host "Provide index number to delete"
            }
            Catch [System.Management.Automation.RuntimeException] {
                Write-Warning "Invalid data entered. Must be an integer."
            }
            Finally {
                $OldItems = $Items
                $Items = @()
                $Items = $OldItems | Where-Object { $_ -ne $OldItems[$Index] } 
            }
            Write-Host "Item number $Index deleted.`n" -ForegroundColor Red
            Show-Options
        }

        7 {
            Write-Host "Saving items ..." -ForegroundColor Green
            $SaveData = $Items | ConvertTo-Json
            Set-Content -Path $PSScriptRoot\ToDo.JSON -Value $SaveData
            Write-Host "Item data saved.`n" -ForegroundColor Green
        }

        8 {
            Write-Host "Loading items ..." -ForegroundColor Green
            $Items = @()
            $LoadData = Get-Content $PSScriptRoot\ToDo.JSON | ConvertFrom-Json
            $Items += $LoadData
            Write-Host "Item data loaded.`n" -ForegroundColor Green
        }

        9 {
            #'Bye!'
        }

        'H' {
            Show-Title
            Show-Options
        }
        
        Default {
            Show-Title
            Write-Host "Invalid option chosen." -ForegroundColor Red
            Show-Options
        }
    }
}

Write-Host "Goodbye!"
$host.UI.RawUI.WindowTitle = $OldTitle

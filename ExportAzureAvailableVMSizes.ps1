#Add-AzureRmAccount -SubscriptionId 7d94a8a1-65c8-4172-a3f7-9b7ef76bef6f

$ExportFilePath = "$($Env:Temp)\AzureVMSizes.csv"
$RegionSearch = "*"
$regionExclude = ""

$VMSizeList = New-Object collections.ArrayList
$Locns = Get-AzureRmLocation | Where-Object {$_.location -like $RegionSearch -and $_.Location -notlike $regionExclude }
$Locns.location

foreach ($Locn in $Locns) {
    
    $VMSizes = Get-AzureRmVMSize -Location $Locn.Location 
    Write-Output "Locn: $($Locn.DisplayName) - $($VMSizes.Count) records"
    foreach ($VMSize in $VMSizes) {
        $SizeListEntry = new-object psobject -Property @{
            Location = $($Locn.DisplayName)
            Name = $VMSize.Name
            NumberOfCores = $VMSize.NumberOfCores
            MemoryInMB = $VMSize.MemoryInMB
            MaxDataDiskCount = $VMSize.MaxDataDiskCount
            OSDiskSizeInMB = $VMSize.OSDiskSizeInMB
            ResourceDiskSizeInMB = $VMSize.ResourceDiskSizeInMB
        }
        $VMSizeList.Add($SizeListEntry) | Out-Null 
    }
    
}

$Headers = "Location","Name","Number of Cores","Memory In MB", "Max Data Disk Count", "OS Disk Size In MB", "Resource Disk Size In MB" 
$VMSizeList | Select-Object Location, Name, NumberOfCores, MemoryInMB, MaxDataDiskCount, OSDiskSizeInMB, ResourceDiskSizeInMB | format-table -AutoSize
$TempFile = New-TemporaryFile
$VMSizeList | Select-Object Location, Name, NumberOfCores, MemoryInMB, MaxDataDiskCount, OSDiskSizeInMB, ResourceDiskSizeInMB | Export-Csv -Path $TempFile.FullName -NoTypeInformation 
$tList = Import-Csv -Path $TempFile.FullName -Delimiter "," -Header $Headers | Select-Object -Skip 1
$tList | Export-Csv -Path $ExportFilePath -NoTypeInformation 
$TempFile.Delete()
Invoke-Item $ExportFilePath

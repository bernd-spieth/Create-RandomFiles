
#region functions

function New-RandomFolders
{
    param(
        [Parameter(mandatory = $false)]$RootPath,
        [Parameter(mandatory = $false)]$MaxFolderDepth,
        [Parameter(mandatory = $false)]$MaxFolderCount
    )
    begin {
        $Progress = @{Activity = "Create random pathes..."; Status = "Initializing..." }

        $folderPathes = @()
        $monthNumberRange = 1..12
        # $weekdayNumberRange = 0..6
        $randomNumberRange = 0..10000
        $currentFolderDepth = 0
        $currentFolderCount = 0
    }
    process{
        while($true)
        {
            $currentFolderPath = $RootPath
            $currentFolderDepth = 0

            while ($currentFolderDepth -le $MaxFolderDepth)
            {
                # If we have reached the max folder count exit the while loop
                if($currentFolderCount -le $MaxFolderCount)
                {
                    $monthNumber = $monthNumberRange | Get-Random
                    $monthName = (Get-Culture).DateTimeFormat.GetMonthName($monthNumber)
                    
                    # $weekdayNumber = $weekdayNumberRange | Get-Random
                    # $weekdayName = (Get-Culture).DateTimeFormat.GetDayName($weekdayNumber)
            
                    $randomNumber = $randomNumberRange | Get-Random
            
                    $currentFolderPath = Join-Path $currentFolderPath  (("{0}.{1}-{2}") -f $monthNumber, $monthName, $randomNumber)
                    $folderPathes += $currentFolderPath 
                    Write-Progress @Progress -CurrentOperation ("Created folder path: {0}" -f $currentFolderPath)

                    $currentFolderCount++
                    $currentFolderDepth++
                }
                else {
                    break
                }
            }

            if($currentFolderCount -ge $MaxFolderCount)
            {
                break
            }
        }
    }
    end {
        return $folderPathes
    }
}

function New-FileName {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(mandatory = $false)][validateSet("Multimedia", "Image", "Office", "Junk", "Archive", "Script", "all", "")][String]$FileTypes = $all,
        [Parameter(mandatory = $false)]$NamePrefix = ""
    )
    begin {
        $AllExtensions = @()
        $MultimediaExtensions = ".avi", ".midi", ".mov", ".mp3", ".mp4", ".mpeg", ".mpeg2", ".mpeg3", ".mpg", ".ogg", ".ram", ".rm", ".wma", ".wmv"
        $ImageExtensions = ".gif", ".jpg", ".jpeg", ".png", ".tif", ".tiff", ".bmp", ".dib", ".wmf", ".emf", ".emz", ".svg", ".svgz", ".dwg", ".dxf", ".crw", ".cr2", ".raw", ".eps", ".ico", ".pcx"
        $OfficeExtensions = ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx"
        $OfficeExtensions2 = ".rtf", ".txt", ".csv", ".xml", ".mht", ".mhtml", ".htm", ".html", ".xps", `
            ".dot", ".dotx", ".docm", ".dotm", ".odt", ".wps", `
            ".xlt", ".xltx", ".xlsm", ".xlsb", ".xltm", ".xla", ".ods", `
            ".pot", ".potx", ".pptm", ".potm", ".pps", ".ppsx", ".ppsm", ".odp", `
            ".pub", ".mpp", ".vsd", ".vsdx", ".vsdm", ".vdx", ".vssx", ".vssm", ".vsx", ".vstx", ".vst", ".vstm", ".vsw", ".vdw"
        $OfficeExtensions += $OfficeExtensions2
        $JunkExtensions = ".tmp", ".temp", ".lock"
        $ArchiveExtensions = ".zip", ".7z", ".rar", ".cab", ".iso", ".001", ".ex_"
        $ScriptExtensions = ".ps1", ".vbs", ".vbe", ".cmd", ".bat", ".php", ".hta", ".ini", ".inf", ".reg", ".asp", ".sql", ".vb", ".js", ".css", ".kix", ".au3"
        $AllExtensions = $MultimediaExtensions + $ImageExtensions + $OfficeExtensions + $JunkExtensions + $ArchiveExtensions + $ScriptExtensions
        $extension = $null
    }
    process {
        Write-Verbose "Creating file Name"

        switch ($filesType) {
            "Multimedia" { $extension = $MultimediaExtensions | Get-Random }
            "Image" { $extension = $ImageExtensions | Get-Random }
            "Office" { $extension = $OfficeExtensions | Get-Random }
            "Junk" { $extension = $JunkExtensions | Get-Random }
            "Archive" { $extension = $ArchiveExtensions | Get-Random }
            "Script" { $extension = $ScriptExtensions | Get-Random }
            default { $extension = $AllExtensions | Get-Random }
        }
        Get-Verb | Select-Object verb | Get-Random -Count 2 | ForEach-Object { $Name += $_.verb }
        $FullName = $NamePrefix + $name + $extension
        Write-Verbose "File name created : $FullName"
        Write-Progress @Progress -CurrentOperation "Created file Name : $FullName"
    }
    end {
        return $FullName
    }
}

function New-RandomFilesInFolders {
<#
    .SYNOPSIS
    Generates a number of dumb files for a specific size.
    
    .DESCRIPTION
    Generates a defined number of files until reaching a maximum size.
    
    .PARAMETER TotalSize
    Specify the total size you would all the files combined should use on the harddrive.
    This parameter accepts the following size values (KB,MB,GB,TB).  MB is assumed if no designation is specified.
    200KB
    5MB
    3GB
    1TB
    
    .PARAMETER NumberOfFiles
    Specify a number of files that need to be created. This can be used to generate 
    a big number of small files in order to simulate User backup specefic behaviour.
    
    .PARAMETER FilesTypes
    This parameter is not mandatory, but the following choices are valid to generate files with the associated extensions:
    Multimedia : ".avi",".midi",".mov",".mp3",".mp4",".mpeg",".mpeg2",".mpeg3",".mpg",".ogg",".ram",".rm",".wma",".wmv"
    Image      : ".gif",".jpg",".jpeg",".png",".tif",".tiff",".bmp",".dib",".wmf",".emf",".emz",".svg",".svgz",".dwg",".dxf",".crw",".cr2",".raw",".eps",".ico",".pcx"
    Office     : ".pdf",".doc",".docx",".xls",".xlsx",".ppt",".pptx",".rtf",".txt",".csv",".xml",".mht",".mhtml",".htm",".html",".xps",".dot",".dotx",".docm",".dotm",".odt",".wps",".xlt",".xltx",".xlsm",".xlsb",".xltm",".xla",".ods",".pot",".potx",".pptm",".potm",".pps",".ppsx",".ppsm",".odp",".pub",".mpp",".vsd",".vsdx",".vsdm",".vdx",".vssx",".vssm",".vsx",".vstx",".vst",".vstm",".vsw",".vdw"
    Junk       : ".tmp",".temp",".lock"
    Archive    : ".zip",".7z",".rar",".cab",".iso",".001",".ex_"
    Script     : ".ps1",".vbs",".vbe",".cmd",".bat",".php",".hta",".ini",".inf",".reg",".asp",".sql",".vb",".js",".css",".kix",".au3"
    If Filestypes parameter is not set, by default, the script will create all types of files.
    
    .PARAMETER Path
    Specify a path where the files should be generated.
    
    .PARAMETER NamePrefix
    Optional.  Allows prepending text to the beginning of the generated file names so they can be easily found and sorted.

    .PARAMETER MaxFolderCount
    Optional. The number of folders to create. If no value is provided or the parameter is missing no folders will be created.
    
    .PARAMETER MaxFolderDepth
    Optional. The number of folder depth. If no value is provided 5 is used

    .PARAMETER WhatIf
    Permits to launch this script in "draft" mode. This means it will only show the results without really making generating the files.
    
    .PARAMETER Verbose
    Allow to run the script in verbose mode for debbuging purposes.
    
    .EXAMPLE
    .Create-RandomFiles.ps1 -TotalSize 1GB -NumberOfFiles 123 -Path $env:Temp -FilesTypes 'Office' -NamePrefix '~'
    
    Generate in the user's temp folder 123 randomly named office files all beginning with "~" which total 1GB.
    
    .EXAMPLE
    .Create-RandomFiles.ps1 -TotalSize 50 -NumberOfFiles 42 -Path C:Usersadministratordocuments
    
    Generate in the adminstrator's documents folder 42 randomly named files which total 50MB.
    
    .NOTES
    -Author: Stéphane van Gulick
    -Email : Svangulick@gmail.com
    -Version: 1.0
    -History:
        -Creation V0.1 : SVG
        -First final draft V0.5 : SVG
        -Corrected minor bugs V0.6 : SVG
        -Functionalized the script V0.8 : SVG
        -Simplified code V1.0 : SVG

    ===== Change History =====
    based on http://powershelldistrict.com/create-files/
    -Author: Chad Simmons
    -2015/12/04: added Write-Progress, files are created with different sizes, TotalSize defaults to MB, added name prefix, added execution statistics, replaced fsutil.exe with New-Object byte[], added additional filetypes

    .LINK
    http://www.PowerShellDistrict.com
    http://blogs.CatapultSystems.com
#>
    [cmdletbinding()]
    param(
        [Parameter(mandatory = $true)]$NumberOfFiles,
        [Parameter(mandatory = $true)]$Path,
        [Parameter(mandatory = $true)]$TotalSize,
        [Parameter(mandatory = $false)][validateSet("Multimedia", "Image", "Office", "Junk", "Archive", "Script", "all", "")][String]$FilesType = $all,
        [Parameter(mandatory = $false)]$NamePrefix = "",
        [Parameter(mandatory = $false)]$MaxFolderCount = "",
        [Parameter(mandatory = $false)]$MaxFolderDepth = 5

    )
    begin {
        $StartTime = (get-date)
        $Progress = @{Activity = "Create Random Files..."; Status = "Initializing..." }
        Write-verbose "Generating files"
        $AllCreatedFilles = @()
        $folderPathes = @()
    }

    process {
        if ($TotalSize -match '^d+$') { [string]$TotalSize += "MB" }
        $Progress.Status = "Creating $NumberOfFiles files totalling $TotalSize"
        Write-Progress @Progress
 
        Write-Verbose "Total Size is $TotalSize"
        $FileSize = $TotalSize / $NumberOfFiles
        $FileSize = [Math]::Round($FileSize, 0)
        Write-Verbose "Average file size of $FileSize"
        $FileSizeOffset = [Math]::Round($FileSize / $NumberOfFiles, 0)
        Write-Verbose "file size offset of $FileSizeOffset"
        $FileSize = $FileSizeOffset * $NumberOfFiles / 2
        Write-Verbose "Beginning file size of $FileSize"
 
        # Get random folders if we have a value for MaxFolderCount
        if($MaxFolderCount)
        {
            $folderPathes = New-RandomFolders -MaxFolderDepth $MaxFolderDepth -RootPath $Path -MaxFolderCount $MaxFolderCount
        }

        while ($FileNumber -lt $NumberOfFiles) {
            $FileNumber++
            If ($FileNumber -eq $NumberOfFiles) { 
                $FileSize = $TotalSize - $TotalFileSize
                Write-Verbose "Setting last file to size $FileSize"
            }
            $TotalFileSize = $TotalFileSize + $FileSize
            $FileName = New-FileName -FileTypes $filesType
            Write-Verbose "Creating : $FileName of $FileSize"
            $Progress.Status = "Creating $NumberOfFiles files totalling $TotalSize.  Run time $(New-TimeSpan -Start $StartTime -end $(Get-Date))"
            Write-Progress @Progress -CurrentOperation "Creating file $FileNumber of $NumberOfFiles : $FileName is $FileSize bytes." -PercentComplete ($FileNumber / $NumberOfFiles * 100)
            $FullPath = ""

            # Pick a random folder from the list of folders if we use folders at all and create it if it does not exist
            if($MaxFolderCount)
            {
                $path = Get-Random -InputObject $folderPathes
                
                if(!(Test-Path $path))
                {
                    New-Item -Path $path -ItemType "directory"
                }

                $FullPath = Join-Path  $path $FileName
            }
            else {
                $FullPath = Join-Path $path -ChildPath $FileName
            }

            try {
                #fsutil.exe file createnew $FullPath $FileSize | Out-Null
                $buffer = New-Object byte[] $FileSize  #http://blogs.technet.com/b/heyscriptingguy/archive/2010/06/09/hey-scripting-guy-how-can-i-use-windows-powershell-2-0-to-create-a-text-file-of-a-specific-size.aspx
                $fi = [io.file]::Create($FullPath)
                $fi.Write($buffer, 0, $buffer.length)
                $fi.Close()
            }
            catch {
                $_
            }
 
            $FileCreated = ""
            $Properties = @{'FullPath' = $FullPath; 'Size' = $FileSize }
            $FileCreated = New-Object -TypeName psobject -Property $properties
            $AllCreatedFilles += $FileCreated
            Write-verbose "$($AllCreatedFilles) created $($FileCreated)"
            Write-Progress @Progress -CurrentOperation "Creating file $FileNumber of $NumberofFiles : $FileName is $FileSize bytes.  Done." -PercentComplete ($FileNumber / $NumberOfFiles * 100)
 
            $FileSize = ([Math]::Round($FileSize, 0)) + $FileSizeOffset
        }
    }
    end {
        Write-Output $AllCreatedFilles
        Write-Output "Start     time: $StartTime"
        Write-Output "Execution time: $(New-TimeSpan -Start $StartTime -end $(Get-Date))" #http://blogs.technet.com/b/heyscriptingguy/archive/2013/03/15/use-powershell-and-conditional-formatting-to-format-time-spans.aspx
    }
}
#endregion functions

New-RandomFilesInFolders -TotalSize 100MB -NumberOfFiles 500 -Path "C:\Temp" -FilesType "Office" -MaxFolderDepth 5 -MaxFolderCount 30

#embed watermark
function Embed-Watermark {
    param (
        [string]$FolderPath,
        [string]$Watermark
    )

    $files = Get-ChildItem -Path $FolderPath
    # Code to embed watermark into the file
    # For demonstration purposes, let's assume we're appending metadata
    foreach ($f in $files){
    Add-Content -Path $f.FullName -Value "watermark= $Watermark"
    }
}

# Function to extract watermark from a file
function Extract-Watermark {
    param (
        [string]$FilePath
    )
    
    # Code to extract watermark from the file
    
    $content = Get-Content -Path $FilePath
    $watermark = $content | Where-Object { $_ -match '^watermark= (.+)$' } | ForEach-Object { $matches[1] }
    
    return $watermark
}

# Function to remove watermark from files in a folder
function Remove-Watermark {
    param (
        [string]$FolderPath
    )
    # Get all files in the folder
    $files = Get-ChildItem -Path $FolderPath

    # Iterate through each file
    foreach ($file in $files) {
        # Check if the file contains a watermark
        $content = Get-Content -Path $file.FullName
        $watermarkExists = $content -match '^watermark= (.+)$'

        # If watermark exists, remove it
        if ($watermarkExists) {
            $contentWithoutWatermark = $content -notmatch '^watermark= (.+)$'
            Set-Content -Path $file.FullName -Value $contentWithoutWatermark
        } 
    }
}

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Calculate-Metadata($filepath) {
    $fileInfo = Get-Item $filepath
    return $fileInfo
}

Function Erase-Baseline-If-Already-Exists {
    param (
        [string]$baselineFilePath,
        [string]$MetabaselinePath
    )

    $baselineExists = Test-Path -Path $baselineFilePath

    if ($baselineExists) {
        # Delete it
        Remove-Item -Path $baselineFilePath
    }

    $metaBaselineExists = Test-Path -Path $MetabaselinePath

    if($metaBaselineExists){
       Remove-Item -Path $MetabaselinePath
    }
}

Function create-hashDict {
    
    param (
        [string] $baselineFilePath
    )

    $fileHashDictionary = @{}

    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathsAndHashes = Get-Content -Path $baselineFilePath
    
    #baseline loading into dict
    foreach ($f in $filePathsAndHashes) {
         $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

    return $fileHashDictionary
}

Function create-MetaDict{
    param (
         [string] $MetabaselinePath
    )
    #create empty dict for metadata baseline
    $fileMetaDictionary = @{}

    $fileMetadata = Get-Content -Path $MetabaselinePath

    foreach ($f in $fileMetadata){

         $fileMetaDictionary.add($f.Split("|")[0].Trim(),@($f.Split("|")[1],$f.Split("|")[2]))

    }

    return $fileMetaDictionary
}

Function waterMark-Module {
    param (
        [string] $hashPath,
        [System.Collections.Hashtable] $fileMetaDictionary
    )
    $fileMeta = Calculate-Metadata($hashPath)
    
    if ($fileMetaDictionary.ContainsKey($hashPath)) {
        $values = $fileMetaDictionary[$hashPath]
        $v1 = $values[0]  # Access the first value
        $v2 = $values[1]  # Access the second value
        $watermark = Extract-Watermark -FilePath $hashPath
                    
        if($v1 -ne $fileMeta.Length -or $v2 -ne $fileMeta.LastWriteTime){
              if($watermark -eq $env:USERNAME){
                   Write-Host "authorized user changes!" -ForegroundColor Green
              }
              else{ 
                   Write-Host "Unauthorized Changes" -ForegroundColor Red
              }
              Write-Host "Content of $($hashPath) is modified"
              write-Host "Baseline length : $($v1) and current Length : $($fileMeta.Length)"
              Write-Host "Baseline ModifiedTime: $($v2) and latest ModifiedTime : $($fileMeta.LastWriteTime)"
        }
        else{
             write-Host "no change"
        }
    }
    else{
        Write-Host "new File $($hashPath) has been created with Length $($fileMeta.Length)" -ForegroundColor DarkCyan
    }

}

#driver code

Write-Host ""
Write-Host "What would you like to do?"
Write-Host ""
Write-Host "    A) Collect new Baseline?"
Write-Host "    B) Begin monitoring files with saved Baseline?"
Write-Host ""
$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""



if ($response -eq "A".ToUpper()) {
    
    # Collect all files in the target folder in a path
    $file_path = Read-Host -Prompt "enter the directory path where the files are stored"
    $save_path = Read-Host -Prompt "enter the path where you want to store the baseline files"
    $folderPath = $file_path #'D:\FSI\MyTool!\practise codes\test files1'

    # Get all files in the folder
    $files = Get-ChildItem -Path $folderPath

    $baselineFilePath = $save_path + "\baseline.txt" #'D:\FSI\MyTool!\practise codes\baseline.txt' 
    $MetabaselinePath = $save_path + "\MetaBaseline.txt" #'D:\FSI\MyTool!\practise codes\MetaBaseline.txt'

    # Delete baseline.txt if it already exists
    Erase-Baseline-If-Already-Exists -baselineFilePath $baselineFilePath -MetabaselinePath $MetabaselinePath
    Remove-Watermark -FolderPath $folderPath

    #embed watermark
    Embed-Watermark -FolderPath $folderPath -Watermark $env:USERNAME

    # Calculate Hash from the target files and store in baseline.txt

    # For each file, calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath $baselineFilePath -Append
    }
 

    #Foe each file, retrieve metadata and create metadata baseline text file.
    foreach ($f in $files){
        $metaData = Calculate-Metadata $f.FullName
        "$($metaData.FullName) | $($metaData.Length) | $($metaData.LastWriteTime)" | Out-File -FilePath $MetabaselinePath -Append
    }
    
}

elseif ($response -eq "B".ToUpper()){

     # create HashDict by loading content from baseline.txt file into hash dict
     $fileHashDictionary = create-hashDict -baselineFilePath $baselineFilePath

     # create  metaDict by loading content from metabaseline.txt file into metaDict
     $fileMetaDictionary = create-MetaDict -MetabaselinePath $MetabaselinePath

     while ($true) {
        Start-Sleep -Seconds 3
        
        $files = Get-ChildItem -Path $folderPath

        # For each file, calculate the hash, and write to baseline.txt
        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName
            #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append

            # Notify if a new file has been created
            if ($fileHashDictionary[$hash.Path] -eq $null) {
                # A new file has been created!
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Yellow
                waterMark-Module -hashPath $hash.Path -fileMetaDictionary $fileMetaDictionary
            }
            else{
                if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                    # The file has not changed
                }
                else {
                    # File file has been compromised!, notify the user
                    Write-Host "$($hash.Path) has changed!!!" -ForegroundColor Red
                    $hashPath = $hash.Path
                    waterMark-Module -hashPath $hashPath -fileMetaDictionary $fileMetaDictionary
                }
            }
        }
    }

}



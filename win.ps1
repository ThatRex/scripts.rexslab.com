$name = "script.rexslab.com"
$workDir = "$env:TEMP/$name"

param(
    [string]$Script
)

$scriptUrls = @{
    "voicemeeter-no-crackle"  = "https://raw.githubusercontent.com/ThatRex/voicemeeter-no-crackle/main/voicemeeter-no-crackle.bat";
    "windows-virtual-monitor" = "https://raw.githubusercontent.com/ThatRex/windows-virtual-monitor/main/windows-virtual-monitor.ps1";
}

function DownloadAndExecuteScript([string]$url) {
    New-Item -Path $workDir -ItemType Directory | Out-Null
    $extension = [System.IO.Path]::GetExtension($url)
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($url)
    $scriptPath = "$workDir/$scriptName$extension"
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing

    Set-Content -Path $scriptPath -Value $response

    if ($extension -eq ".ps1") {
        powershell -ExecutionPolicy Bypass -File $scriptPath
    }
    elseif ($extension -eq ".bat" -or $extension -eq ".cmd") {
        cmd /c $scriptPath
    }
    else {
        Write-Host "Unsupported script type"
        Pause
    }
}

if (-not $Script) {
    $keys = $scriptUrls.Keys
    $index = 1
    $menu = @()
    foreach ($key in $keys) {
        $menu += ($index.ToString() + ". " + $key)
        $index++
    }
    $menu += "Q. quit`n"
    do {
        Clear-Host
        Write-Host "$name`n"
        Write-Host "Select a option:"
        $menu | ForEach-Object { Write-Host $_ }
        $userInput = Read-Host
        if ($userInput -eq "q") { exit }
        $index = [int]$userInput
        if ($index -gt 0 -and $index -le $keys.Count) {
            $array = @($scriptUrls.GetEnumerator())
            $url = $array[$index - 1].Value
            DownloadAndExecuteScript($url)
            break
        }
        else {
            Write-Host "Invalid option, please try again`n"
        }
    } while ($true)
}
elseif ($Script.StartsWith("http")) {
    DownloadAndExecuteScript($Script)
}
elseif ($scriptUrls.ContainsKey($Script)) {
    $url = $scriptUrls[$Script]
    DownloadAndExecuteScript($url)
}
else {
    Write-Host "Script not found"
}
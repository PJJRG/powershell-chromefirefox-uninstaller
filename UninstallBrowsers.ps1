function Get-FirefoxUninstallString {
    param([string]$displayName)
    
    $uninstallString = $null
    
    $uninstallKeys = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
    foreach ($key in $uninstallKeys) {
        if ($key.DisplayName -like $displayName) {
            $uninstallString = $key.UninstallString
            break
        }
    }

    if($null -eq $uninstallString)
    {
        $uninstallKeys = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
        foreach ($key in $uninstallKeys) {
            if ($key.DisplayName -like $displayName) {
                $uninstallString = $key.UninstallString
                break
            }
        }
    }
    
    return $uninstallString
}

function Get-ChromeUninstallString {
    param([string]$displayName)
    
    $uninstallString = $null
    
    $uninstallKeys = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
    foreach ($key in $uninstallKeys) {
        if ($key.DisplayName -like $displayName) {
            $chromeLocation = $key.InstallLocation
            $chromeVersion = $key.DisplayVersion
            $uninstallChromeString = $chromeLocation + "\" + $chromeVersion + "\Installer\setup.exe"
            $uninstallString = $uninstallChromeString
            break
        }
    }

    if($null -eq $uninstallString)
    {
        $uninstallKeys = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
        foreach ($key in $uninstallKeys) {
            if ($key.DisplayName -like $displayName) {
            $chromeLocation = $key.InstallLocation
            $chromeVersion = $key.DisplayVersion
            $uninstallChromeString = $chromeLocation + "\" + $chromeVersion + "\Installer\setup.exe"
            $uninstallString = $uninstallChromeString
            break
            }
        }
    }
    
    return $uninstallString
}

function Uninstall-Firefox {
    param([string]$uninstallString)
    
    if ($uninstallString) {
        try {
            Start-Process -FilePath $uninstallString -ArgumentList "/S" -Wait
            Write-Host "Uninstallation successful."
        } catch {
            Write-Host "Error during uninstallation."
        }
    }
}

function Uninstall-Chrome {
    param([string]$uninstallString,[switch]$live,[switch]$dev,[switch]$beta)
    
    if ($uninstallString) {
        try {
            
            if($live)
            {
                Start-Process -FilePath $uninstallString -ArgumentList "--uninstall --multi-install --chrome --system-level --verbose-logging --force-uninstall" -Wait
            }
            elseif($beta)
            {
                Start-Process -FilePath $uninstallString -ArgumentList "--uninstall --multi-install --chrome-beta --system-level --verbose-logging --force-uninstall" -Wait
            }
            elseif($dev)
            {
                Start-Process -FilePath $uninstallString -ArgumentList "--uninstall --multi-install --chrome-dev --system-level --verbose-logging --force-uninstall" -Wait                
            }
            Write-Host "Uninstallation successful."
        } catch {
            Write-Host "Error during uninstallation."
        }
    }
}

# Main script
# Firefox Live/Beta (can only have one installed at a time)
$firefoxUninstallString = Get-FirefoxUninstallString "*Mozilla Firefox*"
# Firefox Developer Edition
$firefoxDevUninstallString = Get-FirefoxUninstallString "*Firefox Developer*"
# Firefox Nightly
$firefoxNightlyUninstallString = Get-FirefoxUninstallString "Nightly*"
# Chrome
$chromeUninstallString = Get-ChromeUninstallString "Google Chrome"
# Chrome Beta
$chromeBetaUninstallString = Get-ChromeUninstallString "*Google Chrome Beta*"
# Chrome Dev
$chromeDevUninstallString = Get-ChromeUninstallString "*Google Chrome Dev*"

# Uninstalls Live/Beta (can only have one installed at a time)
Uninstall-Firefox $firefoxUninstallString
# Uninstalls Firefox Developer Edition
Uninstall-Firefox $firefoxDevUninstallString
# Uninstalls Firefox Nightly
Uninstall-Firefox $firefoxNightlyUninstallString
# Uninstalls Chrome Live
Uninstall-Chrome $chromeUninstallString -Live
# Uninstalls Chrome Beta
Uninstall-Chrome $chromeBetaUninstallString -Beta
# Uninstalls Chrome Dev
Uninstall-Chrome $chromeDevUninstallString -Dev

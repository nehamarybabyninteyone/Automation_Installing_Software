# PowerShell script to download, install MongoDB, MongoDB Compass, Visual Studio Code, and Node.js, and add them to PATH

# Function to download and install software with elevated permissions
function Install-Software {
    param (
        [string]$url,
        [string]$filePath,
        [string]$arguments,
        [string]$installerType = "msi"
    )

    Write-Output "Downloading $filePath from $url..."
    Invoke-WebRequest -Uri $url -OutFile $filePath

    Write-Output "Installing $filePath with elevated permissions..."
    if ($installerType -eq "exe") {
        Start-Process -FilePath $filePath -ArgumentList $arguments -Wait -Verb RunAs
    } else {
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -Verb RunAs
    }

    $exitCode = $LASTEXITCODE
    Write-Output "$filePath installation complete with exit code $exitCode."
    return $exitCode
}

# Ensure the destination directory exists
$installDir = "C:\Program Files"
if (-Not (Test-Path -Path $installDir)) {
    New-Item -Path $installDir -ItemType Directory -Force
}

# Define URLs for MongoDB, MongoDB Compass, Visual Studio Code, and Node.js
$mongoDbUrl = "https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-5.0.6-signed.msi"
$mongoDbInstaller = "$env:TEMP\mongodb-installer.msi"
$CompassUrl = 'https://compass.mongodb.com/api/v2/download/latest/compass/stable/windows'
$CompassExe = "$env:TEMP\compass-install.exe"
$vsCodeUrl = "https://aka.ms/win32-x64-user-stable"
$vsCodeInstaller = "$env:TEMP\vscode-installer.exe"
$nodeJsUrl = "https://nodejs.org/dist/v20.13.1/node-v20.13.1-x64.msi"
$nodeJsInstaller = "$env:TEMP\nodejs-installer.msi"

# Check if MongoDB is already installed
if (Test-Path "C:\Program Files\MongoDB\Server\5.0\bin\mongod.exe") {
    Write-Output "MongoDB is already installed."
} else {
    # Install MongoDB
    $mongoDbExitCode = Install-Software -url $mongoDbUrl -filePath $mongoDbInstaller -arguments "/i `"$mongoDbInstaller`" /quiet INSTALLLOCATION=`"C:\Program Files\MongoDB`"" -installerType "msi"
    if ($mongoDbExitCode -eq 0) {
        Write-Output "MongoDB installed successfully."

        # Add MongoDB to PATH environment variable
        $mongoDbBinPath = "C:\Program Files\MongoDB\Server\5.0\bin"
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        if ($currentPath -notlike "*$mongoDbBinPath*") {
            Write-Output "Adding MongoDB to PATH environment variable..."
            [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$mongoDbBinPath", [System.EnvironmentVariableTarget]::Machine)
            Write-Output "MongoDB added to PATH."
        } else {
            Write-Output "MongoDB is already in the PATH."
        }

        # Refresh the environment variables in the current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    } else {
        Write-Output "MongoDB installation failed with exit code $mongoDbExitCode."
    }

    # Clean up MongoDB installer
    Remove-Item -Path $mongoDbInstaller -ErrorAction Ignore
}

# Check if MongoDB Compass is already installed
if (Test-Path "C:\Program Files\MongoDB Compass\MongoDBCompass.exe") {
    Write-Output "MongoDB Compass is already installed."
} else {
    # Install MongoDB Compass
    $compassExitCode = Install-Software -url $CompassUrl -filePath $CompassExe -arguments "/S" -installerType "exe"
    if ($compassExitCode -eq 0) {
        Write-Output "MongoDB Compass installed successfully."
    } else {
        Write-Output "MongoDB Compass installation failed with exit code $compassExitCode."
    }

    # Clean up MongoDB Compass installer
    Remove-Item -Path $CompassExe -ErrorAction Ignore
}

# Check if Visual Studio Code is already installed
if (Test-Path "C:\Program Files\Microsoft VS Code\Code.exe") {
    Write-Output "Visual Studio Code is already installed."
} else {
    # Install Visual Studio Code
    $vsCodeExitCode = Install-Software -url $vsCodeUrl -filePath $vsCodeInstaller -arguments "/MERGETASKS=!runcode /VERYSILENT /DIR=`"C:\Program Files\Microsoft VS Code`"" -installerType "exe"
    if ($vsCodeExitCode -eq 0) {
        Write-Host "Visual Studio Code installed successfully."

        # Add Visual Studio Code to PATH environment variable
        $vsCodeBinPath = "C:\Program Files\Microsoft VS Code\bin"
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        if ($currentPath -notlike "*$vsCodeBinPath*") {
            Write-Host "Adding Visual Studio Code to PATH environment variable..."
            [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$vsCodeBinPath", [System.EnvironmentVariableTarget]::Machine)
            Write-Host "Visual Studio Code added to PATH."
        } else {
            Write-Host "Visual Studio Code is already in the PATH."
        }

        # Refresh the environment variables in the current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    } else {
        Write-Host "Visual Studio Code installation failed with exit code $vsCodeExitCode."
    }

    # Clean up Visual Studio Code installer
    Remove-Item -Path $vsCodeInstaller -ErrorAction Ignore
}

# Install Node.js
$nodeJsExitCode = Install-Software -url $nodeJsUrl -filePath $nodeJsInstaller -arguments "/i `"$nodeJsInstaller`" /quiet INSTALLDIR=`"C:\Program Files\nodejs`"" -installerType "msi"
if ($nodeJsExitCode -eq 0) {
    Write-Output "Node.js installed successfully."

    # Add Node.js to PATH environment variable
    $nodeJsBinPath = "C:\Program Files\nodejs"
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($currentPath -notlike "*$nodeJsBinPath*") {
        Write-Output "Adding Node.js to PATH environment variable..."
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$nodeJsBinPath", [System.EnvironmentVariableTarget]::Machine)
        Write-Output "Node.js added to PATH."
    } else {
        Write-Output "Node.js is already in the PATH."
    }

    # Refresh the environment variables in the current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Output "Node.js installation failed with exit code $nodeJsExitCode."
}

# Clean up Node.js installer
Remove-Item -Path $nodeJsInstaller -ErrorAction Ignore

Write-Host "Installation script complete."

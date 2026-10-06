# ------------------------------------------------------------------
# T6A Control Flow - Windows setup script
# Run this in PowerShell (not Command Prompt):
#
#   irm https://raw.githubusercontent.com/JValentineC/t6a-control-flow/main/setup.ps1 | iex
#
# What it does:
#   1. Checks that Git and Python are installed
#   2. Makes sure Git knows your name and email (for commits)
#   3. Checks that you made your own copy of the repo on GitHub
#   4. Clones YOUR copy into the folder PowerShell is currently in
#      (cd to where you keep your code first, e.g. cd ~\Documents\apps)
#   5. Opens it in VS Code
# ------------------------------------------------------------------

& {
    $RepoName     = "t6a-control-flow"
    $TemplatePage = "https://github.com/JValentineC/t6a-control-flow/generate"

    function Say($msg)  { Write-Host $msg -ForegroundColor Cyan }
    function Good($msg) { Write-Host "  OK  $msg" -ForegroundColor Green }
    function Stop-Setup($msg) {
        Write-Host ""
        Write-Host "STOPPED: $msg" -ForegroundColor Red
        Write-Host "No problem - raise your hand and a facilitator will help." -ForegroundColor Yellow
    }

    Write-Host ""
    Say "=== T6A Control Flow setup ==="
    Write-Host ""

    # --- 1. Git installed? ---------------------------------------
    Say "Step 1: Checking for Git..."
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Stop-Setup "Git is not installed. Install it from https://git-scm.com/download/win, then close and reopen PowerShell and run this again."
        return
    }
    Good (git --version)

    # --- 2. Python installed? ------------------------------------
    # On Windows, 'python' can be a fake shortcut to the Microsoft Store,
    # so we check that it actually prints a Python 3 version.
    Say "Step 2: Checking for Python..."
    $PythonCmd = $null
    foreach ($candidate in @("python", "py")) {
        if (Get-Command $candidate -ErrorAction SilentlyContinue) {
            $version = (& $candidate --version 2>&1) | Out-String
            if ($version -match "Python 3") {
                $PythonCmd = $candidate
                Good "$($version.Trim())  (run your code with: $candidate kata1.py)"
                break
            }
        }
    }
    if (-not $PythonCmd) {
        Stop-Setup "Python 3 is not installed. Install it from https://www.python.org/downloads/ and CHECK the box 'Add python.exe to PATH'. Then reopen PowerShell and run this again."
        return
    }

    # --- 3. Git name and email -----------------------------------
    Say "Step 3: Checking your Git name and email..."
    $gitName  = git config --global user.name
    $gitEmail = git config --global user.email
    if (-not $gitName) {
        $gitName = Read-Host "  Type your full name (shows on your commits)"
        git config --global user.name "$gitName"
    }
    if (-not $gitEmail) {
        $gitEmail = Read-Host "  Type the email you use for GitHub"
        git config --global user.email "$gitEmail"
    }
    Good "Commits will be signed as: $gitName <$gitEmail>"

    # --- 4. Their own copy exists on GitHub? ---------------------
    Say "Step 4: Finding your copy of the repo on GitHub..."
    $GitHubUser = (Read-Host "  Type your GitHub username").Trim()
    $RepoPage   = "https://github.com/$GitHubUser/$RepoName"

    function Test-RepoExists {
        try {
            Invoke-WebRequest -Uri $RepoPage -Method Head -UseBasicParsing -ErrorAction Stop | Out-Null
            return $true
        } catch { return $false }
    }

    if (-not (Test-RepoExists)) {
        Write-Host ""
        Write-Host "  You don't have your own copy yet. Opening GitHub for you..." -ForegroundColor Yellow
        Write-Host "  In the browser:" -ForegroundColor Yellow
        Write-Host "    - Owner: your account" -ForegroundColor Yellow
        Write-Host "    - Repository name: $RepoName  (keep it exactly like this)" -ForegroundColor Yellow
        Write-Host "    - Choose Public" -ForegroundColor Yellow
        Write-Host "    - Click 'Create repository'" -ForegroundColor Yellow
        Start-Process $TemplatePage
        Read-Host "  Press Enter here AFTER you click 'Create repository'"
        Start-Sleep -Seconds 3
        if (-not (Test-RepoExists)) {
            Stop-Setup "Still can't find $RepoPage. Check the username spelling and that the repo is named $RepoName and set to Public."
            return
        }
    }
    Good "Found $RepoPage"

    # --- 5. Clone into the folder PowerShell is in right now -----
    Say "Step 5: Downloading your repo..."
    $Here = (Get-Location).Path
    if ($Here -like "*\Windows\System32*") {
        Stop-Setup "PowerShell is in a Windows system folder. Run: mkdir ~\Documents\apps -Force; cd ~\Documents\apps  then run the setup command again."
        return
    }
    $Dest = Join-Path $Here $RepoName
    Write-Host "  Your repo will be downloaded to: $Dest" -ForegroundColor Yellow
    $answer = Read-Host "  Is that where you want your code? (y/n)"
    if ($answer -notmatch "^[yY]") {
        Stop-Setup "Use cd to go to the folder you want (for example: cd ~\Documents\apps), then run the setup command again."
        return
    }

    if (Test-Path $Dest) {
        Good "Folder already exists, skipping download: $Dest"
    } else {
        git clone "$RepoPage.git" "$Dest"
        if ($LASTEXITCODE -ne 0) {
            Stop-Setup "The download (git clone) failed. Read the red message above."
            return
        }
        Good "Downloaded to $Dest"
    }

    # --- 6. Open in VS Code --------------------------------------
    Say "Step 6: Opening your project..."
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code "$Dest"
        Good "Opened in VS Code"
    } else {
        Start-Process explorer.exe $Dest
        Write-Host "  VS Code's 'code' command wasn't found, so the folder opened in File Explorer." -ForegroundColor Yellow
        Write-Host "  Open VS Code and use File > Open Folder to open it." -ForegroundColor Yellow
    }

    # --- Done ----------------------------------------------------
    Write-Host ""
    Write-Host "=== You're ready! ===" -ForegroundColor Green
    Write-Host "In the VS Code terminal, your cycle for every kata is:"
    Write-Host "  $PythonCmd kata1.py                                (run it)"
    Write-Host "  git add kata1.py"
    Write-Host "  git commit -m `"scaffold loop structure`"         (commit 1)"
    Write-Host "  git commit -am `"added condition check`"          (commit 2)"
    Write-Host "  git commit -am `"refactored names for clarity`"   (commit 3)"
    Write-Host "  git push                                         (send to GitHub)"
    Write-Host ""
}
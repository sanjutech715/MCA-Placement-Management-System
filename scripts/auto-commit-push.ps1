$ErrorActionPreference = "Stop"
$pollSeconds = 10

while ($true) {
    $changes = git status --porcelain

    if ($changes) {
        git add -A
        $commitMessage = "Auto-commit: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git commit -m $commitMessage

        if ($LASTEXITCODE -eq 0) {
            git push
        }
    }

    Start-Sleep -Seconds $pollSeconds
}

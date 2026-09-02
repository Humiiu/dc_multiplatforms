$lines = Get-Content "STATUS.md"
Write-Output "=== Line 6 (Tech Stack) ==="
Write-Output $lines[5]
Write-Output ""
Write-Output "=== Line 18 (Authentication) ==="
Write-Output $lines[17]
Write-Output "=== Line 19 ==="
Write-Output $lines[18]
Write-Output "=== Line 20 ==="
Write-Output $lines[19]
Write-Output "=== Line 21 ==="
Write-Output $lines[20]
Write-Output ""
Write-Output "=== Line 22 (Core infra) ==="
Write-Output $lines[21]
Write-Output ""
Write-Output "=== Line 24 (Services) ==="
Write-Output $lines[23]
Write-Output ""
Write-Output "=== Line 38 (Auth provider) ==="
Write-Output $lines[37]
Write-Output ""
Write-Output "=== Verify files deleted ==="
if (Test-Path "lib\core\firebase.dart") { Write-Output "FAIL: firebase.dart still exists" } else { Write-Output "OK: firebase.dart deleted" }
if (Test-Path "lib\core\DELETE_ME.txt") { Write-Output "FAIL: DELETE_ME.txt still exists" } else { Write-Output "OK: DELETE_ME.txt deleted" }

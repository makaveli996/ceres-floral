param(
  [Parameter(Mandatory=$true)][string]$Domain,
  [string]$Ip = "127.0.0.1"
)

function Test-Admin {
  $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
$line = "$Ip`t$Domain"

if (-not (Test-Admin)) {
  Write-Host "Not running as Administrator. Re-launching elevated..."
  $argsList = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", "`"$PSCommandPath`"",
    "-Domain", "`"$Domain`"",
    "-Ip", "`"$Ip`""
  )
  Start-Process PowerShell -Verb RunAs -ArgumentList $argsList
  exit
}

$hostsContent = Get-Content $hostsPath -ErrorAction Stop

if ($hostsContent | Select-String -Pattern "^\s*$([regex]::Escape($Ip))\s+$([regex]::Escape($Domain))\s*$" -Quiet) {
  Write-Host "OK: Entry already exists: $line"
} else {
  Add-Content -Path $hostsPath -Value $line
  Write-Host "OK: Added entry: $line"
}

try { ipconfig /flushdns | Out-Null } catch {}

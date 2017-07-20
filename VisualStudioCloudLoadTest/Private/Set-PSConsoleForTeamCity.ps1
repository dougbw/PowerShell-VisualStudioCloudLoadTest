function Set-PSConsoleForTeamCity {
  if (Test-Path env:TEAMCITY_VERSION) {
    try {
      $rawUI = (Get-Host).UI.RawUI
      $m = $rawUI.MaxPhysicalWindowSize.Width
      $rawUI.BufferSize = New-Object Management.Automation.Host.Size ([Math]::max($m, 500), $rawUI.BufferSize.Height)
      $rawUI.WindowSize = New-Object Management.Automation.Host.Size ($m, $rawUI.WindowSize.Height)
    } catch {}
  }
}
# powershell completion for k3d                                  -*- shell-script -*-

function __k3d_debug {
  if ($env:BASH_COMP_DEBUG_FILE) {
    "$args" | Out-File -Append -FilePath "$env:BASH_COMP_DEBUG_FILE"
  }
}

filter __k3d_escapeStringWithSpecialChars {
  $_ -replace '\s|#|@|\$|;|,|''|\{|\}|\(|\)|"|`|\||<|>|&', '`$&'
}

[scriptblock]${__k3dCompleterBlock} = {
  param(
    $WordToComplete,
    $CommandAst,
    $CursorPosition
  )

  $Command = $CommandAst.CommandElements
  $Command = "$Command"

  __k3d_debug ""
  __k3d_debug "========= starting completion logic =========="
  __k3d_debug "WordToComplete: $WordToComplete Command: $Command CursorPosition: $CursorPosition"

  if ($Command.Length -gt $CursorPosition) {
    $Command = $Command.Substring(0, $CursorPosition)
  }

  __k3d_debug "Truncated command: $Command"

  $ShellCompDirectiveError = 1
  $ShellCompDirectiveNoSpace = 2
  $ShellCompDirectiveNoFileComp = 4
  $ShellCompDirectiveFilterFileExt = 8
  $ShellCompDirectiveFilterDirs = 16
  $ShellCompDirectiveKeepOrder = 32

  $Program, $Arguments = $Command.Split(" ", 2)

  $RequestComp = "$Program __complete $Arguments"
  __k3d_debug "RequestComp: $RequestComp"

  if ($WordToComplete -ne "") {
    $WordToComplete = $Arguments.Split(" ")[-1]
  }

  __k3d_debug "New WordToComplete: $WordToComplete"

  $IsEqualFlag = $WordToComplete -like "--*=*"
  if ($IsEqualFlag) {
    __k3d_debug "Completing equal sign flag"
    $Flag, $WordToComplete = $WordToComplete.Split("=", 2)
  }

  if ($WordToComplete -eq "" -and (-not $IsEqualFlag)) {
    __k3d_debug "Adding extra empty parameter"

    if (
      $PSVersionTable.PsVersion -lt [version]'7.2.0' -or
      (
        $PSVersionTable.PsVersion -lt [version]'7.3.0' -and
        -not [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")
      ) -or
      (
        (
          $PSVersionTable.PsVersion -ge [version]'7.3.0' -or
          [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")
        ) -and
        $PSNativeCommandArgumentPassing -eq 'Legacy'
      )
    ) {
      $RequestComp = "$RequestComp" + ' `"`"'
    }
    else {
      $RequestComp = "$RequestComp" + ' ""'
    }
  }

  __k3d_debug "Calling $RequestComp"
  ${env:K3D_ACTIVE_HELP} = 0

  Invoke-Expression -OutVariable out "$RequestComp" 2>&1 | Out-Null

  [int]$Directive = $Out[-1].TrimStart(':')
  if ($Directive -eq "") {
    $Directive = 0
  }

  __k3d_debug "The completion directive is: $Directive"

  $Out = $Out | Where-Object { $_ -ne $Out[-1] }
  __k3d_debug "The completions are: $Out"

  if (($Directive -band $ShellCompDirectiveError) -ne 0) {
    __k3d_debug "Received error from custom completion go code"
    return
  }

  $Longest = 0
  [array]$Values = $Out | ForEach-Object {
    $Name, $Description = $_.Split("`t", 2)
    __k3d_debug "Name: $Name Description: $Description"

    if ($Longest -lt $Name.Length) {
      $Longest = $Name.Length
    }

    if (-not $Description) {
      $Description = " "
    }

    @{
      Name = "$Name"
      Description = "$Description"
    }
  }

  $Space = " "
  if (($Directive -band $ShellCompDirectiveNoSpace) -ne 0) {
    __k3d_debug "ShellCompDirectiveNoSpace is called"
    $Space = ""
  }

  if (
    (($Directive -band $ShellCompDirectiveFilterFileExt) -ne 0) -or
    (($Directive -band $ShellCompDirectiveFilterDirs) -ne 0)
  ) {
    __k3d_debug "ShellCompDirectiveFilterFileExt ShellCompDirectiveFilterDirs are not supported"
    return
  }

  $Values = $Values | Where-Object {
    $_.Name -like "$WordToComplete*"

    if ($IsEqualFlag) {
      __k3d_debug "Join the equal sign flag back to the completion value"
      $_.Name = $Flag + "=" + $_.Name
    }
  }

  if (($Directive -band $ShellCompDirectiveKeepOrder) -eq 0) {
    $Values = $Values | Sort-Object -Property Name
  }

  if (($Directive -band $ShellCompDirectiveNoFileComp) -ne 0) {
    __k3d_debug "ShellCompDirectiveNoFileComp is called"

    if ($Values.Length -eq 0) {
      ""
      return
    }
  }

  $Mode = (Get-PSReadLineKeyHandler | Where-Object { $_.Key -eq "Tab" }).Function
  __k3d_debug "Mode: $Mode"

  $Values | ForEach-Object {
    $comp = $_

    switch ($Mode) {
      "Complete" {
        if ($Values.Length -eq 1) {
          __k3d_debug "Only one completion left"

          [System.Management.Automation.CompletionResult]::new(
            $($comp.Name | __k3d_escapeStringWithSpecialChars) + $Space,
            "$($comp.Name)",
            'ParameterValue',
            "$($comp.Description)"
          )
        }
        else {
          while ($comp.Name.Length -lt $Longest) {
            $comp.Name = $comp.Name + " "
          }

          if ($comp.Description -eq " ") {
            $Description = ""
          }
          else {
            $Description = "  ($($comp.Description))"
          }

          [System.Management.Automation.CompletionResult]::new(
            "$($comp.Name)$Description",
            "$($comp.Name)$Description",
            'ParameterValue',
            "$($comp.Description)"
          )
        }
      }

      "MenuComplete" {
        [System.Management.Automation.CompletionResult]::new(
          $($comp.Name | __k3d_escapeStringWithSpecialChars) + $Space,
          "$($comp.Name)",
          'ParameterValue',
          "$($comp.Description)"
        )
      }

      Default {
        [System.Management.Automation.CompletionResult]::new(
          $($comp.Name | __k3d_escapeStringWithSpecialChars),
          "$($comp.Name)",
          'ParameterValue',
          "$($comp.Description)"
        )
      }
    }
  }
}

Register-ArgumentCompleter -CommandName 'k3d' -ScriptBlock ${__k3dCompleterBlock}
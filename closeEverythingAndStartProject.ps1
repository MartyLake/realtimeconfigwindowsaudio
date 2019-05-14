# Hello, here is the list of customization points
# TODO


# From https://stackoverflow.com/questions/37648262/using-powershell-script-to-kill-process-but-access-deined -> go admin
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
$myWindowsPrincipal.IsInRole($adminRole)

# From https://stackoverflow.com/questions/12801563/powershell-setforegroundwindow -> create a setforegroundwindow method
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class SFW {
     [DllImport("user32.dll")]
     [return: MarshalAs(UnmanagedType.Bool)]
     public static extern bool SetForegroundWindow(IntPtr hWnd);
  }
"@

# example
# $h =  (get-process NOTEPAD).MainWindowHandle # just one notepad must be opened!
#[SFW]::SetForegroundWindow($h)

# Originaly from https://stackoverflow.com/questions/9725629/how-to-close-all-windows
# Close all windows
while ($true) {
    $process_list = (get-process | ? { $_.mainwindowtitle -ne "" -and $_.processname -ne "cmd" -and $_.processname -ne "powershell" -and $_.processname -notmatch "Ableton.*" } )
    $process_list_measure = $process_list | measure
    if ($process_list_measure.Count -eq 0) {break}
    Write-Host "Still $($process_list_measure.Count) processes to close :"
    $process_list | % { Write-Host " * $($_.processname) :: $($_.mainwindowtitle)" }
    $process_list | % { [SFW]::SetForegroundWindow($_.MainWindowHandle) -and $_.CloseMainWindow() }
    # When one window is blocked in a modal, we want to let the user handle the closing and indicates that the script can continue
    Read-Host -Prompt "Press Enter to continue"
}
# Close all explorer
(New-Object -comObject Shell.Application).Windows() | foreach-object {$_.quit()}
Write-Host "All windows closed gracefully"

# From http://blog.danskingdom.com/allow-others-to-run-your-powershell-scripts-from-a-batch-file-they-will-love-you-for-it/
# If running in the console, wait for input before closing.
if ($Host.Name -eq "ConsoleHost")
{ 
    Write-Host "Press any key to continue..."
    $Host.UI.RawUI.FlushInputBuffer()   # Make sure buffered input doesn't "press a key" and skip the ReadKey().
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}

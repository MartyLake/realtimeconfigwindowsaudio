### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = "C:\Users\Matthieu\AppData\Roaming\Ableton\Live Reports"
    $watcher.Filter = "*.zip"
    $watcher.IncludeSubdirectories = $false
    $watcher.EnableRaisingEvents = $true  

### DEFINE ACTIONS AFTER AN EVENT IS DETECTED
    $action = { $path = $Event.SourceEventArgs.FullPath
                $changeType = $Event.SourceEventArgs.ChangeType
                $logline = "$(Get-Date), $changeType, $path"
                Write-Host "$logline" -fore green
                Add-content "C:\Users\Matthieu\AppData\Roaming\Ableton\Live Reports\log.txt" -value $logline
                Copy-Item "$path" -Destination "D:\Saved\2019\Ableton\Crash report"
              }    
### DECIDE WHICH EVENTS SHOULD BE WATCHED 
    $registered_action = Register-ObjectEvent $watcher "Created" -Action $action
#    Register-ObjectEvent $watcher "Changed" -Action $action
#    Register-ObjectEvent $watcher "Deleted" -Action $action
#    Register-ObjectEvent $watcher "Renamed" -Action $action
    while ($true) {
        sleep 5
    }

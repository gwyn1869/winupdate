# 1. Define the action (What to run)
# We use -WindowStyle Hidden to test if the EDR flags hidden execution.
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -Command 'Write-Output Check' "

# 2. Define the trigger (When to run)
# 'AtLogon' is the standard for persistence.
$Trigger = New-ScheduledTaskTrigger -AtLogOn

# 3. Define Settings (The "Stealth" flags)
# -Hidden makes the task invisible in the standard Task Scheduler UI.
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden

# 4. Register the task (The "Placement")
# We use a path that looks like a legitimate Windows Cleanup task.
Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName "Microsoft\Windows\LanguageComponents\Cleanup" -Description "Maintains language component health." -Force

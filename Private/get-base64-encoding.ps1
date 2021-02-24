function get-base64-encoding {
param (
    [Parameter(Mandatory = $true)]
    [string]$message
)

$Bytes = [System.Text.Encoding]::Unicode.GetBytes($message)
$EncodedText =[Convert]::ToBase64String($Bytes)
return $EncodedText

}
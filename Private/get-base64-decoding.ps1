function get-base64-decoding {
param (
    [Parameter(Mandatory = $true)]
    [string]$message
)

$decodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($message))
return $decodedText

}
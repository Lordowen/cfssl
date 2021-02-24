function get-hmac-sha256-encoding {
param (
    [Parameter(Mandatory = $true)]
    [string]$message,

    [Parameter(Mandatory = $true)]
    [string]$secret
)

#$message = 'Message'
#$secret = 'secret'

#$message =  '' + $message + ''

$hmacsha = New-Object System.Security.Cryptography.HMACSHA256
$hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)
$signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
$signature = [Convert]::ToBase64String($signature)

#echo $signature
# Do we get the expected signature?
#echo ($signature -eq 'qnR8UCqJggD55PohusaBNviGoOJ67HC6Btry4qXLVZc=')

return $signature

}
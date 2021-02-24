function Get-CfsslCsrAuthSign {
param(
    [Parameter(Mandatory = $false)]
    [String]$cfssladdress = "https://192.168.0.121",
 
    [Parameter(Mandatory = $false)]
    [int]$cfsslport = 8888,
 
    [Parameter(Mandatory = $true)]
    [string]$csrfile,

    [Parameter(Mandatory = $false)]
    [ValidateSet('rdp','server','client')]
    [string]$certprofile = "server",

    [Parameter(Mandatory = $true)]
    [string]$apikey = "Letsdothis",

    [Parameter(Mandatory=$true)]
    [string]$DestinationFilePath = "c:\temp"

)

if ("TrustAllCertsPolicy" -as [type]) {} else {
        Add-Type "using System.Net;using System.Security.Cryptography.X509Certificates;public class TrustAllCertsPolicy : ICertificatePolicy {public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {return true;}}"
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

update-typedata .\Private\my.types.ps1xml


. .\Private\hexfunctions.ps1

# we will always use authsign function.
$function = "authsign"

# building up the cfssl address uri, port, api call and function.
$cfssladdress_uri = $cfssladdress + ":" + $cfsslport + "/api/v1/cfssl/" + $function

# read content of CSR file
$readfile = (Get-Content -Path $csrfile)

# Must remove spaces in CSR file
$csr = $null
Foreach ($line in $readfile) 
{
   $line = $line + "\n" 
   $csr += $line -join ' '    
}

# building up the JSON with csr.
$innercsr = '"certificate_request":"' + $csr + '"'

# profile might change between RDP, server, 
$cfsslprofile = '"profile":"' + $certprofile + '"'
$innerbody = '{' + $innercsr + "," + $cfsslprofile + '}'

# base64 encoding av innerbody:
$innerbody_base64 = $innerbody.tobase64utf8 # OK

# Remove newline characters.
$innerbody_base64 = $innerbody_base64 -replace "`n",""  # OK
#Write-Host "innerbody_base64 without newline: " $innerbody_base64

# get hex encode of api key: hex_encoded_onboarding_key
$hexkey = stringtohex $apikey # OK
Write-Host "Hexkey of apikey:" $hexkey

# Må lage HMAC SHA256 av CSR først.

#$base64_token = get-hmac-sha256-encoding -message $innerbody -secret $apikey 

# initializing a new HMACSHA256 object
$hmacsha = New-Object System.Security.Cryptography.HMACSHA256

# Converting to ASCII characterset the APIkey
$hmacsha.key = [Text.Encoding]::ASCII.GetBytes($apikey)

# base64 token 
$base64_token = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($innerbody))
$base64_token = [Convert]::ToBase64String($base64_token)

# remove newline
$base64_token = $base64_token -replace "`n","" # OK

# the final json body to be sent to cfssl authsign function
$auth_req = '{"token":"' + $base64_token + '","request":"' + $innerbody_base64 + '"}' 

# v3 wwith auth key
Write-Host Invoke-WebRequest -Method Post -Body $auth_req -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json
$result = Invoke-WebRequest -Method Post -Body $auth_req -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json

# v2 working
#Write-Host Invoke-WebRequest -Method Post -Body $csr -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json
#$result = Invoke-WebRequest -Method Post -Body $csr -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json

# Working call:
#Write-Host Invoke-WebRequest -Method Post -Body "{$csr2}" -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json
#$result = Invoke-WebRequest -Method Post -Body "{$csr2}" -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json


write-host $result.result.certificate
out-file -FilePath $DestinationFilePath + "\" + $(get-date -f yyyy-MM-dd)".cer" -InputObject $result.result.certificate

}
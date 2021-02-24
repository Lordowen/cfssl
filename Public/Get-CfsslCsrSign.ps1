function Get-CfsslCsrSign {
param(
 
    [Parameter(Mandatory = $false)]
    [String]$cfsslfqdn = "https://cfsslserver:8888/api/v1/cfssl/",
 
    [Parameter(Mandatory = $true)]
    [int]$cfsslport = 8888,
 
#    [Parameter(Mandatory = $true)]
#    [ValidateSet('sign','newkey')]
#    [ValidateSet('new-authz','new-cert')]
#    [string]$function = 'sign',

    [Parameter(Mandatory = $true)]
    [string]$csrfile, 

    [Parameter(Mandatory = $false)]
    [string]$certfile = "C:\temp\$(get-date -f yyyy-MM-dd).cer"
  
)

# $cfssladdress_uri = $cfssladdress + ":" + $cfsslport + "/api/v1/cfssl/" + $function
# using the sign api endpoint without authentication.
$function = 'sign'

$cfssladdress_uri = $cfsslfqdn + ":" + $cfsslport + "/api/v1/cfssl/" + $function

write-host $cfssladdress_uri

#$cfssladdress = "cfsslserver:8888/api/v1/cfssl/sign"
# Profile: add profile in body: "prifile:server" or "profile:rdp" or "profile:splunk"  

$readfile = (Get-Content -Path $csrfile)

# Must remove spaces in CSR file
$csr = $null
Foreach ($line in $readfile) 
{
   $line = $line + "\n" 
   $csr += $line -join ' '    
}

$csr = '{"certificate_request": "' + $csr + '"}'

Write-Host Invoke-WebRequest -Method Post -Body $csr -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json
$result = Invoke-WebRequest -Method Post -Body $csr -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json

# Working call:
#Write-Host Invoke-WebRequest -Method Post -Body "{$csr2}" -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json
#$result = Invoke-WebRequest -Method Post -Body "{$csr2}" -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json

write-host $result.result.certificate
out-file -FilePath $certfile -InputObject $result.result.certificate

}
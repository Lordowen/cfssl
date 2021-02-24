function New-CfsslAPICert {
param(
 
    [Parameter(Mandatory = $false)]
    [String]$cfssladdress = "https://10.109.39.83:8888/api/v1/cfssl/newcert",
 
    [Parameter(Mandatory = $false)]
    [string]$canonicalnames = "localhost.localdomain.no",

    [Parameter(Mandatory = $false)]
    [string]$alternatenames = "localhost.localdomain.no,localhost,127.0.0.1"
)

$body = @{
    request = @{
		key = @{
			algo = 'rsa'
			size = 2048
		}
		hosts = @($alternatenames)
		CN = $canonicalnames 
        }
}
 

$path = Get-Location
write-host $path.Path

$header = @{
 "Accept"="application/json"
 "Content-Type"="application/json"
} 



$bod = $body | ConvertTo-Json

try
{
    # $response = Invoke-restMethod -UseBasicParsing $cfssladdress -ContentType "application/json" -Method POST -Body $bod -ErrorAction Stop
    $response = Invoke-WebRequest -UseBasicParsing -uri $cfssladdress -ContentType "application/json" -Method POST -Body $bod -ErrorAction Stop
} catch 

{
    Write-Output "Error connecting to CFSSL, or error with the response:" $Error 
    exit
}

$response = $response | ConvertFrom-Json

$certoutfile = $path.Path + "\ACME_$(get-date -f yyyy-MM-dd).cer"
$keyoutfile = $path.Path + "\ACME_$(get-date -f yyyy-MM-dd).key"

write-host $response.result.certificate

out-file -FilePath $certoutfile -InputObject $response.result.certificate

write-host $response.result.private_key

out-file -FilePath $keyoutfile -InputObject $response.result.private_key

}
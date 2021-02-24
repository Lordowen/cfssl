function Get-CfsslCerts {
param(
    [Parameter(Mandatory = $false)]
    [String]$cfssladdress = "https://192.168.0.121",
 
    [Parameter(Mandatory = $false)]
    [int]$cfsslport = 8888,

    [Parameter(Mandatory = $false)]
    [string]$outfolder = "c:\temp"

)

if ("TrustAllCertsPolicy" -as [type]) {} else {
        Add-Type "using System.Net;using System.Security.Cryptography.X509Certificates;public class TrustAllCertsPolicy : ICertificatePolicy {public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {return true;}}"
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

$cfssladdress_uri = $cfssladdress + ":" + $cfsslport

$webRequest = [Net.WebRequest]::Create($cfssladdress_uri)

try { $webRequest.GetResponse() } catch {}
$cert = $webRequest.ServicePoint.Certificate
$bytes = $cert.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert)
set-content -value $bytes -encoding byte -path $outfolder

write-host $bytes

Write-Host Invoke-WebRequest -Method Post -Body $csr -Uri $cfssladdress_uri -Verbose | ConvertFrom-Json

}

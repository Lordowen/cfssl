function Get-CfsslChain {
#$url = "https://192.168.0.121:8888"
$url = "https://www.vg.no:443"

if ("TrustAllCertsPolicy" -as [type]) {} else {
        Add-Type "using System.Net;using System.Security.Cryptography.X509Certificates;public class TrustAllCertsPolicy : ICertificatePolicy {public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {return true;}}"
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

$WebRequest = [Net.WebRequest]::CreateHttp($url)
$WebRequest.AllowAutoRedirect = $true
$chain = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Chain

#[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

#Request website
try {$Response = $WebRequest.GetResponse()}
catch {write-host ""}

#Creates Certificate
$Certificate = $WebRequest.ServicePoint.Certificate.Handle
$Issuer = $WebRequest.ServicePoint.Certificate.Issuer
$Subject = $WebRequest.ServicePoint.Certificate.Subject

#Build chain
$chain.Build($Certificate)
write-host $chain.ChainElements.Count #This returns "1" meaning none of the CA certs are included.
write-host $chain.ChainElements[0].Certificate
write-host $chain.ChainElements[1].Certificate.IssuerName.Name
        
[Net.ServicePointManager]::ServerCertificateValidationCallback = $null

}
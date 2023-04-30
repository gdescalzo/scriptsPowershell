<#
https://estadisticasbcra.com/api/documentacion

Authorization: BEARER eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MDcwMTI5MzcsInR5cGUiOiJleHRlcm5hbCIsInVzZXIiOiJnZGVzY2Fsem9AZ21haWwuY29tIn0.sGMDe4yXQhhsuJS9-3_SbUO-1GXSXCw1QQwPk3ywrubdSi6QGhUxnkM0aLWg4kBPJVgKgiHS6ptZVrkh_xBqlg

eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MDcwMTI5MzcsInR5cGUiOiJleHRlcm5hbCIsInVzZXIiOiJnZGVzY2Fsem9AZ21haWwuY29tIn0.sGMDe4yXQhhsuJS9-3_SbUO-1GXSXCw1QQwPk3ywrubdSi6QGhUxnkM0aLWg4kBPJVgKgiHS6ptZVrkh_xBqlg


Expira: 2024-02-04 00:15:37


#>

$token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MDcwMTI5MzcsInR5cGUiOiJleHRlcm5hbCIsInVzZXIiOiJnZGVzY2Fsem9AZ21haWwuY29tIn0.sGMDe4yXQhhsuJS9-3_SbUO-1GXSXCw1QQwPk3ywrubdSi6QGhUxnkM0aLWg4kBPJVgKgiHS6ptZVrkh_xBqlg"
$headers = @{ "Authorization" = "Bearer $token" }
$url = "https://api.estadisticasbcra.com/usd"
$response = Invoke-WebRequest -Uri $url -Headers $headers
if ($response.Content -match '^\s*{') {
    $price = ($response.Content | ConvertFrom-Json).dolar.precio
    Write-Output "The price of the Argentina blue dollar is $($price) ARS"
}
else {
    Write-Output "Error: response is not in a valid JSON format."
}
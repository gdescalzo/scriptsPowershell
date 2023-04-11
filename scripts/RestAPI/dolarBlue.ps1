<#
market-scrll-2
#$parseRequest    = $downloadRequest.ParsedHtml.getElementById('market-scrll-2') | Select innerText
#$parseCompra = $parseRequest.innerText.Replace('Compra','Compra')
#$parseVenta = $parseCompra.innerText.Replace('Venta',' Venta')
#$parseCompra
#$parseRequest    = $downloadRequest.ParsedHtml.getElementById('market-scrll-2').textContent
#$parseRequest    = $downloadRequest.ParsedHtml.getElementById('market-scrll-2') | Select innerText
#$out = $splitRequest | foreach {if ($_ -ne 'DÓLAR*' ) {$_ +'"'}}
#$out = $splitRequest | foreach {if ($_ | select-string -pattern 'DÓLAR*' -notmatch ) {$_ +'"'}}
#>
<#
{
    "Cotizacion":{
        "DÓLAR BNA": {
            "Compra": "$149,25",
            "Venta" : "$157,250,00%"
        },
        "DÓLAR BLUE": {
            "Compra": "$286,00",
            "Venta" : "$290,00-0,34%"
        },
        "DÓLAR TURISTA" : {
            "Venta": "$275,190,00%"
        },
        "DÓLAR MAYORISTA" : {
            "Compra": "$151,44",
            "Venta": "$151,640,22%"
        },
        "DÓLAR CDO C/LIQ": {
            "Compra": "$287,15",
            "Venta": "$319,31-0,04%"
        },
        "DÓLAR MEP Contado": {
            "Compra": "$295,14",
            "Venta": "$296,06-0,32%"
        }
    }
}


#>
<#
$downloadURL         = "https://www.cronista.com/MercadosOnline/dolar.html"
$downloadRequest     = Invoke-WebRequest -uri $downloadURL
$parseRequest        = $downloadRequest.ParsedHtml.getElementById('market-scrll-2')

$requestJson         = $parseRequest.outerText | ConvertTo-Json

$replaceCompra       = $requestJson.Replace('Compra','\r\nCompra:')
$replaceVenta        = $replaceCompra.Replace('Venta','\r\nVenta:')
$replaceActualizado  = $replaceVenta.Replace('Actualizado','\r\n"Actualizado')
$replaceActualizado2 = $replaceActualizado.Replace(': ','":"')
$replaceRequest      = $replaceActualizado2.Replace('\r\n',';')
$replaceRequest1     = $replaceRequest.Replace(':;','":"')

$splitRequest        = $replaceRequest1.Split(';')  

$out = $splitRequest | foreach {'"'+$_ +'"'}
$out1 = $out | select-string -pattern 'Actualizado' -notmatch 

$out2 = '{'+$out1+'}' -replace ('" "','";"') -replace ('""','"') | ConvertFrom-String -Delimiter [';']
$out2

$jsonArray = @(

    $out2.P1   = @(
        Compra = $out2.p2.Replace('"Compra":','') 
        Venta  = $out2.p3.Replace('"Venta":','')
    )
    $out2.P4   = @(
        Compra = $out2.p5.Replace('"Compra":','') 
        Venta  = $out2.p6.Replace('"Venta":','')
    )
    
)

$jsonArray

#>

$downloadURL = "https://www.cronista.com/MercadosOnline/dolar.html"


$downloadRequest = Invoke-WebRequest -uri $downloadURL -UseBasicParsing -Body


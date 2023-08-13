$response = Invoke-RestMethod 'https://www.dolarsi.com/api/api.php?type=valoresprincipales' -Method 'GET' 

foreach ($r in $response) {
    
    if ($r.casa.nombre -eq 'Dolar Blue') {         
        $nombre = $r.casa.nombre
        $compra = $r.casa.compra
        $venta = $r.casa.venta

        Write-Host $nombre"`nCompra: "$compra"`nVenta: "$venta
    }
}
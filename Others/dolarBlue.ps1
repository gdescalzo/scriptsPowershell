<<<<<<< HEAD
﻿$response = Invoke-RestMethod 'https://www.dolarsi.com/api/api.php?type=valoresprincipales' -Method 'GET' 
=======
$response = Invoke-RestMethod 'https://www.dolarsi.com/api/api.php?type=valoresprincipales' -Method 'GET' -Headers $headers
>>>>>>> cdcc365ea93c86f9dafc7b39d5b872a1192839a3

foreach ($r in $response) {
    
    if ($r.casa.nombre -eq 'Dolar Blue') {         
        $nombre = $r.casa.nombre
        $compra = $r.casa.compra
        $venta = $r.casa.venta

        Write-Host $nombre"`nCompra: "$compra"`nVenta: "$venta
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> cdcc365ea93c86f9dafc7b39d5b872a1192839a3

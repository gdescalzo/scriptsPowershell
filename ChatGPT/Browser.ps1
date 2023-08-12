$env:OAIKEY = ""
$RequestBody = @{
    prompt      = "quien es Rene fabaloro"
    model       = "text-davinci-003"
    temperature = 1
    max_tokens  = 4000
}
$Header = @{ Authorization = "Bearer $($env:OAIKEY) " }
$RequestBody = $RequestBody | ConvertTo-Json

$RestMethodParameter = @{
    Method      = 'Post'
    Uri         = 'https://api.openai.com/v1/completions'
    body        = $RequestBody
    Headers     = $Header
    ContentType = 'application/json'
}


(Invoke-RestMethod @RestMethodParameter).choices[0].text


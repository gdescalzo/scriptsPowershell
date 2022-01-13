#Forest functional level must be Server 2008R2 or higher
Set-ADForestMode -Identity atlantis.local -ForestMode Windows2016Forest -Confirm:$false
get-adforest

#Enable the recycle bin.  If already enabled, you will get an error message. You will get a warning message
Enable-ADOptionalFeature 'recycle bin feature' -Scope ForestOrConfigurationSet `
    -Target (get-adforest).rootdomain -server (get-adforest).domainnamingmaster `
        -Confirm:$false
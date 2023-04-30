<## VARS ##>
$Secret = "UIc8Q~zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
$ApplicationId = "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"

<## To Modify ##>
$myResourceGroup = "ResourceGroupName"
$myAKSCluster = "ClusterAKSname"
$NodeCount = "1"
$WorkSpaceID = "WorkSpaceName"

$SecuredPassword = ConvertTo-SecureString $Secret -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword

function AzAKScreate {
    Get-AzAksCluster -ResourceGroupName $myResourceGroup -Name $myAKSCluster -ErrorVariable notPresent -ErrorAction SilentlyContinue

    if ($notPresent) {     
        $SecuredPassword = ConvertTo-SecureString $Secret -AsPlainText -Force
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword

        New-AzAksCluster -ResourceGroupName $myResourceGroup -Name $myAKSCluster -NodeCount $NodeCount -WorkspaceResourceId $WorkSpaceID -Verbose -ServicePrincipalIdAndSecret $Credential -Debug
    }
    else {        
        Write-Output "AKS Cluster exist."
    }
}

AzAKScreate
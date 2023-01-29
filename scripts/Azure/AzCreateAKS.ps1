<# Azure SPN (GSV-Enterprise)

SPN Name			: SPN-GSV-Enterprise
SPN Secret Name		: SPN-GSV-Enterprise-ClientSecret
SPN Secret Value    : UIc8Q~IsxLBanGJcKdKhYMGa2xG7zByu1vsR5b9B	
SPN Secret ID		: ea9511ad-6ab9-4726-bf6d-340b588b442e
SPN Application ID	: e1ee79fc-976d-4d29-97e6-e935abf7d333
Subscription Id     : 794c4aed-01e7-4a3f-b64d-4d4b02022224

#>

<## VARS ##>
$Secret = "UIc8Q~IsxLBanGJcKdKhYMGa2xG7zByu1vsR5b9B"
$ApplicationId = "e1ee79fc-976d-4d29-97e6-e935abf7d333"

<## To Modify ##>
$myResourceGroup = "GSV-RG01"
$myAKSCluster = "GSV-AKScluster01"
$NodeCount = "1"
$WorkSpaceID = "GSV-WorkSpace01"

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
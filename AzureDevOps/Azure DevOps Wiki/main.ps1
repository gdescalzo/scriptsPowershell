# Install Module
# Install-Module -Name 'PSDocs' -Repository PSGallery -force;

# Import Module
# Import-Module -Name PSDocs

# Loading vars for Azure configuration
. .\vars\vars.ps1

. .\scripts\azWiki-CreatePage-1-Overview.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-2-IAD-ArchDesing.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-3-FunctionalFlow.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-4-EnvInformation.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-5-Dashboards.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-6-Alerts.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-7-Runbooks.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-8-SLOdocuments.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-9-AvailabilitySyntheticTests.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-10-CustomMonitorings.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-11-ContactsStackholders.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-12-Backups.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-13-KTsessions.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-14-SupportModel.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-15-HA-DR.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options
. .\scripts\azWiki-CreatePage-16-ProdReadinessValidation.ps1 $OrganizationName $ProjectName $PAT $WikiName $Content $options

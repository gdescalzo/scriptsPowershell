#Azure Setings
$OrganizationName = 'SomeOrg'
$ProjectName = 'SomeProject'
$PAT = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$WikiName = 'SomeWikiName.wiki'
$options = New-PSDocumentOption -Option @{ 'Markdown.UseEdgePipes' = 'Always'; 'Markdown.ColumnPadding' = 'None' };
$null = [PSDocs.Configuration.PSDocumentOption]$Options
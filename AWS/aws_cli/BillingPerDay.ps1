$start_date = Get-Date

$month_31_days = 1, 3, 5, 7, 8, 10, 12
$month_30_days = 4, 6, 9, 11

$actual_month = $start_date.Month
$actual_year = $start_date.Year

if ($month_31_days -contains $actual_month) {
    $start_date_formatted = "{0:yyyy-MM}-01" -f $start_date
    $end_date_formatted = "{0:yyyy-MM}-31" -f $start_date

    Write-Output ("The start date is: " + $start_date_formatted)
    Write-Output ("The end date is: " + $end_date_formatted)

    aws ce get-cost-and-usage --time-period "Start=$start_date_formatted, End=$end_date_formatted" --granularity DAILY --metrics BlendedCost --query "ResultsByTime[].[TimePeriod.Start, Total.BlendedCost.[Amount][0], Total.BlendedCost.[Unit][0]]" --output text
}
elseif ($month_30_days -contains $actual_month) {
    $start_date_formatted = "{0:yyyy-MM}-01" -f $start_date
    $end_date_formatted = "{0:yyyy-MM}-30" -f $start_date

    Write-Output ("The start date is: " + $start_date_formatted)
    Write-Output ("The end date is: " + $end_date_formatted)

    aws ce get-cost-and-usage --time-period "Start=$start_date_formatted, End=$end_date_formatted "--granularity DAILY --metrics BlendedCost --query "ResultsByTime[].[TimePeriod.Start, Total.BlendedCost.[Amount][0], Total.BlendedCost.[Unit][0]]" --output text
}
else {
    $start_date_formatted = "{0:yyyy-MM}-01" -f $start_date
    $end_date_formatted = "{0:yyyy-MM}-28" -f $start_date

    Write-Output ("The start date is: " + $start_date_formatted)
    Write-Output ("The end date is: " + $end_date_formatted)

    aws ce get-cost-and-usage --time-period "Start=$start_date_formatted, End=$end_date_formatted" --granularity DAILY --metrics BlendedCost --query "ResultsByTime[].[TimePeriod.Start, Total.BlendedCost.[Amount][0], Total.BlendedCost.[Unit][0]]" --output text
}

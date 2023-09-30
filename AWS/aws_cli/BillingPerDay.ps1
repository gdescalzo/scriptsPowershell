$start_date = Get-Date

$month_31_days = 1, 3, 5, 7, 8, 10, 12
$month_30_days = 4, 6, 9, 11

$actual_month = $start_date.Month
$actual_year = $start_date.Year

function Is-LeapYear {
    param (
        [int]$year
    )

    return ($year % 4 -eq 0 -and ($year % 100 -ne 0 -or $year % 400 -eq 0))
}

function Get-FormattedDates {
    param (
        [int]$daysToAdd
    )

    $start_date_formatted = "{0:yyyy-MM}-01" -f $start_date
    $end_date = $start_date.AddMonths(1).AddDays(-$daysToAdd)

    if ($actual_month -eq 2 -and (Is-LeapYear $actual_year)) {
        $end_date = $end_date.AddDays(1) 
    }

    $end_date_formatted = "{0:yyyy-MM-dd}" -f $end_date

    return $start_date_formatted, $end_date_formatted
}

if ($month_31_days -contains $actual_month) {
    $start_date_formatted, $end_date_formatted = Get-FormattedDates -daysToAdd 1
}
elseif ($month_30_days -contains $actual_month) {
    $start_date_formatted, $end_date_formatted = Get-FormattedDates -daysToAdd 30
}
else {
    $start_date_formatted, $end_date_formatted = Get-FormattedDates -daysToAdd 28
}

Write-Output `n("The start date is: " + $start_date_formatted)
Write-Output ("The end date is: " + $end_date_formatted)`n

aws ce get-cost-and-usage --time-period "Start=$start_date_formatted, End=$end_date_formatted" --granularity DAILY --metrics BlendedCost --query "ResultsByTime[].[TimePeriod.Start, Total.BlendedCost.[Amount][0], Total.BlendedCost.[Unit][0]]" --output text

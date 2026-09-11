$u = { param($s) -join ($s -split ' ' | ForEach-Object { [char]([Convert]::ToInt32($_, 16)) }) }
$trim = fsutil behavior query DisableDeleteNotify | Out-String
$headers = @(
    (&$u '78c1 789f 5340')
    (&$u '985e 578b')
    (&$u '5927 5c0f')
    (&$u '52d5 4f5c')
)
$rows = @()

Get-PhysicalDisk | ForEach-Object {
    $disk = $_
    $volumes = Get-Partition -DiskNumber $disk.DeviceID | Get-Volume
    foreach ($volume in $volumes) {
        $part = if ($volume.DriveLetter) { $volume.DriveLetter + ':' } else { '[' + (&$u '7121 78c1 789f 6a5f') + ']' }
        $size = [math]::Round($volume.Size / 1GB, 2).ToString() + ' GB'

        if ($disk.MediaType -eq 'HDD') {
            $type = 'HDD'
            $action = (&$u '6a94 6848') + ' Shift+Delete ' + (&$u '6216 8cc7 6e90 56de 6536 7b52 522a 9664 3001 8cc7 6599 4ecd 53ef 88ab 6aa2 67e5')
        } elseif ($disk.MediaType -eq 'SSD' -and $trim -match 'DisableDeleteNotify = 0') {
            $type = 'SSD (TRIM ' + (&$u '555f 7528') + ')'
            $action = (&$u '6a94 6848') + ' Shift+Delete ' + (&$u '6216 8cc7 6e90 56de 6536 7b52 522a 9664 3001 6703 7acb 5373 6e05 9664 3001 7121 6cd5 88ab 6aa2 67e5')
        } elseif ($disk.MediaType -eq 'SSD') {
            $type = 'SSD (TRIM ' + (&$u '672a 555f 7528') + ')'
            $action = (&$u '6a94 6848') + ' Shift+Delete ' + (&$u '6216 8cc7 6e90 56de 6536 7b52 522a 9664 3001 4e0d 6703 7acb 5373 6e05 9664 3001 8cc7 6599 4ecd 53ef 88ab 6aa2 67e5')
        } else {
            $type = (&$u '672a 77e5')
            $action = (&$u '7121 6cd5 5224 65b7')
        }

        $rows += ,@($part, $type, $size, $action)
    }
}

$encoding = [Text.Encoding]::GetEncoding(950)
$widths = @($headers | ForEach-Object { $encoding.GetByteCount($_) })
foreach ($row in $rows) {
    for ($i = 0; $i -lt $row.Count; $i++) {
        $widths[$i] = [math]::Max($widths[$i], $encoding.GetByteCount([string]$row[$i]))
    }
}

$borderWidth = ($widths.Count * 2) + $widths.Count + 1
$baseWidths = @($widths)

$wrap = {
    param($text, $maxBytes)
    $lines = @('')
    foreach ($character in [char[]][string]$text) {
        $candidate = $lines[-1] + $character
        if ($lines[-1] -and $encoding.GetByteCount($candidate) -gt $maxBytes) {
            $lines += [string]$character
        } else {
            $lines[-1] = $candidate
        }
    }
    $lines
}

$makeBorder = {
    param($left, $join, $right)
    $result = [char]$left
    for ($column = 0; $column -lt $widths.Count; $column++) {
        $result += ([string][char]0x2500 * ($widths[$column] + 2))
        if ($column -lt $widths.Count - 1) { $result += [char]$join }
    }
    $result + [char]$right
}

$formatLine = {
    param($values)
    $line = [char]0x2502
    for ($column = 0; $column -lt $values.Count; $column++) {
        $value = $values[$column]
        $text = [string]$value
        $line += ' ' + $text + (' ' * ($widths[$column] - $encoding.GetByteCount($text))) + ' ' + [char]0x2502
    }
    $line
}

$renderRow = {
    param($values)
    $wrappedValues = @()
    $height = 1
    for ($column = 0; $column -lt $values.Count; $column++) {
        $lines = @(&$wrap $values[$column] $widths[$column])
        $wrappedValues += ,$lines
        $height = [math]::Max($height, $lines.Count)
    }
    for ($lineIndex = 0; $lineIndex -lt $height; $lineIndex++) {
        $lineValues = @()
        for ($column = 0; $column -lt $values.Count; $column++) {
            if ($lineIndex -lt $wrappedValues[$column].Count) {
                $lineValues += $wrappedValues[$column][$lineIndex]
            } else {
                $lineValues += ''
            }
        }
        &$formatLine $lineValues
    }
}

$render = {
    $widths = @($baseWidths)
    $targetWidth = [math]::Max(1, [Console]::WindowWidth - 1)
    while ((($widths | Measure-Object -Sum).Sum + $borderWidth) -gt $targetWidth) {
        $largestColumn = 0
        for ($column = 1; $column -lt $widths.Count; $column++) {
            if ($widths[$column] -gt $widths[$largestColumn]) { $largestColumn = $column }
        }
        if ($widths[$largestColumn] -le 1) { break }
        $widths[$largestColumn]--
    }

    &$makeBorder 0x250c 0x252c 0x2510
    &$renderRow $headers
    &$makeBorder 0x251c 0x253c 0x2524
    for ($rowIndex = 0; $rowIndex -lt $rows.Count; $rowIndex++) {
        &$renderRow $rows[$rowIndex]
        if ($rowIndex -lt $rows.Count - 1) { &$makeBorder 0x251c 0x253c 0x2524 }
    }
    &$makeBorder 0x2514 0x2534 0x2518
}

$lastWidth = [Console]::WindowWidth
&$render
while (-not [Console]::KeyAvailable) {
    if ([Console]::WindowWidth -ne $lastWidth) {
        $lastWidth = [Console]::WindowWidth
        Clear-Host
        &$render
    }
    Start-Sleep -Milliseconds 100
}
[Console]::ReadKey($true) | Out-Null
$errors = Get-Content final_errors_3.txt | Where-Object { 
    $_ -match "const_eval_method_invocation" -or 
    $_ -match "invalid_constant" -or
    $_ -match "const_with_non_constant_argument"
}

foreach ($err in $errors) {
    if ($err -match " - ([^\s]+.dart):(\d+):(\d+) ") {
        $file = "c:\Users\Admin\Pictures\XingCam\$($matches[1])"
        $lineNum = [int]$matches[2]
        if (Test-Path $file) {
            $lines = Get-Content $file
            # Remove the word 'const ' from the line
            $lines[$lineNum - 1] = $lines[$lineNum - 1] -replace '\bconst\s+', ''
            Set-Content $file -Value $lines -Encoding UTF8
        }
    }
}
Write-Host "Invalid constants removed."

$files = Get-Content final_errors.txt | Where-Object {  -match "error -" } | ForEach-Object {
    if ($_ -match " - ([^\s]+.dart):\d+:\d+ ") {
        $matches[1]
    }
} | Select-Object -Unique

foreach ($file in $files) {
    if ($file -match "lib\\" -or $file -match "test\\") {
        $path = "c:\Users\Admin\Pictures\XingCam\$file"
        if (Test-Path $path) {
            $content = Get-Content $path -Raw
            $needsDesignTokens = $false
            $needsHaptics = $false
            $needsMath = $false
            $needsEasyLocalization = $false

            if ($content -match "AppColors" -or $content -match "AppIcons") { $needsDesignTokens = $true }
            if ($content -match "HapticsUtility") { $needsHaptics = $true }
            if ($content -match "dart:math" -eq $false -and $content -match "math\.") { $needsMath = $true }
            if ($content -match "\.tr\(\)" -or $content -match "context\.tr\(") { $needsEasyLocalization = $true }

            $newImports = ""
            if ($needsDesignTokens -and $content -notmatch "design_tokens\.dart") {
                $newImports += "import 'package:xingcam/core/theme/design_tokens.dart';
"
            }
            if ($needsHaptics -and $content -notmatch "haptics_utility\.dart") {
                $newImports += "import 'package:xingcam/core/utils/haptics_utility.dart';
"
            }
            if ($needsMath -and $content -notmatch "dart:math") {
                $newImports += "import 'dart:math' as math;
"
            }
            if ($needsEasyLocalization -and $content -notmatch "easy_localization\.dart") {
                $newImports += "import 'package:easy_localization/easy_localization.dart';
"
            }

            if ($newImports -ne "") {
                # Insert after the first import or at the top
                if ($content -match "(?s)^(.*?import .*?;)(.*)") {
                    $content = $matches[1] + "
" + $newImports + $matches[2]
                } else {
                    $content = $newImports + $content
                }
                Set-Content $path -Value $content -Encoding UTF8
                Write-Host "Fixed imports for: $file"
            }
        }
    }
}

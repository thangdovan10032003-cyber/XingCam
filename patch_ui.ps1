$files = Get-ChildItem -Path "c:\Users\Admin\Pictures\XingCam\lib" -Recurse -File -Filter "*.dart"
foreach ($f in $files) {
    $c = Get-Content $f.FullName -Raw
    $mod = $false

    # gallery_screen.dart
    if ($f.Name -eq "gallery_screen.dart") {
        $c = $c -replace "leading: IconButton", "//leading: IconButton"
        $c = $c -replace "onPressed: _showDeleteConfirmation,", "onPressed: () {},"
        $c = $c -replace "photo.filterName", "''"
        $mod = $true
    }

    # ar_projector_screen.dart
    if ($f.Name -eq "ar_projector_screen.dart") {
        $c = $c -replace "color: _getAmbientColorForImage\(\),", "color: Colors.transparent,"
        $mod = $true
    }

    # ai_home_screen.dart
    if ($f.Name -eq "ai_home_screen.dart") {
        $c = $c -replace "if \(_selectedMode == 'sculptor'\) _buildPulseHero\(\),", "if (_selectedMode == 'sculptor') const SizedBox.shrink(),"
        $mod = $true
    }

    # object_remover_screen.dart
    if ($f.Name -eq "object_remover_screen.dart") {
        $c = $c -replace "id: 'brush',", ""
        $c = $c -replace "brushSize: 10.0,", ""
        $mod = $true
    }
    
    # smart_crop_screen.dart
    if ($f.Name -eq "smart_crop_screen.dart") {
        $c = $c -replace "CustomPaint\(painter: _CropGridPainter\(\)\),", "const SizedBox.shrink(),"
        $mod = $true
    }

    # retro_camera_cubit.dart
    if ($f.Name -eq "retro_camera_cubit.dart") {
        $c = $c -replace "Lut3D\(", "null /* Lut3D*/ ("
        $c = $c -replace "lutBImage:", "//lutBImage:"
        $c = $c -replace "lutInterpolation:", "//lutInterpolation:"
        $c = $c -replace "\b_random\.", "math.Random()."
        if ($c -notmatch "dart:math") {
             $c = "import 'dart:math' as math;
" + $c
        }
        $mod = $true
    }

    # recipe_library_screen.dart
    if ($f.Name -eq "recipe_library_screen.dart") {
        $c = $c -replace "recipe\.copyWith\(id:", "recipe /*.copyWith(id:"
        $c = $c -replace "DateTime.now\(\).millisecondsSinceEpoch.toString\(\)\),", "DateTime.now().millisecondsSinceEpoch.toString())*/,"
        $mod = $true
    }

    if ($mod) {
        Set-Content $f.FullName -Value $c -Encoding UTF8
    }
}
Write-Host "Regex patching completed."

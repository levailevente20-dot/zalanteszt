# Web-optimized copies of the new photo sets.
# Output: images/hero, images/mid, images/becs  (sanitized names, EXIF-rotated, resized JPEG)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot   # repo root (.claude parent)

function Resize-Photo([string]$src, [string]$dst, [int]$maxEdge, [int]$quality) {
  $img = [System.Drawing.Image]::FromFile($src)
  try {
    if ($img.PropertyIdList -contains 0x0112) {
      $o = $img.GetPropertyItem(0x0112).Value[0]
      switch ($o) {
        3 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone) }
        6 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }
        8 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }
      }
    }
    $w = $img.Width; $h = $img.Height
    $scale = [Math]::Min(1.0, $maxEdge / [double][Math]::Max($w, $h))
    $nw = [Math]::Max(1, [int][Math]::Round($w * $scale))
    $nh = [Math]::Max(1, [int][Math]::Round($h * $scale))
    $bmp = New-Object System.Drawing.Bitmap($nw, $nh)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($img, 0, 0, $nw, $nh)
    $g.Dispose()
    $enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
    $bmp.Save($dst, $enc, $ep)
    $bmp.Dispose()
    return "{0},{1},{2}" -f (Split-Path -Leaf $dst), $nw, $nh
  } finally {
    $img.Dispose()
  }
}

function Convert-Set([string]$srcDir, [string]$dstDir, [string]$prefix, [int]$maxEdge, [int]$quality, [int]$pad) {
  New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
  $files = Get-ChildItem $srcDir -File | Where-Object { $_.Extension -match '\.jpe?g$' } | Sort-Object Name
  $i = 0
  $log = @()
  foreach ($f in $files) {
    $i++
    $name = "{0}-{1}.jpg" -f $prefix, $i.ToString().PadLeft($pad, '0')
    $log += (Resize-Photo $f.FullName (Join-Path $dstDir $name) $maxEdge $quality) + "," + $f.Name
  }
  $log | Out-File (Join-Path $dstDir '_map.csv') -Encoding utf8
  Write-Output ("{0}: {1} images" -f $prefix, $i)
}

Convert-Set (Join-Path $root 'images\photos\home-hero')          (Join-Path $root 'images\hero') 'hero' 1000 78 2
Convert-Set (Join-Path $root 'images\photos\home mid')           (Join-Path $root 'images\mid')  'mid'  1400 76 2
Convert-Set (Join-Path $root 'images\photos\Vienna 2026_06_05')  (Join-Path $root 'images\becs') 'becs' 1400 76 3
Write-Output 'DONE'

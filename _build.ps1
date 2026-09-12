Add-Type -AssemblyName System.Drawing
$SZ = 128
# PICO-8 palette RGB (index 0..15)
$pal = @(
 @(0,0,0),@(29,43,83),@(126,37,83),@(0,135,81),
 @(171,82,54),@(95,87,79),@(194,195,199),@(255,241,232),
 @(255,0,77),@(255,163,0),@(255,236,39),@(0,228,54),
 @(41,173,255),@(131,118,156),@(255,119,168),@(255,204,170)
)

# index buffer, init navy(1)
$buf = New-Object 'int[,]' $SZ,$SZ
for($yy=0;$yy -lt $SZ;$yy++){ for($xx=0;$xx -lt $SZ;$xx++){ $buf[$yy,$xx]=1 } }

function setpx($x,$y,$c){
  if($x -ge 0 -and $x -lt 128 -and $y -ge 0 -and $y -lt 128){ $script:buf[$y,$x]=$c }
}

# ---- 5x7 font ----
$font = @{}
$font['P']=@('XXXX.','X...X','X...X','XXXX.','X....','X....','X....')
$font['I']=@('XXXXX','..X..','..X..','..X..','..X..','..X..','XXXXX')
$font['C']=@('.XXXX','X....','X....','X....','X....','X....','.XXXX')
$font['O']=@('.XXX.','X...X','X...X','X...X','X...X','X...X','.XXX.')
$font['B']=@('XXXX.','X...X','X...X','XXXX.','X...X','X...X','XXXX.')
$font['A']=@('.XXX.','X...X','X...X','XXXXX','X...X','X...X','X...X')
$font['T']=@('XXXXX','..X..','..X..','..X..','..X..','..X..','..X..')
$font['L']=@('X....','X....','X....','X....','X....','X....','XXXXX')
$font['E']=@('XXXXX','X....','X....','XXXX.','X....','X....','XXXXX')

$word='PICOBATTLE'
$cw=6
$wbits=@{}
$wx=0
foreach($ch in $word.ToCharArray()){
  $g=$font["$ch"]
  for($ry=0;$ry -lt 7;$ry++){
    $line=$g[$ry]
    for($rx=0;$rx -lt 5;$rx++){
      if($line[$rx] -eq 'X'){ $wbits["$($wx+$rx),$ry"]=$true }
    }
  }
  $wx += $cw
}
$wW = $wx - 1
$scale=2
$logoW=$wW*$scale
$ox=[int](($SZ-$logoW)/2)
$oy=17
$depth=4

# gold pixel set (scaled + placed)
$goldset=@{}
foreach($k in $wbits.Keys){
  $p=$k.Split(','); $bx=[int]$p[0]; $by=[int]$p[1]
  for($sy=0;$sy -lt $scale;$sy++){ for($sx=0;$sx -lt $scale;$sx++){
     $goldset["$($ox+$bx*$scale+$sx),$($oy+$by*$scale+$sy)"]=$true
  }}
}
# extrusion shadow
$shad=@{}
foreach($k in $goldset.Keys){ $p=$k.Split(','); $gx=[int]$p[0];$gy=[int]$p[1]
  for($dd=1;$dd -le $depth;$dd++){ $ky="$gx,$($gy+$dd)"; if(-not $goldset.ContainsKey($ky)){ $shad[$ky]=$true } }
}
# outline = dilate(solid) - solid
$solid=@{}
foreach($k in $goldset.Keys){$solid[$k]=$true}
foreach($k in $shad.Keys){$solid[$k]=$true}
$out=@{}
foreach($k in $solid.Keys){ $p=$k.Split(','); $gx=[int]$p[0];$gy=[int]$p[1]
  foreach($ddx in -1,0,1){ foreach($ddy in -1,0,1){
     $ky="$($gx+$ddx),$($gy+$ddy)"; if(-not $solid.ContainsKey($ky)){ $out[$ky]=$true }
  }}
}
foreach($k in $out.Keys){ $p=$k.Split(','); setpx ([int]$p[0]) ([int]$p[1]) 0 }
foreach($k in $shad.Keys){ $p=$k.Split(','); setpx ([int]$p[0]) ([int]$p[1]) 4 }
foreach($k in $goldset.Keys){ $p=$k.Split(','); setpx ([int]$p[0]) ([int]$p[1]) 10 }
# top-rim highlight
foreach($k in $goldset.Keys){ $p=$k.Split(','); $gx=[int]$p[0];$gy=[int]$p[1]
  if(-not $goldset.ContainsKey("$gx,$($gy-1)")){ setpx $gx $gy 7 }
}

# ---- crossed sabers ----
function saber($cx,$cy,$r){
  for($i=-$r;$i -le $r;$i++){
    setpx ($cx+$i) ($cy+$i) 4
    setpx ($cx+$i) ($cy-$i) 4
  }
  # hilts (grey) near center
  setpx $cx $cy 5
  setpx ($cx-1) $cy 5; setpx ($cx+1) $cy 5
  # bright blade tips
  setpx ($cx+$r) ($cy+$r) 6; setpx ($cx-$r) ($cy-$r) 6
  setpx ($cx+$r) ($cy-$r) 6; setpx ($cx-$r) ($cy+$r) 6
}
saber 12 6 5
saber 115 6 5
saber 10 70 4
saber 117 70 4

# ---- red flag, bottom-right ----
for($y=100;$y -le 124;$y++){ setpx 112 $y 6 }   # pole
setpx 112 99 7
for($y=100;$y -le 109;$y++){
  $len = 12 - [int]([math]::Abs($y-104)*0.6)
  for($x=113;$x -lt 113+$len;$x++){ setpx $x $y 8 }
}

# ---- cannon silhouette from jpg, bottom-left ----
try {
  $img=[System.Drawing.Bitmap]::FromFile("C:\Users\ghosty\Downloads\title\PDudG.jpg")
  $iw=$img.Width; $ih=$img.Height
  # bbox of non-background (background = light, low-saturation checker)
  $minx=$iw;$miny=$ih;$maxx=0;$maxy=0
  for($y=0;$y -lt $ih;$y+=5){ for($x=0;$x -lt $iw;$x+=5){
     $px=$img.GetPixel($x,$y)
     $mx=[math]::Max($px.R,[math]::Max($px.G,$px.B))
     $mn=[math]::Min($px.R,[math]::Min($px.G,$px.B))
     $sat=$mx-$mn
     if(($mx -lt 150) -or ($sat -gt 35)){
       if($x -lt $minx){$minx=$x}; if($x -gt $maxx){$maxx=$x}
       if($y -lt $miny){$miny=$y}; if($y -gt $maxy){$maxy=$y}
     }
  }}
  $bw=$maxx-$minx; $bh=$maxy-$miny
  $tw=48
  $th=[int]($bh*$tw/$bw)
  if($th -gt 26){ $th=26; $tw=[int]($bw*$th/$bh) }
  $cox=3
  $coy=126-$th
  for($ty=0;$ty -lt $th;$ty++){ for($tx=0;$tx -lt $tw;$tx++){
     $sx=$minx+[int]($tx*$bw/$tw)
     $sy=$miny+[int]($ty*$bh/$th)
     $px=$img.GetPixel($sx,$sy)
     $mx=[math]::Max($px.R,[math]::Max($px.G,$px.B))
     $mn=[math]::Min($px.R,[math]::Min($px.G,$px.B))
     $sat=$mx-$mn
     if(($mx -lt 150) -or ($sat -gt 35)){
       # silhouette: darker -> 2, mid -> 4 (faint)
       if($mx -lt 95){ setpx ($cox+$tx) ($coy+$ty) 2 }
       else { setpx ($cox+$tx) ($coy+$ty) 4 }
     }
  }}
  $img.Dispose()
  "cannon bbox $minx,$miny .. $maxx,$maxy -> ${tw}x${th} at $cox,$coy"
} catch { "cannon FAILED: $_" }

# ---- save preview PNG (8x) ----
$pv=8
$bmp=New-Object System.Drawing.Bitmap (128*$pv),(128*$pv)
$gfx=[System.Drawing.Graphics]::FromImage($bmp)
for($y=0;$y -lt 128;$y++){ for($x=0;$x -lt 128;$x++){
   $c=$pal[$buf[$y,$x]]
   $br=New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($c[0],$c[1],$c[2]))
   $gfx.FillRectangle($br,$x*$pv,$y*$pv,$pv,$pv)
   $br.Dispose()
}}
$gfx.Dispose()
$bmp.Save("C:\Users\ghosty\AppData\Roaming\pico-8\carts\tactic_test\_preview.png")
$bmp.Dispose()

# ---- emit __gfx__ hex ----
$hex='0123456789abcdef'
$lines=New-Object System.Collections.Generic.List[string]
for($y=0;$y -lt 128;$y++){
  $sb=New-Object System.Text.StringBuilder
  for($x=0;$x -lt 128;$x++){ $ci=$buf[$y,$x]; [void]$sb.Append($hex[$ci]) }
  $lines.Add($sb.ToString())
}
[System.IO.File]::WriteAllLines("C:\Users\ghosty\AppData\Roaming\pico-8\carts\tactic_test\_gfx.txt",$lines)
"DONE logo ox=$ox oy=$oy logoW=$logoW"

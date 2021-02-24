function StringToHex($i) {
    $r = ""
    $i.ToCharArray() | foreach-object -process {
        $r += '{0:X}' -f [int][char]$_
        }
    return $r
    }
 
function HexToString($i) {
    $r = ""
    for ($n = 0; $n -lt $i.Length; $n += 2)
        {$r += [char][int]("0x" + $i.Substring($n,2))}
    return $r
    }
 
function HexDump($i) {
    $i.ToCharArray() | foreach-object -process {
        $num = [int][char]$_
        $hex = "0x" + ('{0:X}' -f $num)
        "$_ $hex $num"
        }
    }
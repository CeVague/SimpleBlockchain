wdir=$1

if [ "$wdir" = "" ] ; then
    echo "A working dir should be provided"
    exit 1
fi

cd $wdir/blocks

echo "<style>td {border: 1px solid #999; text-align:center; margin:0px; padding:5px 10px; font-family: monospace}</style>"
echo "<table>"
echo "<tr>"
echo "<td>level</td>"
echo "<td>mined by</td>"
echo "<td>date</td>"
echo "<td>pow</td>"
echo "<td>hash</td>"
echo "</tr>"

for f in `ls * | sort -n`; do
    echo "<tr>"
    echo "<td>$f</td>"
    miner="`grep "^miner " $f | cut -d" " -f 2`"
    echo $miner > /tmp/miner
    mhash="`md5sum /tmp/miner | cut -d " " -f 1`"
    color=${mhash:0:8} 
    echo "<td style=\"background-color:#$color\"><b>$miner</b></td>"
    echo "<td>`grep "^date " $f | cut -d" " -f 2`</td>"
    echo "<td>`grep "^pow " $f | cut -d" " -f 2`</td>"
    echo "<td>`md5sum $f | cut -d " " -f1`</td>"
    echo "</tr>"
done
echo "</table>"

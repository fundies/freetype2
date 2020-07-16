#!/bin/bash

# Arguments

FONT=$1
SIZE=$2
COMMIT_A=$3
COMMIT_B=$4

OUTDIR_A="/tmp/ft-tests/${COMMIT_A}/$(basename ${FONT})/${SIZE}/"
OUTDIR_B="/tmp/ft-tests/${COMMIT_B}/$(basename ${FONT})/${SIZE}/"

function write_img_comp() {
  echo "<!DOCTYPE html>
  <html>
  <head>
  <style>
  .comp {
    width: $(identify -format '%w' $1)px;
    height: $(identify -format '%h' $1)px;
    background: url(\"$1\") no-repeat;
    display: inline-block;
  }
  .comp:hover {
    background: url(\"${OUTDIR_B}/$(basename $1)\") no-repeat;
  }
  </style>
  </head>
  <body>
  <h2>Comparison of $(basename $1) between commits</h2>
  <div class=\"comp\"></div>
  </body>
  </html>"
}

echo "<!DOCTYPE html>
<html>
<head>
<style>
table, tr {
  border: 1px solid black;
  display:table;
  margin-right:auto;
  margin-left:auto;
  width:100%;
}

th.fail {
 color: red       
}

th.pass {
 color: green      
}

</style>
</head>
<body>

<h2>Freetype2 Difference Report</h2>

<table>"

PASS=()
FAIL=()
FILES=${OUTDIR_A}/*

for f in $FILES
do
  derp=$(diff $f ${OUTDIR_B}/$(basename $f)) # we only care about return result
  result=$?
  if [ "$result" -eq "0" ]; 
  then
    PASS+="$f "
  else
    FAIL+="$f "
  fi
done

echo "<tr><th class=\"fail\">FAIL</th></tr>"

for f in $FAIL
do
  PAGE="$(basename $f .png).html"
  write_img_comp $f &> $PAGE
  echo "
  <tr>
    <td><a href=\"$PAGE\">$(basename $f)</a></td>
  </tr>"
done

echo "<tr><th class=\"pass\">PASS</th></tr>"

for f in $PASS
do
  echo "
  <tr>
    <td>$(basename $f)</td>
  </tr>"
done

echo "
</table>

</body>
</html>"

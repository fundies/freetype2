#!/bin/bash

# Arguments to /ft-test-font.sh
#COMMIT=$1
#FONT=$2
#SIZE=$3
#DPI=$4
#DUMP=$5
#BENCH=$6
#VIEW=$7
#STRING=$8
#START_GLYPH=$9
#END_GLYPH=$10

# This script is where one might add additional tests. Currently, it cycles
# through the below directory and call the metric dumping script for any files
# in that directory. Currently, it only tests all files at pt 16 and dpi 72 and
# with ft-grid's default rendering mode.
  
FILES=~/test-fonts/*

GIT_HASH=$(git log --pretty=format:'%h' -n 1)

EXIT=0
DEMOSDIR="../freetype2-demos/bin"
PASS=()
FAIL=()

for f in $FILES
do
  GLYPHCOUNT=$(${DEMOSDIR}/ftdump $f | grep "glyph count" | sed 's/\s*glyph count:\s*\([0-9]\+\)/\1/')
  ${PREVIOUS_PWD}/CI/ft-test-font.sh ${GIT_HASH} $f 16 72 1 1 1 1 0 ${GLYPHCOUNT}
  if [ ! -z "$1" ]; then
   ${PREVIOUS_PWD}/CI/ft-report.sh $f 16 ${1} ${2}\
    &> /tmp/ft-tests/ft-$(basename $f)-16-report.html
   result=$?
   if [ "$result" -eq "0" ];
   then
     RESULT_STR="PASS"
     PASS+="ft-$(basename $f)-16-report.html "
   else
     RESULT_STR="FAIL"
     FAIL+="ft-$(basename $f)-16-report.html "
     # We store any failure to use later in the exit command.
     EXIT=1
   fi
   echo "ft-$(basename $f)-16-report.html [$RESULT_STR]"
  fi
done

# Below we generate an index of all reports generated
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
<h2>Freetype2 Difference Reports Index</h2>
<table>" &> "/tmp/ft-tests/index.html"

echo "<tr><th class=\"fail\">FAIL</th></tr>" &>> "/tmp/ft-tests/index.html"

for f in $FAIL
do
  echo "
  <tr>
    <td><a href=\"$f\">$(basename $f .html)</a></td>
  </tr>" &>> "/tmp/ft-tests/index.html"
done

echo "<tr><th class=\"pass\">PASS</th></tr>" &>> "/tmp/ft-tests/index.html"

for f in $PASS
do
  echo "
  <tr>
        <td><a href=\"$f\">$(basename $f .html)</a></td>
  </tr>" &>> "/tmp/ft-tests/index.html"
done

echo "
</table>

</body>
</html>" &>> "/tmp/ft-tests/index.html"

exit $EXIT

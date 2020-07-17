#!/bin/bash

# Arguments
COMMIT=$1
FONT=$2
SIZE=$3
DPI=$4
BENCH=$5
VIEW=$6
STRING=$7
START_C=$8
END_C=$9

DEMOSDIR="../freetype2-demos/bin"
OUTDIR="/tmp/ft-tests/${COMMIT}/$(basename ${FONT})/${SIZE}/"

function startX {
  Xvfb :"$1" -screen 0 1024x768x24 &
  XVFB_PIDS+=( $! )
  DISPLAY=:"$1" xfwm4 &
  sleep 2
}

function xvfbRunAndScreenShot {
  display="$1"
  shift
  screenshot_name="$1"
  shift
  DISPLAY=:"$display" $@ &
  PID=$!
  sleep 1
  DISPLAY=:"$display" xwd -root -silent | convert -trim xwd:- png:${OUTDIR}/${screenshot_name}
  kill $PID
}

mkdir -p $OUTDIR

WORKERS=10

for worker in $(seq 1 $WORKERS)
do
  startX $((98 + ${worker})) &
done

if [[ "$BENCH" -eq 1 ]]; then
  $DEMOSDIR/ftbench ${FONT} &> ${OUTDIR}/bench.txt
fi

if [[ "$STRING" -eq 1 ]]; then
  xvfbRunAndScreenShot 99 "$ftstring.png" $DEMOSDIR/ftstring -r $DPI ${SIZE} ${FONT}
fi

if [[ "$VIEW" -eq 1 ]]; then
  xvfbRunAndScreenShot 99 "ftview.png" $DEMOSDIR/ftview -r $DPI ${SIZE} ${FONT}
fi

for char in $(seq ${START_C} ${END_C})
do 
   ((i=i%WORKERS)); ((i++==0)) && wait
   echo "ftgrid ${char}"
   char_padded=$(printf "%03d" ${char})
   xvfbRunAndScreenShot $((98 + ${i})) "ftgrid_${char_padded}.png" $DEMOSDIR/ftgrid -r $DPI -f ${char} ${SIZE} ${FONT} &
done

sleep 2 # wait for workers to finish up

killall Xvfb

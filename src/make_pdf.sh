#!/bin/bash
#
# PDF for QA check

echo Making PDF

# FSL init
PATH=${FSLDIR}/bin:${PATH}
. ${FSLDIR}/etc/fslconf/fsl.sh

# Work in output directory
cd ${OUTDIR}

# Views of seg over subject T1 and atlas T1
z=500
fsleyes render -of subj.png \
  --scene ortho --displaySpace world --xzoom $z --yzoom $z --zzoom $z \
  --layout horizontal --hideCursor --hideLabels --hidex \
  ${WT1_NII} --overlayType volume \
  ${WSEG_NII} --overlayType label --lut random_big --outlineWidth 0 #--outline

fsleyes render -of atlas.png \
  --scene ortho --displaySpace world --xzoom $z --yzoom $z --zzoom $z \
  --layout horizontal --hideCursor --hideLabels --hidex \
  ${MNI_NII} --overlayType volume \
  ${WSEG_NII} --overlayType label --lut random_big --outlineWidth 0 #--outline


# Combine into single PDF
${IMMAGDIR}/montage \
-mode concatenate \
subj.png atlas.png \
-tile 1x2 -quality 100 -background black -gravity center \
-border 20 -bordercolor black page1.png

info_string="$PROJECT $SUBJECT $SESSION $SCAN"
${IMMAGDIR}/convert \
-size 2600x3365 xc:white \
-gravity center \( page1.png -resize 1600x \) -composite \
-gravity North -pointsize 48 -annotate +0+100 \
"PMAT_fs ROIs in atlas space" \
-gravity SouthEast -pointsize 48 -annotate +100+100 "$(date)" \
-gravity NorthWest -pointsize 48 -annotate +100+200 "${info_string}" \
makerois-PMAT-fs.pdf


#!/bin/bash
# Fabrication files for the KiCad board, from Hardware/KiCAD-10import, with kicad-cli.
#   Production/make_production.sh <tag, e.g. 0v7> <date, e.g. 2026-11-13>
# Writes Production/Okapi_<tag>_<date>.zip (Gerbers, drill, pick-and-place) and
# Production/Okapi_BoM_<tag>_<date>.csv. Coordinates are KiCad's absolute ones in
# every file, so the Gerbers and the placement files agree; placement follows the
# convention of Eagle's 2024 export (tools/okapi_pos.py).
set -e
cd "$(dirname "$0")/.."
TAG=$1; DATE=$2; [ -n "$TAG" ] && [ -n "$DATE" ] || { echo "usage: $0 <tag> <date>"; exit 2; }
K=Hardware/KiCAD-10import
W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
kicad-cli pcb drc --severity-error -o "$W/drc.rpt" --exit-code-violations $K/Okapi.kicad_pcb
kicad-cli pcb export gerbers -l F.Cu,B.Cu,F.Paste,B.Paste,F.SilkS,B.SilkS,F.Mask,B.Mask,Edge.Cuts -o "$W/Okapi_$TAG/" $K/Okapi.kicad_pcb
kicad-cli pcb export drill --excellon-separate-th --format excellon -u mm -o "$W/Okapi_$TAG/" $K/Okapi.kicad_pcb
python3 Production/tools/okapi_pos.py $K/Okapi.kicad_pcb "$W/Okapi_$TAG"   # Eagle's convention: SMD-pad center, any part with an SMD pad
rm -f "Production/Okapi_${TAG}_$DATE.zip"
(cd "$W" && zip -qrX "$OLDPWD/Production/Okapi_${TAG}_$DATE.zip" "Okapi_$TAG")
kicad-cli sch export bom \
  --fields 'Reference,Value,Footprint,${QUANTITY},MF,MPN,DIGIKEY,ALT_MF,ALT_MPN,ALT_DIGIKEY,${DNP}' \
  --labels 'Refs,Value,Footprint,Qty,MF,MPN,DIGIKEY,ALT_MF,ALT_MPN,ALT_DIGIKEY,DNP' \
  --group-by 'Value,Footprint,MF,MPN,DIGIKEY,${DNP}' --ref-range-delimiter '' \
  -o "Production/Okapi_BoM_${TAG}_$DATE.csv" $K/Okapi.kicad_sch
unzip -l "Production/Okapi_${TAG}_$DATE.zip"

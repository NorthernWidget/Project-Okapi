#!/usr/bin/env python3
"""Pick-and-place files as Eagle wrote them for the 2024 fab, from the KiCad board.

    okapi_pos.py <board.kicad_pcb> <out_dir>

Eagle's export listed every part with at least one SMD pad, at the center of the
box through those pads' centers; kicad-cli lists parts by footprint type, at the
footprint origin. Those differ on Okapi: J9, J10, U3 and USB2 are surface-mount
parts with plated holes (typed through_hole), and SD1's origin is 8 mm from its
pads. This writes Okapi-top-pos.csv and Okapi-bottom-pos.csv in kicad-cli's CSV
columns and KiCad's absolute coordinates (y negated, as kicad-cli writes it), so
the Gerbers and the placement agree. Parts excluded from position files or marked
DNP are left out.
"""
import csv, os, sys
import pcbnew

board = pcbnew.LoadBoard(sys.argv[1])
out = sys.argv[2]
rows = {'top': [], 'bottom': []}
for f in board.GetFootprints():
    if f.IsExcludedFromPosFiles() or f.IsDNP():
        continue
    smd = [p for p in f.Pads() if p.GetAttribute() == pcbnew.PAD_ATTRIB_SMD]
    if not smd:
        continue
    xs = []
    ys = []
    for p in smd:
        xs.append(p.GetPosition().x)
        ys.append(p.GetPosition().y)
    cx = pcbnew.ToMM((min(xs) + max(xs)) / 2)
    cy = pcbnew.ToMM((min(ys) + max(ys)) / 2)
    side = 'bottom' if f.IsFlipped() else 'top'
    rot = f.GetOrientationDegrees()
    if rot > 180:
        rot -= 360
    rows[side].append((f.GetReference(), f.GetValue(), str(f.GetFPID().GetLibItemName()),
                       '%.6f' % cx, '%.6f' % -cy, '%.6f' % rot, side))
for side, rs in rows.items():
    with open(os.path.join(out, 'Okapi-%s-pos.csv' % side), 'w', newline='') as fh:
        w = csv.writer(fh, quoting=csv.QUOTE_MINIMAL)
        w.writerow(['Ref', 'Val', 'Package', 'PosX', 'PosY', 'Rot', 'Side'])
        for r in sorted(rs, key=lambda r: (r[0].rstrip('0123456789'), int('0' + ''.join(c for c in r[0] if c.isdigit())))):
            w.writerow(r)
    print(side, len(rs))

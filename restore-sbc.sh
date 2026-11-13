#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PYCODE'
import json,subprocess
cards=json.loads(subprocess.check_output(['pactl','-f','json','list','cards'],text=True))
matches=[c for c in cards if c.get('name','').startswith('bluez_card.') and c.get('properties',{}).get('device.description')=='soundcore Space Q45']
if len(matches)!=1:
 raise SystemExit('Connect exactly one Soundcore Space Q45, then retry.')
subprocess.run(['pactl','set-card-profile',matches[0]['name'],'a2dp-sink-sbc'],check=True)
print('Requested original SBC music profile.')
PYCODE

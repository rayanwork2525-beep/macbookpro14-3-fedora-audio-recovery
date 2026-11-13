#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
# Read-only check. Exit 1 means at least one missing build/dependency.
set -u
failed=0
printf 'Running kernel: %s\n' "$(uname -r)"
printf 'Model: '; cat /sys/class/dmi/id/product_name
printf '\nSource link: '; readlink -f /usr/src/snd_hda_macbookpro-0.1 || true
if [[ ! -f /usr/src/snd_hda_macbookpro-0.1/dkms.conf ]]; then
  printf 'MISSING: persistent DKMS source\n'; failed=1
fi
if ! command -v dkms >/dev/null; then
  printf 'MISSING: dkms command\n'; exit 1
fi
status=$(dkms status) || exit 1
printf '\n%s\n' "$status"
while IFS= read -r release; do
  [[ -n "$release" ]] || continue
  if printf '%s\n' "$status" | grep -F "snd_hda_macbookpro/0.1, $release," | grep -q ': installed'; then
    printf 'OK: custom driver installed for %s\n' "$release"
  else
    printf 'CHECK BEFORE BOOTING: no installed custom driver for %s\n' "$release"; failed=1
  fi
done < <(rpm -q kernel-core --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n')
printf '\nCurrently selected module: '
modinfo -F filename snd_hda_codec_cs8409 || failed=1
printf '\nThis checks installation, not sound quality or future compatibility.\n'
exit "$failed"

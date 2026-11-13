# Bluetooth troubleshooting — 13 November 2026

## Corrected symptom history
The owner clarified that this movement/hand-covering glitch does NOT happen under macOS on the same laptop. It also does not occur with phone/iPad playback, persists in Normal mode (ANC off), and occurs with downloaded media. Earlier statements implying the same movement-related fault existed under macOS are superseded. This favors the Linux Bluetooth path; it does not prove a specific firmware bug.

## Verified
- Broadcom BCM20703A2, Apple ACPI BCM2E7C, HCI UART/serial transport (not USB Bluetooth).
- Kernel 7.2.11-200.fc44.x86_64; PipeWire 1.6.9; WirePlumber 0.5.18; BlueZ 5.87+1.git8750129efca8-1.fc44.
- Wi-Fi already uses 5 GHz; Bluetooth discovery is false. No external USB devices appeared in lsusb topology.
- Runtime power status for the Bluetooth serial device says unsupported; its control says auto. This alone does not show active power-saving transitions.
- SBC/A2DP was active before the trial. Source inspection of PipeWire 1.6.9 bt-latency.h shows the missing-completion warning triggers after pending send/completion timing exceeds one second. The text suggests a firmware bug but does not diagnose one. A warning is not direct proof of RF packet loss.
- Boot has baudrate-setting and missing brcm/BCM.hcd warnings. No matching replacement firmware has been validated, so no firmware files were changed.
- A short SBC observation also had zero PipeWire processing errors despite earlier packet warnings. Therefore zero errors under AAC alone does not establish superiority.

## Reversible trial applied
Changed only the Q45 profile from a2dp-sink-sbc to a2dp-sink (AAC on this device). Verified the sink reports codec=aac, RUNNING, connected, with approximately the same 58% volume. Small volume rounding changed 58% raw values across the profile switch. Speaker configuration was not changed.

A 30-sample pw-top observation showed zero errors on the AAC sink. No new missing-completion warnings were observed during that short window. The old SBC transport reported an error during profile replacement, so that transition is excluded from steady-state assessment. These observations do not verify acoustic quality or movement-related stability.

WirePlumber normally remembers the selected profile; this is a trial setting, not a validated permanent fix. Roll back with the supplied restore-sbc.sh if AAC is worse. The script discovers the currently connected Space Q45 card by its description rather than publishing its Bluetooth address.

## Remaining work / actual blockers
- A human listening test while reproducing the movement is needed: the assistant cannot hear the headphones or physically reproduce the obstruction.
- btmon failed with Operation not permitted; sudo -n reports a password is required. Controller-level tracing and privileged driver/power-policy changes could not be performed in this session. No password was requested or collected.
- Comparing 7.2.10 or 7.2.9 requires a deliberate reboot, which was not initiated. Their speaker DKMS builds are installed, but their Bluetooth behavior is untested.
- Do not install a random renamed BCM.hcd, change USB autosuspend for this UART controller, or force higher-bitrate LDAC as a supposed fix without evidence.

Source inspected: https://github.com/PipeWire/pipewire/blob/1.6.9/spa/plugins/bluez5/bt-latency.h

# MacBookPro14,3 Fedora audio: working setup and recovery

A recovery snapshot captured on 13 November 2026 from a 2017 15-inch MacBook Pro. The owner reports that both speakers and Bluetooth sound much better than under their previous macOS installation. This records what actually works on that machine; it is not proof of why macOS sounded bad or a universal fix for every Mac.

## What was verified

| Component | Captured working configuration |
| --- | --- |
| Model | MacBookPro14,3 |
| System | Fedora 44 KDE, x86_64 |
| Running kernel | 7.2.11-200.fc44.x86_64 |
| Speaker codec | Cirrus Logic CS8409/CS42L83, subsystem 106b3900 |
| Controller / codec drivers | snd_hda_intel / custom snd_hda_codec_cs8409 |
| Driver project | davidjo/snd_hda_macbookpro |
| Exact source commit | 89b22ff90b86468b186706861dd18663562defa7 |
| DKMS | snd_hda_macbookpro/0.1, AUTOINSTALL=yes |
| Installed DKMS builds | 7.2.9-201, 7.2.10-200, 7.2.11-200 (fc44.x86_64) |
| Audio services | PipeWire 1.6.9, WirePlumber 0.5.18 |
| Speakers | Analog Stereo Output, speaker port, 50% volume |
| Bluetooth headphones | Soundcore Space Q45, A2DP/SBC, stereo 48 kHz, 52% volume |

The custom module was selected from the running kernel's `extra/` directory. Boot logs confirm its Apple initialization path. Bluetooth playback was active during capture; speaker quality is the owner's report, not a measurement. The two outputs use different driver paths: the CS8409 driver does not fix Bluetooth.

## Why this can sound different

The speaker path uses the community Apple's-hardware support in the bundled driver. The Bluetooth path is currently in stereo music mode. Differences in the old OS's routing, microphone mode, processing, or driver behavior are possible explanations, but were not tested. No new sound fix was installed during this investigation: the working driver was already present.

## Before updating or rebooting

1. Keep this repository and a separate system backup. This is source/configuration recovery, not a disk image.
2. Keep the directory targeted by `/usr/src/snd_hda_macbookpro-0.1`. On the captured installation it links to the owner's `~/snd_hda_macbookpro`. Deleting or moving that source breaks future DKMS builds.
3. After the update installs a new kernel, run `bash check-audio.sh`. Check that the new kernel has an installed `snd_hda_macbookpro/0.1` DKMS build. A successful build alone cannot guarantee runtime sound.
4. Keep kernel `7.2.11-200.fc44.x86_64` available as a boot-menu fallback until you have tested the new kernel. Verify retention in the package manager; this repository does not prevent automatic kernel cleanup.
5. If the new build is missing, remain on the working kernel and investigate before rebooting into the new one. Matching `kernel-devel` files and a successful driver build are needed. DKMS automatic installation is already enabled, but future kernel API changes can still break compilation.

No update was blocked, no kernel was pinned, and no automatic reboot prevention was installed by creating this backup. If an offline update is already scheduled, it may install the new kernel during reboot before you can run the check; retain the old boot entry and test it as a fallback.

## Reproducing on a compatible Fedora machine

First identify hardware with `cat /sys/class/dmi/id/product_name` and `cat /proc/asound/cards`. Read [the bundled upstream README](vendor/README.md) and check amplifier/model compatibility. These steps were taken from the captured driver's installation interface; they were not re-run on the already-working machine.

Install build dependencies and matching headers:

```sh
sudo dnf install gcc make patch wget dkms "kernel-devel-$(uname -r)"
```

Keep this checkout in a permanent location, then inspect and use the bundled source:

```sh
cd vendor
sudo ./install.cirrus.driver.sh -i
```

This registers/builds through DKMS. Its installer downloads matching Linux source; it is not an offline installer. If it fails, inspect its output and DKMS logs rather than rebooting and assuming success. Existing installations should inspect their DKMS source link first, instead of registering a second copy. Use KDE's Analog Stereo Output profile. Start quietly and test via normal desktop playback; avoid direct `hw:0,0` playback, which upstream warns can bypass volume control.

Secure Boot requires appropriately trusted module signing. Do not disable security just to silence a module-load error. The captured machine loaded the custom module with a signature verification warning; that is evidence of this machine's state, not a requirement for others.

## If speakers break after an update

Boot the retained working kernel from the boot menu. Then inspect:

```sh
uname -r
dkms status
modinfo -F filename snd_hda_codec_cs8409
journalctl -b -k | grep -Ei 'cs8409|snd_hda|verification'
```

For a specific installed target kernel, ensure its matching kernel-devel package exists, then a repair may use `sudo dkms autoinstall -k TARGET_KERNEL_RELEASE` (replace the placeholder). Review build errors if this fails. Never copy an old `.ko` into a different kernel: modules are kernel-specific.

The original local backup also contains the installed binary. This public repository instead preserves the source and mixer snapshot, avoiding reliance on redistributing a kernel-specific binary.

## If Bluetooth becomes thin or telephone-like

Close microphone capture and select High Fidelity Playback / A2DP (SBC) in KDE. Discover your own card identifier with `pactl list cards short`, then use:

```sh
pactl set-card-profile YOUR_BLUEZ_CARD_NAME a2dp-sink-sbc
```

Use a profile actually listed by `pactl list cards`. Enabling a headset microphone can switch profiles. No Bluetooth auto-switch setting was changed in this capture. A2DP/SBC was the observed working configuration; a different codec is not necessary to reproduce it.

## Files and limitations

- `vendor/`: exact tracked upstream source, license, scripts, and test notes; the two large upstream WAV samples are omitted. No local Git history or user settings.
- `snapshot/`: ALSA mixer state and audio-related package versions. Treat mixer state as a comparison reference, not a universal configuration to load blindly.
- `check-audio.sh`: read-only checks for installed kernel builds; no installation, volume changes, or restarts.
- `SHA256SUMS`: integrity checks for included files; run `sha256sum -c SHA256SUMS` from this directory.

MAC addresses, personal home paths, live application lists, pairing keys, private signing keys, and unrelated installed software were excluded. This cannot guarantee future compatibility, preserve all RPMs, or establish whether previous macOS trouble was software or hardware related.

## Credits and references

- [Original driver and contributors](https://github.com/davidjo/snd_hda_macbookpro)
- [Exact source revision](https://github.com/davidjo/snd_hda_macbookpro/tree/89b22ff90b86468b186706861dd18663562defa7)
- [WirePlumber profile settings](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/settings.html)
- [DKMS](https://github.com/dell/dkms)

See LICENSE and NOTICE.md. Contributions documenting reproducible hardware/kernel results are welcome; avoid publishing personal device identifiers in logs.

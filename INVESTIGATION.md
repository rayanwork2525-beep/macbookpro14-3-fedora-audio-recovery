# Deeper investigation: MacBookPro14,3 audio

Investigation date: 13 November 2026. No codec, volume, driver, or DSP changes were made during this investigation.

## Main result

The current Linux speaker path is explained by a previously installed Apple-specific CS8409 driver. Its source explicitly matches subsystem 106b3900, configures the model's amplifier paths, and mirrors stereo playback to the second converter. This establishes how audio works now. It does not prove which macOS fault caused the previous distortion.

The owner's clarified symptoms were severe speaker crackling/distortion and Bluetooth beeps/crackles/dropouts. Those symptoms make a headset-profile-only explanation insufficient. Speaker gain/processing/routing and Bluetooth transport stability require separate investigation.

## Evidence found locally

- The custom driver source files have October 14 timestamps; the DKMS source link has an October 14 timestamp, and the current kernel's DKMS make.log records an October 19 build. A previous boot also loaded the same Apple-specific path. These show a pre-existing installation, not something installed during this chat. Clock discontinuities appear in the journal, so exact historical dates are tentative.
- The captured source is commit 89b22ff90b86468b186706861dd18663562defa7. The 14,3 branch calls cs_8409_setup_amp_max; 14,1/14,2 take a different amplifier branch. Settings intended for another Mac model should not be assumed transferable.
- During active speaker playback, ALSA reported S32_LE, two channels, 44100 Hz. Converter nodes 0x02 and 0x03 both reported stream=1, channel=0. The source explicitly sets the second converter to channel 0 for stereo. This supports correct stereo duplication; it does not acoustically prove that every individual speaker is healthy.
- The browser stream was 48 kHz while the hardware stream was 44.1 kHz. PipeWire was converting the rate. This is normal supported processing, not by itself evidence of audible damage or a reason to force 192 kHz.
- The inspected graph contained a direct browser-to-speaker route and no visible external EQ filter. A brief pw-top sample showed ERR=0 for speaker playback. This is a limited software observation, not an acoustic distortion measurement or a long-term stability guarantee.
- The Q45 was configured for A2DP/SBC. Available alternatives included AAC and SBC-XQ. No LDAC profile was exposed in the current connection.
- Fedora already has the LDAC plugin and its encoder/bitrate-control libraries installed; ldd resolved them. Missing LDAC packages are therefore not the obvious cause of its absence.
- Earlier in this boot, PipeWire/WirePlumber logged Bluetooth transport failures. They could coincide with disconnects or mode changes; the logs alone do not establish recurring packet loss during steady listening. Boot logs also contain Broadcom baudrate/firmware warnings despite successful audio later. Do not change firmware based solely on those warnings.

## Explanation and uncertainty

Linux uses a different speaker initialization, routing, gain and processing path from macOS. The community driver supplies the model-specific hardware setup needed here. A change in that path could avoid a prior processing or gain fault, or could simply excite a damaged speaker differently. Software cannot repair a physically torn speaker. The present improvement is evidence that the machine can produce pleasing sound in this configuration, not proof that all hardware is fault-free.

Bluetooth uses its own Broadcom/BlueZ/PipeWire path. Beeps and crackles can arise from transport interruptions, radio interference, competing connections, or buffering. The current evidence cannot distinguish those from the historical macOS problem. Headset mode can reduce music quality, but should not be treated as the established cause of the reported dropouts.

## Improvements, ranked by usefulness

1. **Protect recovery first.** Preserve a working bootable kernel and verify each new kernel's DKMS build. The GitHub source snapshot is not a bootable backup or an automatic update guard.
2. **Establish a stable listening baseline.** Use the same passage and comfortable volume on SBC, with the computer nearby. Observe uninterrupted playback and log errors. Then change only one variable at a time. A brief desktop error counter cannot replace this listening test.
3. **Compare AAC and SBC-XQ.** Both are already offered. Compare at matched perceived loudness; record crackles/dropouts as well as preference. Return to SBC if either is worse. These are candidates, not guaranteed upgrades.
4. **Investigate LDAC after stability.** Soundcore says Q45 supports LDAC and enables it through Settings > Sound Mode > Preferred Audio Quality in its app. Soundcore also says LDAC is unavailable with multipoint. Check those headphone-side settings before adding Linux packages or overriding codec lists. The app menu's availability on a particular phone still needs checking. Reconnect and verify that Linux actually exposes/selects LDAC. Start with adaptive bitrate; high bitrate may worsen an unstable radio link.
5. **Tune speaker tone conservatively.** A bypassable, speaker-only software EQ with headroom is a useful experiment once the baseline is repeatable. Start with modest cuts of objectionable frequencies, not bass boost or amplifier register changes. No measured response or model-specific tuning has been established here, so no universal EQ numbers are justified.
6. **Consider per-speaker DSP as research.** Upstream issue #179 discusses extracting Apple's EQ data, but its example targets a 2017 iMac, not this MacBook. Model/speaker identification, channel mapping and measurements would be required before borrowing settings. The maintainer specifically cautions about loudness processing and speaker protection. A digital limiter alone does not establish thermal or excursion protection.

## Source references

- [Pinned driver source](https://github.com/davidjo/snd_hda_macbookpro/tree/89b22ff90b86468b186706861dd18663562defa7)
- [Model identification and Apple initialization](https://github.com/davidjo/snd_hda_macbookpro/blob/89b22ff90b86468b186706861dd18663562defa7/patch_cirrus/cirrus_apple.h)
- [Amplifier setup and stereo converter mapping](https://github.com/davidjo/snd_hda_macbookpro/blob/89b22ff90b86468b186706861dd18663562defa7/patch_cirrus/patch_cirrus_real84.h)
- [Soundcore Q45 codec support and LDAC menu](https://service.soundcore.com/article-description/soundcore-Space-Q45-Headphones-FAQ)
- [Soundcore LDAC/multipoint restriction](https://service.soundcore.com/article-description/How-to-Stop-Interruptions-While-Listening-in-Multipoint-or-LDAC-Mode)
- [WirePlumber codec configuration](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/bluetooth.html)
- [Experimental Apple tuning discussion, model-specific](https://github.com/davidjo/snd_hda_macbookpro/issues/179)

# Shivansh Timer v9.0 User Manual

Arduino Uno + Multi-Function Shield timer, clock, games, and tools firmware.

## 1. Overview

Shivansh Timer v9.0 has 24 modes:

1. Clock
2. Countdown 1 minute
3. Countdown 2 minutes
4. Countdown 3 minutes
5. Countdown 4 minutes
6. Countdown 5 minutes
7. Countdown 10 minutes
8. Countdown 15 minutes
9. Countdown 20 minutes
10. Countdown 25 minutes
11. Countdown 30 minutes
12. Countdown 40 minutes
13. Countdown 50 minutes
14. Countdown 60 minutes
15. Countdown 90 minutes
16. Countdown 2 hours
17. Countdown 2.5 hours
18. Countdown 3 hours
19. Stopwatch
20. Counter
21. Reaction Timer
22. Interval Timer
23. Simon Says
24. Chess

The firmware is designed for an Arduino Uno with a standard Multi-Function Shield. It uses the shield display, three buttons, buzzer, and four LEDs.

## 2. Hardware

Required:

- Arduino Uno
- Multi-Function Shield
- TimerOne library
- MultiFuncShield library

Optional:

- DS1307/DS3231-style RTC module at I2C address `0x68`

The firmware automatically checks for an RTC. If one is found, Clock mode reads it. If no RTC is found, Clock mode uses a millis-based uptime clock.

## 3. Controls

The shield has three buttons:

- `B1`: left button
- `B2`: middle button
- `B3`: right button

Each button supports:

- Short press: quick tap
- Long press: hold for about one second

Global controls:

| Action | Result |
|---|---|
| B1 short | Next mode, when allowed |
| B1 long | Previous mode, when allowed |
| B3 long | Home, returns to Mode 1 Clock |
| Hold B2+B3 | Toggle Silent Mode |

Mode switching is blocked while countdown, stopwatch, interval, chess, or Simon active play is running. Stop or pause first if B1 navigation does not respond.

## 4. Display Format

The 4-digit display uses compact codes:

| Display | Meaning |
|---|---|
| `P-01` to `P-24` | Mode intro screen |
| `HHMM` | Clock or time value |
| `MMSS` | Minutes and seconds |
| `1H30` | 1 hour 30 minutes |
| `END` | Countdown finished |
| `HoME` | Returned to Clock |
| `BACK` | Previous mode selected |
| `rSEt` | Quick restart |
| `none` | No saved result yet |
| `bESt` / `BEST` | Best saved result |
| `AVG` | Average saved result |

For time values under 1 hour, the format is `MMSS`. For 1 hour or more, the format is `HMM`, shown with `H`, for example `2H30`.

## 5. LEDs

Countdown modes use LEDs as groups:

| Modes | Countdown group | LED |
|---|---|---|
| 2-6 | 1 to 5 minutes | LED1 |
| 7-10 | 10 to 25 minutes | LED2 |
| 11-14 | 30 to 60 minutes | LED3 |
| 15-18 | 90 minutes to 3 hours | LED4 |

Special modes normally leave LEDs off, except Chess:

- LED1 on: Player 1 active
- LED2 on: Player 2 active
- LED1 and LED2 slow blink: Chess paused

## 6. Sound and Silent Mode

Normal button actions and mode entries use short beeps.

Silent Mode:

1. Hold `B2+B3`.
2. Display shows `SILn`.
3. On release, display shows `ON` or `OFF`.

When Silent Mode is ON, normal beeps are disabled. Timeout alarms still sound.

Silent Mode is saved in EEPROM and restored after reboot.

## 7. EEPROM Saved Settings

The firmware saves:

- Last used mode
- Display brightness
- Clock 12/24-hour preference
- Alarm hour, minute, and enabled state
- Silent Mode state
- Last Chess preset
- Whether a mode was active/running before power loss

Writes are protected by only updating EEPROM when a value changes.

Boot behavior:

- If the previous session was idle, the firmware restores the last used mode.
- If the previous session was active or running, the firmware boots into Clock mode.

## 8. Mode 1: Clock

Display:

- Normal: `HHMM`
- The decimal point blinks like a clock colon.

Time source:

- RTC if present at I2C address `0x68`
- Otherwise millis-based uptime clock starting from the firmware default time

Clock controls:

| Button | Action |
|---|---|
| B1 short | Next mode |
| B1 long | Previous mode |
| B2 short | Toggle 12-hour / 24-hour display |
| B2 long | Cycle brightness |
| B3 short with RTC present | Refresh clock from RTC |
| B3 short without RTC | Enter alarm set |
| B3 long with RTC present | Enter alarm set |
| B3 long without RTC | Enter manual time set |

12/24-hour display:

- `12H` means 12-hour display
- `24H` means 24-hour display

Brightness:

- `Br-1`
- `Br-2`
- `Br-3`

Brightness is saved in EEPROM.

Manual time set, for no-RTC use:

| SET screen | Meaning |
|---|---|
| `H 12` | Set hour, 24-hour value |
| `n 34` | Set minute |
| `SAVE` | Save the entered time |

Manual set controls:

| Button | Action |
|---|---|
| B1 short | Increase current field by 1 |
| B1 long | Increase current field by 10 |
| B3 short | Decrease current field by 1 |
| B2 short | Next field, then save on `SAVE` |
| B3 long | Cancel without saving |

When saved, seconds reset to zero and the millis-based clock starts from the entered time. Manual time is not a real-time clock replacement; after power loss, use B3 long again to set the time unless an RTC module is installed.

Alarm set:

| SET screen | Meaning |
|---|---|
| `AH07` | Set alarm hour, 24-hour value |
| `An30` | Set alarm minute |
| `A ON` | Alarm enabled |
| `AOFF` | Alarm disabled |
| `SAVE` | Save alarm settings |

Alarm set controls:

| Button | Action |
|---|---|
| B1 short | Increase current field by 1 |
| B1 long | Increase current field by 10 |
| B3 short | Decrease current field by 1 |
| B2 short | Next field, then save on `SAVE` |
| B2 long on ON/OFF field | Toggle alarm ON/OFF |
| B3 long | Cancel without saving |

Alarm behavior:

- When enabled and the clock reaches the alarm time, display flashes `ALrm`.
- Alarm beeps repeat until dismissed.
- Any short button press dismisses the alarm.
- Any long button press snoozes for 5 minutes.
- Alarm beeps are not silenced by Silent Mode.
- Alarm settings are saved in EEPROM.

## 9. Modes 2-18: Countdown Timers

Countdown mode list:

| Mode | Duration | Intro value |
|---:|---|---|
| 2 | 1 minute | `0100` |
| 3 | 2 minutes | `0200` |
| 4 | 3 minutes | `0300` |
| 5 | 4 minutes | `0400` |
| 6 | 5 minutes | `0500` |
| 7 | 10 minutes | `1000` |
| 8 | 15 minutes | `1500` |
| 9 | 20 minutes | `2000` |
| 10 | 25 minutes | `2500` |
| 11 | 30 minutes | `3000` |
| 12 | 40 minutes | `4000` |
| 13 | 50 minutes | `5000` |
| 14 | 60 minutes | `1H00` |
| 15 | 90 minutes | `1H30` |
| 16 | 2 hours | `2H00` |
| 17 | 2.5 hours | `2H30` |
| 18 | 3 hours | `3H00` |

Countdown controls:

| Button | Action |
|---|---|
| B1 short | Next mode, only when stopped |
| B1 long | Previous mode, only when stopped |
| B2 short | Start / pause |
| B2 long | Quick restart and run |
| B3 short | Stop and reset to full duration |
| B3 long | Home |

Display behavior:

- While paused, the display blinks slowly.
- During the last 10 seconds, the display blinks quickly.
- At zero, display shows `END` and the timeout alarm sounds.

## 10. Mode 19: Stopwatch

The stopwatch counts upward from `0000`.

Controls:

| Button | Action |
|---|---|
| B1 short | Next mode, only when stopped |
| B1 long | Previous mode, only when stopped |
| B2 short | Start / pause |
| B2 long | Cycle lap statistics |
| B3 short while running | Record lap |
| B3 short while stopped | Reset stopwatch and lap data |
| B3 long | Home |

Lap statistics:

- First B2 long view: `bESt`, then best lap
- Next B2 long view: `AVG`, then average lap
- If no laps exist, display shows `none`

The best lap and average lap are session values. They reset when the stopwatch is reset or the mode state is reset.

## 11. Mode 20: Counter

Counter mode counts events from `0000` to `9999`.

Controls:

| Button | Action |
|---|---|
| B1 short | Next mode |
| B1 long | Previous mode |
| B2 short | Add 1 |
| B2 long | Subtract 1 |
| B3 short | Reset to 0 |
| B3 long | Home |

At `9999`, adding one wraps back to `0000`. Subtract will not go below zero.

## 12. Mode 21: Reaction Timer

Reaction Timer measures how quickly you press B2 after the `GO` signal.

Phases:

| Display | Meaning |
|---|---|
| `PUSH` | Ready, press B2 to start |
| `----` | Waiting for random delay |
| `GO` | Press B2 now |
| number | Reaction time in milliseconds |
| `ERLY` | Pressed too early |

Controls:

| Button | Action |
|---|---|
| B1 short | Next mode |
| B1 long | Previous mode |
| B2 short from `PUSH` | Start attempt |
| B2 short during `----` | Early press, cancel attempt |
| B2 short during `GO` | Record result |
| B2 short after result | Start another attempt |
| B2 long | Cycle `BEST` and `AVG` |
| B3 short | Cancel/reset to `PUSH` |
| B3 long | Home |

Statistics:

- Stores the last 5 successful attempts.
- `BEST` shows the fastest attempt.
- `AVG` shows the average of stored attempts.
- If no successful attempts exist, display shows `none`.

## 13. Mode 22: Interval Timer

Interval Timer cycles between:

- `WORK`: 45 seconds
- `rESt`: 15 seconds

Controls:

| Button | Action |
|---|---|
| B1 short | Next mode, only when stopped |
| B1 long | Previous mode, only when stopped |
| B2 short | Start / pause |
| B2 long | Skip to the next phase |
| B3 short | Stop and reset to WORK |
| B3 long | Home |

When a phase changes, the display briefly shows `WORK` or `rESt`.

## 14. Mode 23: Simon Says

Simon Says is a memory game. The timer plays a sequence using buttons B1, B2, and B3. Repeat the sequence in the same order.

Displays:

| Display | Meaning |
|---|---|
| `SiMn` | Simon idle screen |
| `bt1` | Press B1 |
| `bt2` | Press B2 |
| `bt3` | Press B3 |
| `go` | Your turn |
| `GooD` | Round complete |
| `FAIL` | Wrong button |
| `WIN!` | Completed all rounds |
| `FAST` | Fast mode enabled |

Controls:

| Button | Action |
|---|---|
| B1/B2/B3 during `go` | Game input |
| B2 short from idle/fail/win | Start game |
| B2 long from idle | Enable FAST mode for this session |
| B2 long after playing | Show best round |
| B3 short | Abandon and reset to `SiMn` |
| B3 long | Home |

FAST mode:

- Activate by holding B2 before starting a game.
- Display shows `FAST`.
- Playback speed changes from about 700 ms to about 350 ms per step.
- FAST mode is session-only and does not persist after mode reset.

Best round:

- B2 long shows the best completed round as `r-XX`.
- If no round is saved, display shows `none`.

## 15. Mode 24: Chess

Chess mode is a configurable two-player chess clock.

Preset selection happens before the game starts.

Presets:

| Preset | Display |
|---|---|
| 5+0 | `C050` |
| 5+3 | `C053` |
| 10+0 | `C100` |
| 10+5 | `C105` |
| 15+10 | `C151` |
| 30+0 | `C300` |

Preset selection controls:

| Button | Action |
|---|---|
| B1 short | Previous preset |
| B3 short | Next preset |
| B2 short | Start game |
| B1 long | Previous mode |
| B3 long | Home |

The last selected chess preset is saved in EEPROM.

Gameplay:

- Player 1 is controlled by B1.
- Player 2 is controlled by B3.
- B2 pauses and resumes.
- Player 1 starts active.
- Display shows the active player's remaining time only.
- LED1 means Player 1 is active.
- LED2 means Player 2 is active.

Move handoff:

| Active player | Valid press | Result |
|---|---|---|
| Player 1 | B1 | Add increment to Player 1, switch to Player 2 |
| Player 2 | B3 | Add increment to Player 2, switch to Player 1 |

Invalid player presses are ignored.

Pause behavior:

| Button while paused | Action |
|---|---|
| B2 short | Resume |
| B2 long | Show total moves as `M023` style display |
| B3 long | Home |

Warnings and timeout:

- When the active player has 10 seconds or less, the display blinks quickly.
- When paused, the display and LEDs blink slowly.
- If Player 1 runs out of time, display shows `FLG1`.
- If Player 2 runs out of time, display shows `FLG2`.
- Timeout alarm plays 5 beeps even if Silent Mode is ON.

After timeout:

| Button | Action |
|---|---|
| B2 short | Restart chess preset selection |
| B3 short | Exit to Clock |
| B3 long | Exit to Clock |

## 16. Diagnostic Mode

Diagnostic Mode is hidden.

To enter:

1. Hold B1+B2+B3.
2. Power on or reset the Arduino while holding all three buttons.
3. Display shows `tESt`.

Diagnostic checks:

- Display test
- Button input indication
- LED test
- Buzzer test

Exit:

- Press B3.

## 17. Quick Reference

All modes:

| Control | General meaning |
|---|---|
| B1 short | Next mode |
| B1 long | Previous mode |
| B2 short | Main action |
| B2 long | Secondary/stat/settings action |
| B3 short | Reset/cancel/lap/game action |
| B3 long | Home |

Home always means Mode 1 Clock.

## 18. Troubleshooting

| Problem | Cause / Fix |
|---|---|
| B1 does not change mode | Stop or pause the active mode first. |
| Clock time resets after power cycle | No RTC is installed or the RTC was not detected. |
| Clock is drifting | millis-based fallback clock is running; install/use an RTC for better accuracy. |
| No normal beeps | Silent Mode is ON. Hold B2+B3 to toggle it. |
| Timeout still beeps in Silent Mode | This is intentional. Timeout alarms are never silenced. |
| Alarm does not ring | Check that alarm set screen shows `A ON`, and confirm the clock time is correct. |
| Chess ignores B1 or B3 | Only the active player's valid handoff button works. |
| Stopwatch average shows `none` | No lap has been recorded yet. |
| Reaction BEST/AVG shows `none` | No successful attempts have been recorded yet. |
| Device boots to Clock instead of last mode | Previous mode was active/running when power was lost. |

## 19. Technical Notes

- Firmware version: Shivansh Timer v9.0
- Total modes: 24
- Dynamic allocation: none used
- EEPROM writes: only on value change
- Timing: millis-based nonblocking loop
- Main libraries: TimerOne, MultiFuncShield, EEPROM, Wire

Compile result on Arduino Uno:

- Flash: 21466 bytes of 32256 bytes
- SRAM: 1024 bytes of 2048 bytes
- Standard sketch compile warnings: none
- `--warnings all` may show warnings from the installed MultiFuncShield library source; these are library warnings, not v9 sketch warnings.

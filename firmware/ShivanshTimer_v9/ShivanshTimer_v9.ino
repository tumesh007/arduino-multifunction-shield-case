// ============================================================
//  Shivansh Multi-Function Shield Timer v9.0
//  Arduino Uno + MultiFuncShield + TimerOne
//
//  Mode  1 : Clock
//  Modes 2-18 : Countdown timers
//  Mode 19 : Stopwatch
//  Mode 20 : Tally Counter
//  Mode 21 : Reaction Timer
//  Mode 22 : Interval Timer
//  Mode 23 : Simon Says
//  Mode 24 : Configurable Chess Clock
// ============================================================

#include <TimerOne.h>
#include <MultiFuncShield.h>
#include <EEPROM.h>
#include <Wire.h>

const byte LED1_PIN = 13;
const byte LED2_PIN = 12;
const byte LED3_PIN = 11;
const byte LED4_PIN = 10;

const byte MODE_CLOCK     = 0;
const byte MODE_STOPWATCH = 18;
const byte MODE_COUNTER   = 19;
const byte MODE_REACTION  = 20;
const byte MODE_INTERVAL  = 21;
const byte MODE_SIMON     = 22;
const byte MODE_CHESS     = 23;
const byte TOTAL_MODES    = 24;

const byte COUNTDOWN_FIRST = 1;
const byte COUNTDOWN_LAST  = 17;

const unsigned long BLINK_SLOW = 500;
const unsigned long BLINK_FAST = 150;
const unsigned long WORK_TIME  = 45;
const unsigned long REST_TIME  = 15;

const unsigned long timerOptions[17] = {
  60UL, 120UL, 180UL, 240UL, 300UL,
  600UL, 900UL, 1200UL, 1500UL,
  1800UL, 2400UL, 3000UL, 3600UL,
  5400UL, 7200UL, 9000UL, 10800UL
};

enum EepromAddr {
  EE_MAGIC = 0,
  EE_LAST_MODE = 1,
  EE_BRIGHTNESS = 2,
  EE_CLOCK_12H = 3,
  EE_SILENT = 4,
  EE_CHESS_PRESET = 5,
  EE_WAS_ACTIVE = 6,
  EE_ALARM_HOUR = 7,
  EE_ALARM_MIN = 8,
  EE_ALARM_ON = 9
};

const byte EEPROM_MAGIC = 0x59;

byte currentMode = MODE_CLOCK;
unsigned long timeTracker = 0;
long counterValue = 0;
bool isRunning = false;
unsigned long previousMillis = 0;

bool blinkOn = true;
unsigned long lastBlinkMs = 0;

char overlayText[5] = "";
unsigned long overlayUntil = 0;
char overlayNextText[5] = "";
unsigned long overlayNextMs = 0;

byte brightnessLevel = 1;  // user levels 1..3, mapped to MFS 0..2
bool silentMode = false;
bool lastActiveSaved = false;

bool diagMode = false;
byte diagStep = 0;
unsigned long diagLast = 0;

// Clock
byte ckHour = 12;
byte ckMin = 0;
byte ckSec = 0;
bool ck12hr = false;
bool ckRtcPresent = false;
unsigned long ckPrevMs = 0;
bool ckColonOn = true;
bool ckSetMode = false;
byte ckSetField = 0; // 0 hour, 1 minute, 2 save
byte ckSetH = 12;
byte ckSetM = 0;
unsigned long ckSetBlinkMs = 0;
bool ckSetBlinkOn = true;
bool alSetMode = false;
byte alSetField = 0; // 0 hour, 1 minute, 2 on/off, 3 save
byte alHour = 7;
byte alMin = 0;
byte alSetH = 7;
byte alSetM = 0;
bool alOn = false;
bool alSetOn = false;
bool alFiring = false;
unsigned long alLastBeep = 0;
int alLastTriggerMinute = -1;

// Reaction
byte rxPhase = 0; // 0 idle, 1 waiting, 2 go, 3 result
unsigned long rxGoDelay = 0;
unsigned long rxPhaseStart = 0;
unsigned long rxResult = 0;
unsigned long rxAttempts[5] = {0, 0, 0, 0, 0};
byte rxAttemptCount = 0;
byte rxAttemptPos = 0;
byte rxStatView = 0;

// Interval
bool intIsWork = true;

// Stopwatch
unsigned long swBestLap = 0;
unsigned long swLapSum = 0;
byte swLapCount = 0;
byte swStatView = 0;

// Simon
const byte SI_MAX_LEN = 10;
const unsigned int SI_NORMAL_MS = 700;
const unsigned int SI_FAST_MS = 350;
byte siPhase = 0; // 0 idle, 1 playback, 2 input, 3 win, 4 fail
byte siSequence[SI_MAX_LEN];
byte siLength = 0;
byte siPlayIndex = 0;
byte siInputIndex = 0;
unsigned long siStepStart = 0;
byte siBest = 0;
bool siFast = false;
bool siBlank = false;
const char * const SI_LABELS[4] = { "    ", "bt1 ", "bt2 ", "bt3 " };

// Chess
struct ChessPreset {
  unsigned int baseMin;
  byte increment;
};

const ChessPreset chessPresets[6] = {
  {5, 0}, {5, 3}, {10, 0}, {10, 5}, {15, 10}, {30, 0}
};

byte chessPreset = 0;
byte chessState = 0; // 0 select, 1 running, 2 paused, 3 flagged
byte chessActive = 1;
unsigned long chessP1 = 300;
unsigned long chessP2 = 300;
unsigned int chessMoves = 0;
byte chessFlaggedPlayer = 0;
bool chessBlinkOn = true;

byte bcdToDec(byte v) {
  return (byte)((v >> 4) * 10 + (v & 0x0F));
}

void beepIf(unsigned int onPeriod = 20, unsigned int offPeriod = 0, byte cycles = 1, bool force = false) {
  if (!silentMode || force) MFS.beep(onPeriod, offPeriod, cycles);
}

void eepromWriteByte(byte addr, byte value) {
  if (EEPROM.read(addr) != value) EEPROM.update(addr, value);
}

void saveActive(bool active) {
  if (lastActiveSaved != active) {
    lastActiveSaved = active;
    eepromWriteByte(EE_WAS_ACTIVE, active ? 1 : 0);
  }
}

void saveMode() {
  eepromWriteByte(EE_LAST_MODE, currentMode);
}

void showOverlay(const char *text, unsigned long ms) {
  for (byte i = 0; i < 4; i++) overlayText[i] = text[i] ? text[i] : ' ';
  overlayText[4] = '\0';
  overlayUntil = millis() + ms;
  overlayNextMs = 0;
  MFS.write(overlayText);
}

bool overlayActive() {
  if (overlayUntil == 0) return false;
  if ((long)(millis() - overlayUntil) < 0) return true;
  overlayUntil = 0;
  if (overlayNextMs > 0) {
    for (byte i = 0; i < 4; i++) overlayText[i] = overlayNextText[i];
    overlayText[4] = '\0';
    overlayUntil = millis() + overlayNextMs;
    overlayNextMs = 0;
    MFS.write(overlayText);
    return true;
  }
  return false;
}

void queueOverlay(const char *text, unsigned long ms) {
  for (byte i = 0; i < 4; i++) overlayNextText[i] = text[i] ? text[i] : ' ';
  overlayNextText[4] = '\0';
  overlayNextMs = ms;
}

bool rawPressed(byte pin) {
  return digitalRead(pin) == LOW;
}

void updateDisplay();

void allLEDsOff() {
  digitalWrite(LED1_PIN, HIGH);
  digitalWrite(LED2_PIN, HIGH);
  digitalWrite(LED3_PIN, HIGH);
  digitalWrite(LED4_PIN, HIGH);
}

void setChessLed() {
  allLEDsOff();
  if (chessState == 1) {
    digitalWrite(chessActive == 1 ? LED1_PIN : LED2_PIN, LOW);
  } else if (chessState == 2 && chessBlinkOn) {
    digitalWrite(LED1_PIN, LOW);
    digitalWrite(LED2_PIN, LOW);
  }
}

bool isCountdownMode() {
  return currentMode >= COUNTDOWN_FIRST && currentMode <= COUNTDOWN_LAST;
}

byte countdownIndex() {
  return (byte)(currentMode - COUNTDOWN_FIRST);
}

void updateLEDs() {
  allLEDsOff();
  if (currentMode == MODE_CHESS) {
    setChessLed();
  } else if (isCountdownMode()) {
    byte idx = countdownIndex();
    if (idx <= 4) digitalWrite(LED1_PIN, LOW);
    else if (idx <= 8) digitalWrite(LED2_PIN, LOW);
    else if (idx <= 12) digitalWrite(LED3_PIN, LOW);
    else digitalWrite(LED4_PIN, LOW);
  }
}

void formatTime(char *buf, unsigned long s) {
  if (s >= 3600UL) {
    unsigned long h = s / 3600UL;
    unsigned long m = (s % 3600UL) / 60UL;
    if (h > 9) h = 9;
    sprintf(buf, "%luH%02lu", h, m);
  } else {
    sprintf(buf, "%02lu%02lu", s / 60UL, s % 60UL);
  }
}

void writeTime(unsigned long s) {
  char buf[5];
  formatTime(buf, s);
  MFS.write(buf);
}

void writeClockTime() {
  byte h = ckHour;
  if (ck12hr) {
    if (h == 0) h = 12;
    else if (h > 12) h -= 12;
  }
  if (ckColonOn) {
    float v = h + ckMin / 100.0f;
    MFS.write(v, 2);
  } else {
    char buf[5];
    sprintf(buf, "%02u%02u", h, ckMin);
    MFS.write(buf);
  }
}

void writeClockSet() {
  char buf[5];
  if (ckSetField == 0) {
    if (ckSetBlinkOn) sprintf(buf, "H %02u", ckSetH);
    else strcpy(buf, "H   ");
  } else if (ckSetField == 1) {
    if (ckSetBlinkOn) sprintf(buf, "n %02u", ckSetM);
    else strcpy(buf, "n   ");
  } else {
    strcpy(buf, "SAVE");
  }
  MFS.write(buf);
}

void startClockSet() {
  ckSetMode = true;
  ckSetField = 0;
  ckSetH = ckHour;
  ckSetM = ckMin;
  ckSetBlinkOn = true;
  ckSetBlinkMs = millis();
  beepIf(8, 80, 1);
  writeClockSet();
}

void cancelClockSet() {
  ckSetMode = false;
  ckSetField = 0;
  ckSetBlinkOn = true;
  beepIf(8, 50, 1);
  updateDisplay();
}

void saveClockSet() {
  ckHour = ckSetH;
  ckMin = ckSetM;
  ckSec = 0;
  ckPrevMs = millis();
  ckColonOn = true;
  ckSetMode = false;
  ckSetField = 0;
  beepIf(10, 60, 2);
  updateDisplay();
}

void adjustClockSet(int delta) {
  if (ckSetField == 0) ckSetH = (byte)((ckSetH + 24 + delta) % 24);
  else if (ckSetField == 1) ckSetM = (byte)((ckSetM + 60 + delta) % 60);
  ckSetBlinkOn = true;
  ckSetBlinkMs = millis();
  writeClockSet();
}

void writeAlarmSet() {
  char buf[5];
  if (alSetField == 0) {
    if (ckSetBlinkOn) sprintf(buf, "AH%02u", alSetH);
    else strcpy(buf, "AH  ");
  } else if (alSetField == 1) {
    if (ckSetBlinkOn) sprintf(buf, "An%02u", alSetM);
    else strcpy(buf, "An  ");
  } else if (alSetField == 2) {
    strcpy(buf, alSetOn ? "A ON" : "AOFF");
  } else {
    strcpy(buf, "SAVE");
  }
  MFS.write(buf);
}

void startAlarmSet() {
  alSetMode = true;
  alSetField = 0;
  alSetH = alHour;
  alSetM = alMin;
  alSetOn = alOn;
  ckSetBlinkOn = true;
  ckSetBlinkMs = millis();
  beepIf(8, 80, 1);
  writeAlarmSet();
}

void cancelAlarmSet() {
  alSetMode = false;
  alSetField = 0;
  ckSetBlinkOn = true;
  beepIf(8, 50, 1);
  updateDisplay();
}

void saveAlarmSet() {
  alHour = alSetH;
  alMin = alSetM;
  alOn = alSetOn;
  alFiring = false;
  alSetMode = false;
  alSetField = 0;
  eepromWriteByte(EE_ALARM_HOUR, alHour);
  eepromWriteByte(EE_ALARM_MIN, alMin);
  eepromWriteByte(EE_ALARM_ON, alOn ? 1 : 0);
  beepIf(10, 60, 2);
  updateDisplay();
}

void adjustAlarmSet(int delta) {
  if (alSetField == 0) alSetH = (byte)((alSetH + 24 + delta) % 24);
  else if (alSetField == 1) alSetM = (byte)((alSetM + 60 + delta) % 60);
  else if (alSetField == 2) alSetOn = !alSetOn;
  ckSetBlinkOn = true;
  ckSetBlinkMs = millis();
  writeAlarmSet();
}

void writeCounter() {
  MFS.write((int)counterValue);
}

void writeChessPreset() {
  char buf[5];
  byte inc = chessPresets[chessPreset].increment;
  byte d = inc >= 10 ? (byte)(inc / 10) : inc;
  sprintf(buf, "C%02u%u", chessPresets[chessPreset].baseMin, d);
  MFS.write(buf);
}

void writeMoves() {
  char buf[5];
  unsigned int shown = chessMoves > 999 ? 999 : chessMoves;
  sprintf(buf, "M%03u", shown);
  MFS.write(buf);
}

void updateDisplay();

void showModeIntro() {
  char buf[5];
  sprintf(buf, "P-%02u", currentMode + 1);
  showOverlay(buf, 550);
  if (isCountdownMode()) {
    byte idx = countdownIndex();
    if (idx <= 4) beepIf(8, 120, 1);
    else if (idx <= 8) beepIf(8, 120, 2);
    else if (idx <= 12) beepIf(8, 120, 3);
    else beepIf(8, 120, 4);
  } else {
    beepIf(20, 80, 2);
  }
}

void resetModeState() {
  isRunning = false;
  rxPhase = 0;
  rxResult = 0;
  intIsWork = true;
  swBestLap = 0;
  swLapSum = 0;
  swLapCount = 0;
  siPhase = 0;
  siLength = 0;
  siPlayIndex = 0;
  siInputIndex = 0;
  siFast = false;
  chessState = 0;
  chessActive = 1;
  chessFlaggedPlayer = 0;
  chessMoves = 0;
  ckSetMode = false;
  ckSetField = 0;
  alSetMode = false;
  blinkOn = true;
  chessBlinkOn = true;
  lastBlinkMs = 0;
  saveActive(false);
}

void setupModeValue() {
  if (isCountdownMode()) timeTracker = timerOptions[countdownIndex()];
  else if (currentMode == MODE_INTERVAL) timeTracker = WORK_TIME;
  else timeTracker = 0;
  if (currentMode == MODE_CHESS) {
    chessP1 = (unsigned long)chessPresets[chessPreset].baseMin * 60UL;
    chessP2 = chessP1;
  }
}

void enterMode(byte mode, bool intro) {
  currentMode = mode % TOTAL_MODES;
  resetModeState();
  setupModeValue();
  updateLEDs();
  saveMode();
  if (intro) showModeIntro();
  else updateDisplay();
}

void nextMode() {
  enterMode((byte)((currentMode + 1) % TOTAL_MODES), true);
}

void prevMode() {
  byte next = currentMode == 0 ? (TOTAL_MODES - 1) : (currentMode - 1);
  enterMode(next, false);
  showOverlay("BACK", 450);
  beepIf(12, 80, 1);
}

void homeMode() {
  enterMode(MODE_CLOCK, false);
  showOverlay("HoME", 650);
  beepIf(15, 60, 3);
}

void readClockRtc() {
  Wire.beginTransmission(0x68);
  Wire.write((byte)0);
  if (Wire.endTransmission() != 0) {
    ckRtcPresent = false;
    return;
  }
  Wire.requestFrom((uint8_t)0x68, (uint8_t)3);
  if (Wire.available() < 3) {
    ckRtcPresent = false;
    return;
  }
  byte s = Wire.read();
  byte m = Wire.read();
  byte h = Wire.read();
  if (s & 0x80) {
    ckRtcPresent = false;
    return;
  }
  ckSec = bcdToDec(s & 0x7F);
  ckMin = bcdToDec(m & 0x7F);
  if (h & 0x40) {
    byte hr = bcdToDec(h & 0x1F);
    bool pm = h & 0x20;
    if (hr == 12) hr = 0;
    ckHour = (byte)(hr + (pm ? 12 : 0));
  } else {
    ckHour = bcdToDec(h & 0x3F);
  }
  if (ckHour < 24 && ckMin < 60 && ckSec < 60) ckRtcPresent = true;
}

void updateClock() {
  if (ckSetMode || alSetMode || alFiring) return;
  unsigned long now = millis();
  if (now - ckPrevMs < 1000UL) return;
  ckPrevMs += 1000UL;
  if (ckRtcPresent) {
    readClockRtc();
  } else {
    ckSec++;
    if (ckSec >= 60) {
      ckSec = 0;
      ckMin++;
      if (ckMin >= 60) {
        ckMin = 0;
        ckHour = (byte)((ckHour + 1) % 24);
      }
    }
  }
  if (alOn && ckSec == 0) {
    int minuteOfDay = ckHour * 60 + ckMin;
    if (ckHour == alHour && ckMin == alMin && minuteOfDay != alLastTriggerMinute) {
      alFiring = true;
      alLastBeep = 0;
      alLastTriggerMinute = minuteOfDay;
      blinkOn = true;
      lastBlinkMs = now;
      MFS.write("ALrm");
      beepIf(80, 80, 5, true);
      return;
    }
  }
  ckColonOn = !ckColonOn;
  updateDisplay();
}

void updateCountdown() {
  if (!isRunning) return;
  unsigned long now = millis();
  if (now - previousMillis < 1000UL) return;
  previousMillis += 1000UL;
  if (timeTracker > 0) timeTracker--;
  if (timeTracker == 0) {
    isRunning = false;
    saveActive(false);
    MFS.write("END ");
    beepIf(200, 100, 5, true);
  } else {
    updateDisplay();
  }
}

void updateStopwatch() {
  if (!isRunning) return;
  unsigned long now = millis();
  if (now - previousMillis >= 1000UL) {
    previousMillis += 1000UL;
    timeTracker++;
    updateDisplay();
  }
}

void updateInterval() {
  if (!isRunning) return;
  unsigned long now = millis();
  if (now - previousMillis < 1000UL) return;
  previousMillis += 1000UL;
  if (timeTracker > 0) timeTracker--;
  if (timeTracker == 0) {
    intIsWork = !intIsWork;
    timeTracker = intIsWork ? WORK_TIME : REST_TIME;
    showOverlay(intIsWork ? "WORK" : "rESt", 600);
    beepIf(intIsWork ? 10 : 25, 80, intIsWork ? 2 : 1);
  } else {
    updateDisplay();
  }
}

void reactionTick() {
  if (rxPhase == 1 && millis() - rxPhaseStart >= rxGoDelay) {
    rxPhase = 2;
    rxPhaseStart = millis();
    MFS.write("GO  ");
    beepIf(20);
  }
}

void simonBeep(byte btn) {
  beepIf(12, 80, btn);
}

unsigned int simonStepMs() {
  return siFast ? SI_FAST_MS : SI_NORMAL_MS;
}

void simonNewSequence() {
  for (byte i = 0; i < SI_MAX_LEN; i++) siSequence[i] = (byte)random(1, 4);
}

void simonStartGame() {
  simonNewSequence();
  siLength = 1;
  siPlayIndex = 0;
  siInputIndex = 0;
  siPhase = 1;
  siBlank = false;
  siStepStart = millis();
  MFS.write(SI_LABELS[siSequence[0]]);
  simonBeep(siSequence[0]);
}

void simonStartPlayback() {
  siPlayIndex = 0;
  siInputIndex = 0;
  siPhase = 1;
  siBlank = false;
  siStepStart = millis();
  MFS.write(SI_LABELS[siSequence[0]]);
  simonBeep(siSequence[0]);
}

void simonPlaybackTick() {
  if (siPhase != 1) return;
  unsigned long now = millis();
  unsigned int stepMs = simonStepMs();
  if (!siBlank && now - siStepStart >= stepMs - 120U) {
    siBlank = true;
    MFS.write("    ");
  }
  if (now - siStepStart < stepMs) return;
  siPlayIndex++;
  if (siPlayIndex >= siLength) {
    siPhase = 2;
    siInputIndex = 0;
    MFS.write("go  ");
    return;
  }
  siBlank = false;
  siStepStart = now;
  MFS.write(SI_LABELS[siSequence[siPlayIndex]]);
  simonBeep(siSequence[siPlayIndex]);
}

void simonHandleInput(byte pressedBtn) {
  if (siPhase != 2) return;
  if (pressedBtn == siSequence[siInputIndex]) {
    simonBeep(pressedBtn);
    siInputIndex++;
    if (siInputIndex >= siLength) {
      if (siLength > siBest) siBest = siLength;
      if (siLength >= SI_MAX_LEN) {
        siPhase = 3;
        MFS.write("WIN!");
        beepIf(15, 40, 5);
      } else {
        siLength++;
        showOverlay("GooD", 650);
        simonStartPlayback();
      }
    }
  } else {
    siPhase = 4;
    MFS.write("FAIL");
    beepIf(40, 80, 3);
  }
}

void startChess() {
  chessP1 = (unsigned long)chessPresets[chessPreset].baseMin * 60UL;
  chessP2 = chessP1;
  chessActive = 1;
  chessMoves = 0;
  chessState = 1;
  chessFlaggedPlayer = 0;
  previousMillis = millis();
  saveActive(true);
  updateLEDs();
  updateDisplay();
}

void chessRestart() {
  chessState = 0;
  chessFlaggedPlayer = 0;
  chessMoves = 0;
  chessP1 = (unsigned long)chessPresets[chessPreset].baseMin * 60UL;
  chessP2 = chessP1;
  saveActive(false);
  updateLEDs();
  writeChessPreset();
}

void chessFlag(byte player) {
  chessState = 3;
  chessFlaggedPlayer = player;
  saveActive(false);
  updateLEDs();
  MFS.write(player == 1 ? "FLG1" : "FLG2");
  beepIf(200, 100, 5, true);
}

void chessHandoff(byte player) {
  if (chessState != 1 || chessActive != player) return;
  if (player == 1) {
    chessP1 += chessPresets[chessPreset].increment;
    chessActive = 2;
  } else {
    chessP2 += chessPresets[chessPreset].increment;
    chessActive = 1;
  }
  chessMoves++;
  previousMillis = millis();
  beepIf(5);
  updateLEDs();
  updateDisplay();
}

void updateChess() {
  if (currentMode != MODE_CHESS) return;
  unsigned long now = millis();
  if (chessState == 1 && now - previousMillis >= 1000UL) {
    previousMillis += 1000UL;
    if (chessActive == 1) {
      if (chessP1 > 0) chessP1--;
      if (chessP1 == 0) chessFlag(1);
    } else {
      if (chessP2 > 0) chessP2--;
      if (chessP2 == 0) chessFlag(2);
    }
    updateDisplay();
  }
}

void handleBlink() {
  unsigned long now = millis();
  if (currentMode == MODE_SIMON || currentMode == MODE_REACTION || overlayActive()) return;

  if (currentMode == MODE_CLOCK && ckSetMode && ckSetField < 2) {
    if (now - ckSetBlinkMs >= BLINK_SLOW) {
      ckSetBlinkMs = now;
      ckSetBlinkOn = !ckSetBlinkOn;
      writeClockSet();
    }
    return;
  }

  if (currentMode == MODE_CLOCK && alSetMode && alSetField < 2) {
    if (now - ckSetBlinkMs >= BLINK_SLOW) {
      ckSetBlinkMs = now;
      ckSetBlinkOn = !ckSetBlinkOn;
      writeAlarmSet();
    }
    return;
  }

  if (currentMode == MODE_CLOCK && alFiring) {
    if (now - lastBlinkMs >= BLINK_FAST) {
      lastBlinkMs = now;
      blinkOn = !blinkOn;
      MFS.write(blinkOn ? "ALrm" : "    ");
    }
    if (now - alLastBeep >= 2000UL) {
      alLastBeep = now;
      beepIf(80, 80, 5, true);
    }
    return;
  }

  bool wantBlink = false;
  unsigned long interval = BLINK_SLOW;

  if (isCountdownMode()) {
    if (!isRunning && timeTracker > 0) {
      wantBlink = true;
      interval = BLINK_SLOW;
    } else if (isRunning && timeTracker > 0 && timeTracker <= 10) {
      wantBlink = true;
      interval = BLINK_FAST;
    }
  } else if (currentMode == MODE_STOPWATCH || currentMode == MODE_INTERVAL) {
    if (!isRunning && timeTracker > 0) {
      wantBlink = true;
      interval = BLINK_SLOW;
    }
  } else if (currentMode == MODE_CHESS) {
    if (chessState == 2) {
      wantBlink = true;
      interval = BLINK_SLOW;
    } else if (chessState == 1) {
      unsigned long activeTime = chessActive == 1 ? chessP1 : chessP2;
      if (activeTime > 0 && activeTime <= 10) {
        wantBlink = true;
        interval = BLINK_FAST;
      }
    }
  }

  if (!wantBlink) {
    if (!blinkOn) {
      blinkOn = true;
      updateDisplay();
    }
    return;
  }

  if (now - lastBlinkMs >= interval) {
    lastBlinkMs = now;
    blinkOn = !blinkOn;
    chessBlinkOn = blinkOn;
    updateLEDs();
    if (blinkOn) updateDisplay();
    else MFS.write("    ");
  }
}

unsigned long reactionBest() {
  unsigned long best = 0;
  for (byte i = 0; i < rxAttemptCount; i++) {
    unsigned long v = rxAttempts[i];
    if (v > 0 && (best == 0 || v < best)) best = v;
  }
  return best;
}

unsigned long reactionAvg() {
  if (rxAttemptCount == 0) return 0;
  unsigned long sum = 0;
  for (byte i = 0; i < rxAttemptCount; i++) sum += rxAttempts[i];
  return sum / rxAttemptCount;
}

void storeReactionAttempt(unsigned long result) {
  rxAttempts[rxAttemptPos] = result;
  rxAttemptPos = (byte)((rxAttemptPos + 1) % 5);
  if (rxAttemptCount < 5) rxAttemptCount++;
}

void updateDisplay() {
  if (overlayActive()) {
    MFS.write(overlayText);
    return;
  }

  switch (currentMode) {
    case MODE_CLOCK:
      if (alFiring) MFS.write("ALrm");
      else if (ckSetMode) writeClockSet();
      else if (alSetMode) writeAlarmSet();
      else writeClockTime();
      break;
    case MODE_STOPWATCH:
      writeTime(timeTracker);
      break;
    case MODE_COUNTER:
      writeCounter();
      break;
    case MODE_REACTION:
      if (rxPhase == 0) MFS.write("PUSH");
      else if (rxPhase == 1) MFS.write("----");
      else if (rxPhase == 2) MFS.write("GO  ");
      else MFS.write((int)(rxResult > 9999UL ? 9999UL : rxResult));
      break;
    case MODE_INTERVAL:
      writeTime(timeTracker);
      break;
    case MODE_SIMON:
      if (siPhase == 0) MFS.write("SiMn");
      else if (siPhase == 1) MFS.write(SI_LABELS[siSequence[siPlayIndex]]);
      else if (siPhase == 2) MFS.write("go  ");
      else if (siPhase == 3) MFS.write("WIN!");
      else MFS.write("FAIL");
      break;
    case MODE_CHESS:
      if (chessState == 0) writeChessPreset();
      else if (chessState == 3) MFS.write(chessFlaggedPlayer == 1 ? "FLG1" : "FLG2");
      else writeTime(chessActive == 1 ? chessP1 : chessP2);
      break;
    default:
      if (isCountdownMode()) writeTime(timeTracker);
      break;
  }
}

void setRunning(bool running) {
  isRunning = running;
  saveActive(running);
  if (running) previousMillis = millis();
}

void snoozeAlarm() {
  alFiring = false;
  int totalMin = alHour * 60 + alMin + 5;
  alHour = (byte)((totalMin / 60) % 24);
  alMin = (byte)(totalMin % 60);
  eepromWriteByte(EE_ALARM_HOUR, alHour);
  eepromWriteByte(EE_ALARM_MIN, alMin);
  alLastTriggerMinute = -1;
  showOverlay("Snoz", 800);
  beepIf(8, 60, 1, true);
}

void dismissAlarm() {
  alFiring = false;
  blinkOn = true;
  beepIf(8, 50, 2, true);
  updateDisplay();
}

void handleClockButton(byte btn) {
  if (alFiring) {
    if (btn == BUTTON_1_LONG_PRESSED || btn == BUTTON_2_LONG_PRESSED || btn == BUTTON_3_LONG_PRESSED) snoozeAlarm();
    else if (btn == BUTTON_1_PRESSED || btn == BUTTON_2_PRESSED || btn == BUTTON_3_PRESSED) dismissAlarm();
    return;
  }

  if (ckSetMode) {
    if (btn == BUTTON_1_PRESSED) adjustClockSet(+1);
    else if (btn == BUTTON_1_LONG_PRESSED) adjustClockSet(+10);
    else if (btn == BUTTON_3_PRESSED) adjustClockSet(-1);
    else if (btn == BUTTON_2_PRESSED) {
      if (ckSetField < 2) {
        ckSetField++;
        ckSetBlinkOn = true;
        writeClockSet();
      } else {
        saveClockSet();
      }
    } else if (btn == BUTTON_3_LONG_PRESSED) {
      cancelClockSet();
    }
    return;
  }

  if (alSetMode) {
    if (btn == BUTTON_1_PRESSED) adjustAlarmSet(+1);
    else if (btn == BUTTON_1_LONG_PRESSED) adjustAlarmSet(+10);
    else if (btn == BUTTON_3_PRESSED) adjustAlarmSet(-1);
    else if (btn == BUTTON_2_PRESSED) {
      if (alSetField < 3) {
        alSetField++;
        ckSetBlinkOn = true;
        writeAlarmSet();
      } else {
        saveAlarmSet();
      }
    } else if (btn == BUTTON_2_LONG_PRESSED && alSetField == 2) {
      adjustAlarmSet(1);
    } else if (btn == BUTTON_3_LONG_PRESSED) {
      cancelAlarmSet();
    }
    return;
  }

  if (btn == BUTTON_1_PRESSED) nextMode();
  else if (btn == BUTTON_1_LONG_PRESSED) prevMode();
  else if (btn == BUTTON_2_PRESSED) {
    ck12hr = !ck12hr;
    eepromWriteByte(EE_CLOCK_12H, ck12hr ? 1 : 0);
    showOverlay(ck12hr ? "12H " : "24H ", 750);
    beepIf(8, 60, 1);
  } else if (btn == BUTTON_2_LONG_PRESSED) {
    brightnessLevel++;
    if (brightnessLevel > 3) brightnessLevel = 1;
    MFS.setDisplayBrightness(brightnessLevel - 1);
    eepromWriteByte(EE_BRIGHTNESS, brightnessLevel);
    char buf[5];
    sprintf(buf, "Br-%u", brightnessLevel);
    showOverlay(buf, 800);
    beepIf(8, 60, 1);
  } else if (btn == BUTTON_3_PRESSED) {
    if (ckRtcPresent) {
      readClockRtc();
      ckPrevMs = millis();
      updateDisplay();
    } else {
      startAlarmSet();
    }
  } else if (btn == BUTTON_3_LONG_PRESSED) {
    if (ckRtcPresent) startAlarmSet();
    else startClockSet();
  }
}

void handleSilentCombo() {
  static bool comboWasDown = false;
  static bool comboFired = false;
  static unsigned long comboStart = 0;
  bool down = rawPressed(BUTTON_2_PIN) && rawPressed(BUTTON_3_PIN);
  unsigned long now = millis();
  if (down && !comboWasDown) {
    comboWasDown = true;
    comboFired = false;
    comboStart = now;
  } else if (down && comboWasDown && !comboFired && now - comboStart >= 1000UL) {
    silentMode = !silentMode;
    eepromWriteByte(EE_SILENT, silentMode ? 1 : 0);
    showOverlay("SILn", 700);
    comboFired = true;
  } else if (!down) {
    if (comboWasDown && comboFired) {
      showOverlay(silentMode ? "ON  " : "OFF ", 900);
    }
    comboWasDown = false;
  }
}

void handleButton(byte btn) {
  if (btn == 0) return;

  if (currentMode == MODE_CLOCK) {
    handleClockButton(btn);
    return;
  }

  bool simonBusy = currentMode == MODE_SIMON && (siPhase == 1 || siPhase == 2);

  if (currentMode == MODE_CHESS) {
    if (chessState == 0) {
      if (btn == BUTTON_1_PRESSED) {
        chessPreset = chessPreset == 0 ? 5 : chessPreset - 1;
        eepromWriteByte(EE_CHESS_PRESET, chessPreset);
        writeChessPreset();
      } else if (btn == BUTTON_3_PRESSED) {
        chessPreset = (byte)((chessPreset + 1) % 6);
        eepromWriteByte(EE_CHESS_PRESET, chessPreset);
        writeChessPreset();
      } else if (btn == BUTTON_2_PRESSED) {
        startChess();
      } else if (btn == BUTTON_1_LONG_PRESSED) {
        prevMode();
      } else if (btn == BUTTON_3_LONG_PRESSED) {
        homeMode();
      }
      return;
    }
    if (chessState == 1) {
      if (btn == BUTTON_1_PRESSED) chessHandoff(1);
      else if (btn == BUTTON_3_PRESSED) chessHandoff(2);
      else if (btn == BUTTON_2_PRESSED) {
        chessState = 2;
        saveActive(false);
        beepIf(8, 60, 1);
      }
      return;
    }
    if (chessState == 2) {
      if (btn == BUTTON_2_PRESSED) {
        chessState = 1;
        previousMillis = millis();
        saveActive(true);
        blinkOn = true;
        updateLEDs();
        updateDisplay();
      } else if (btn == BUTTON_2_LONG_PRESSED) {
        char buf[5];
        unsigned int shown = chessMoves > 999 ? 999 : chessMoves;
        sprintf(buf, "M%03u", shown);
        showOverlay(buf, 2000);
      } else if (btn == BUTTON_3_LONG_PRESSED) {
        homeMode();
      }
      return;
    }
    if (chessState == 3) {
      if (btn == BUTTON_2_PRESSED) chessRestart();
      else if (btn == BUTTON_3_PRESSED) homeMode();
      else if (btn == BUTTON_3_LONG_PRESSED) homeMode();
      return;
    }
  }

  if (btn == BUTTON_1_PRESSED && !isRunning && !simonBusy) {
    nextMode();
    return;
  }
  if (btn == BUTTON_1_LONG_PRESSED && !isRunning && !simonBusy) {
    prevMode();
    return;
  }

  if (currentMode == MODE_SIMON && siPhase == 2) {
    if (btn == BUTTON_1_PRESSED) simonHandleInput(1);
    else if (btn == BUTTON_2_PRESSED) simonHandleInput(2);
    else if (btn == BUTTON_3_PRESSED) simonHandleInput(3);
    return;
  }

  if (btn == BUTTON_2_PRESSED) {
    if (isCountdownMode()) {
      setRunning(!isRunning);
      if (isRunning) beepIf(10);
      updateDisplay();
    } else if (currentMode == MODE_STOPWATCH) {
      setRunning(!isRunning);
      if (isRunning) beepIf(10);
      updateDisplay();
    } else if (currentMode == MODE_COUNTER) {
      counterValue++;
      if (counterValue > 9999) counterValue = 0;
      beepIf(5);
      updateDisplay();
    } else if (currentMode == MODE_REACTION) {
      if (rxPhase == 0 || rxPhase == 3) {
        rxPhase = 1;
        rxResult = 0;
        rxGoDelay = (unsigned long)random(1000, 4001);
        rxPhaseStart = millis();
        MFS.write("----");
        beepIf(5);
      } else if (rxPhase == 1) {
        rxPhase = 0;
        rxResult = 0;
        showOverlay("ERLY", 900);
        beepIf(30, 60, 3);
      } else if (rxPhase == 2) {
        rxResult = millis() - rxPhaseStart;
        rxPhase = 3;
        storeReactionAttempt(rxResult);
        beepIf(10);
        updateDisplay();
      }
    } else if (currentMode == MODE_INTERVAL) {
      setRunning(!isRunning);
      if (isRunning) {
        showOverlay(intIsWork ? "WORK" : "rESt", 500);
        beepIf(10);
      }
      updateDisplay();
    } else if (currentMode == MODE_SIMON) {
      if (siPhase == 0 || siPhase == 3 || siPhase == 4) simonStartGame();
    }
    return;
  }

  if (btn == BUTTON_2_LONG_PRESSED) {
    if (isCountdownMode()) {
      timeTracker = timerOptions[countdownIndex()];
      setRunning(true);
      blinkOn = true;
      showOverlay("rSEt", 450);
      beepIf(8, 60, 2);
    } else if (currentMode == MODE_STOPWATCH) {
      swStatView = (byte)((swStatView + 1) % 2);
      if (swLapCount == 0) {
        showOverlay("none", 900);
      } else if (swStatView == 0) {
        char buf[5];
        formatTime(buf, swBestLap);
        showOverlay("bESt", 700);
        queueOverlay(buf, 2200);
      } else {
        char buf[5];
        formatTime(buf, swLapSum / swLapCount);
        showOverlay("AVG ", 700);
        queueOverlay(buf, 2200);
      }
      beepIf(8, 80, 1);
    } else if (currentMode == MODE_COUNTER) {
      if (counterValue > 0) counterValue--;
      beepIf(8, 80, 1);
      updateDisplay();
    } else if (currentMode == MODE_REACTION) {
      rxStatView = (byte)((rxStatView + 1) % 2);
      unsigned long v = rxStatView == 0 ? reactionBest() : reactionAvg();
      if (v == 0) showOverlay("none", 900);
      else {
        char buf[5];
        sprintf(buf, "%04u", (unsigned int)(v > 9999UL ? 9999UL : v));
        showOverlay(rxStatView == 0 ? "BEST" : "AVG ", 700);
        queueOverlay(buf, 2200);
      }
      beepIf(8, 80, 1);
    } else if (currentMode == MODE_INTERVAL) {
      intIsWork = !intIsWork;
      timeTracker = intIsWork ? WORK_TIME : REST_TIME;
      previousMillis = millis();
      showOverlay(intIsWork ? "WORK" : "rESt", 600);
      beepIf(intIsWork ? 10 : 25, 80, intIsWork ? 2 : 1);
    } else if (currentMode == MODE_SIMON) {
      if (siPhase == 0) {
        siFast = true;
        showOverlay("FAST", 900);
      } else if (siBest > 0) {
        char buf[5];
        sprintf(buf, "r-%02u", siBest);
        showOverlay(buf, 1600);
      } else {
        showOverlay("none", 900);
      }
    }
    return;
  }

  if (btn == BUTTON_3_LONG_PRESSED) {
    homeMode();
    return;
  }

  if (btn == BUTTON_3_PRESSED) {
    if (isCountdownMode()) {
      setRunning(false);
      timeTracker = timerOptions[countdownIndex()];
      blinkOn = true;
      beepIf(10, 50, 2);
      updateDisplay();
    } else if (currentMode == MODE_STOPWATCH) {
      if (isRunning) {
        unsigned long split = timeTracker;
        if (split > swBestLap) swBestLap = split;
        swLapSum += split;
        if (swLapCount < 255) swLapCount++;
        char buf[5];
        formatTime(buf, split);
        showOverlay("LAP ", 650);
        queueOverlay(buf, 1800);
        beepIf(8, 60, 2);
      } else {
        timeTracker = 0;
        swBestLap = 0;
        swLapSum = 0;
        swLapCount = 0;
        beepIf(10, 50, 2);
        updateDisplay();
      }
    } else if (currentMode == MODE_COUNTER) {
      counterValue = 0;
      beepIf(10, 50, 2);
      updateDisplay();
    } else if (currentMode == MODE_REACTION) {
      rxPhase = 0;
      rxResult = 0;
      beepIf(8, 50, 2);
      updateDisplay();
    } else if (currentMode == MODE_INTERVAL) {
      setRunning(false);
      intIsWork = true;
      timeTracker = WORK_TIME;
      beepIf(10, 50, 2);
      updateDisplay();
    } else if (currentMode == MODE_SIMON) {
      siPhase = 0;
      siLength = 0;
      beepIf(8, 50, 2);
      updateDisplay();
    }
  }
}

void runDiagnostic(byte btn) {
  unsigned long now = millis();
  if (btn == BUTTON_3_PRESSED || btn == BUTTON_3_LONG_PRESSED) {
    diagMode = false;
    enterMode(currentMode, false);
    return;
  }
  if (now - diagLast >= 700UL) {
    diagLast = now;
    diagStep = (byte)((diagStep + 1) % 6);
    allLEDsOff();
    if (diagStep == 0) MFS.write("tESt");
    else if (diagStep == 1) {
      MFS.write("bttn");
      if (rawPressed(BUTTON_1_PIN)) digitalWrite(LED1_PIN, LOW);
      if (rawPressed(BUTTON_2_PIN)) digitalWrite(LED2_PIN, LOW);
      if (rawPressed(BUTTON_3_PIN)) digitalWrite(LED3_PIN, LOW);
    } else if (diagStep == 2) {
      MFS.write("LED1");
      digitalWrite(LED1_PIN, LOW);
    } else if (diagStep == 3) {
      MFS.write("LED2");
      digitalWrite(LED2_PIN, LOW);
    } else if (diagStep == 4) {
      MFS.write("LED3");
      digitalWrite(LED3_PIN, LOW);
    } else {
      MFS.write("8888");
      digitalWrite(LED4_PIN, LOW);
      MFS.beep(5);
    }
  }
}

void readSettings() {
  if (EEPROM.read(EE_MAGIC) != EEPROM_MAGIC) {
    eepromWriteByte(EE_MAGIC, EEPROM_MAGIC);
    eepromWriteByte(EE_LAST_MODE, MODE_CLOCK);
    eepromWriteByte(EE_BRIGHTNESS, 1);
    eepromWriteByte(EE_CLOCK_12H, 0);
    eepromWriteByte(EE_SILENT, 0);
    eepromWriteByte(EE_CHESS_PRESET, 0);
    eepromWriteByte(EE_WAS_ACTIVE, 0);
    eepromWriteByte(EE_ALARM_HOUR, 7);
    eepromWriteByte(EE_ALARM_MIN, 0);
    eepromWriteByte(EE_ALARM_ON, 0);
  }
  byte savedMode = EEPROM.read(EE_LAST_MODE);
  if (savedMode >= TOTAL_MODES) savedMode = MODE_CLOCK;
  brightnessLevel = EEPROM.read(EE_BRIGHTNESS);
  if (brightnessLevel < 1 || brightnessLevel > 3) brightnessLevel = 1;
  ck12hr = EEPROM.read(EE_CLOCK_12H) != 0;
  silentMode = EEPROM.read(EE_SILENT) != 0;
  chessPreset = EEPROM.read(EE_CHESS_PRESET);
  if (chessPreset >= 6) chessPreset = 0;
  alHour = EEPROM.read(EE_ALARM_HOUR);
  if (alHour >= 24) alHour = 7;
  alMin = EEPROM.read(EE_ALARM_MIN);
  if (alMin >= 60) alMin = 0;
  alOn = EEPROM.read(EE_ALARM_ON) != 0;
  lastActiveSaved = EEPROM.read(EE_WAS_ACTIVE) != 0;
  currentMode = lastActiveSaved ? MODE_CLOCK : savedMode;
}

void setup() {
  Timer1.initialize();
  MFS.initialize();
  Wire.begin();
  randomSeed(analogRead(A0));

  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  pinMode(LED3_PIN, OUTPUT);
  pinMode(LED4_PIN, OUTPUT);
  allLEDsOff();

  readSettings();
  MFS.setDisplayBrightness(brightnessLevel - 1);

  diagMode = rawPressed(BUTTON_1_PIN) && rawPressed(BUTTON_2_PIN) && rawPressed(BUTTON_3_PIN);
  readClockRtc();
  ckPrevMs = millis();

  setupModeValue();
  updateLEDs();
  saveActive(false);
  if (diagMode) MFS.write("tESt");
  else showModeIntro();
}

void loop() {
  byte btn = MFS.getButton();
  if (diagMode) {
    runDiagnostic(btn);
    return;
  }

  handleSilentCombo();
  handleButton(btn);

  if (currentMode == MODE_CLOCK) updateClock();
  else if (isCountdownMode()) updateCountdown();
  else if (currentMode == MODE_STOPWATCH) updateStopwatch();
  else if (currentMode == MODE_REACTION) reactionTick();
  else if (currentMode == MODE_INTERVAL) updateInterval();
  else if (currentMode == MODE_SIMON) simonPlaybackTick();
  else if (currentMode == MODE_CHESS) updateChess();

  handleBlink();
  if (!overlayActive()) updateDisplay();
}

// -- END OF FILE ----------------------------------------------

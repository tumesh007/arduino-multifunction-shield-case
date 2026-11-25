/**
 * Shivansh Timer v9.0 — Arduino Multi-Function Shield (HW-262) Web Simulator
 * 100% Faithful Educational Simulation of the 24 Operating Modes & Hardware
 */

class WebAudioSound {
  constructor() {
    this.ctx = null;
    this.silent = false;
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (AudioCtx) {
        this.ctx = new AudioCtx();
      }
    }
    if (this.ctx && this.ctx.state === "suspended") {
      this.ctx.resume();
    }
  }

  playTone(freq, durationMs, type = "square", volume = 0.15) {
    if (this.silent) return;
    this.init();
    if (!this.ctx) return;

    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.type = type;
      osc.frequency.setValueAtTime(freq, this.ctx.currentTime);

      gain.gain.setValueAtTime(volume, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + durationMs / 1000);

      osc.connect(gain);
      gain.connect(this.ctx.destination);

      osc.start();
      osc.stop(this.ctx.currentTime + durationMs / 1000);
    } catch (e) {
      console.warn("Audio error", e);
    }
  }

  buttonClick() {
    this.playTone(1800, 35, "square", 0.08);
  }

  longPressBeep() {
    this.playTone(2400, 80, "square", 0.12);
  }

  alarmBuzzer() {
    this.playTone(2200, 150, "square", 0.25);
    setTimeout(() => this.playTone(1700, 150, "square", 0.25), 160);
  }

  simonTone(btn) {
    const freqs = [440, 554.37, 659.25]; // A4, C#5, E5
    this.playTone(freqs[btn - 1] || 440, 250, "triangle", 0.2);
  }

  failBuzz() {
    this.playTone(140, 450, "sawtooth", 0.25);
  }

  successChime() {
    const notes = [440, 554.37, 659.25, 880];
    notes.forEach((f, idx) => {
      setTimeout(() => this.playTone(f, 120, "triangle", 0.15), idx * 100);
    });
  }

  reactionGo() {
    this.playTone(1200, 200, "square", 0.2);
  }
}

// 7-Segment Font Table (a, b, c, d, e, f, g)
const SEGMENT_MAP = {
  "0": [1, 1, 1, 1, 1, 1, 0],
  "1": [0, 1, 1, 0, 0, 0, 0],
  "2": [1, 1, 0, 1, 1, 0, 1],
  "3": [1, 1, 1, 1, 0, 0, 1],
  "4": [0, 1, 1, 0, 0, 1, 1],
  "5": [1, 0, 1, 1, 0, 1, 1],
  "6": [1, 0, 1, 1, 1, 1, 1],
  "7": [1, 1, 1, 0, 0, 0, 0],
  "8": [1, 1, 1, 1, 1, 1, 1],
  "9": [1, 1, 1, 1, 0, 1, 1],
  "-": [0, 0, 0, 0, 0, 0, 1],
  "_": [0, 0, 0, 1, 0, 0, 0],
  " ": [0, 0, 0, 0, 0, 0, 0],
  "A": [1, 1, 1, 0, 1, 1, 1],
  "b": [0, 0, 1, 1, 1, 1, 1],
  "C": [1, 0, 0, 1, 1, 1, 0],
  "c": [0, 0, 0, 1, 1, 0, 1],
  "d": [0, 1, 1, 1, 1, 0, 1],
  "E": [1, 0, 0, 1, 1, 1, 1],
  "F": [1, 0, 0, 0, 1, 1, 1],
  "G": [1, 0, 1, 1, 1, 1, 0],
  "H": [0, 1, 1, 0, 1, 1, 1],
  "h": [0, 0, 1, 0, 1, 1, 1],
  "I": [0, 1, 1, 0, 0, 0, 0],
  "i": [0, 0, 1, 0, 0, 0, 0],
  "L": [0, 0, 0, 1, 1, 1, 0],
  "n": [0, 0, 1, 0, 1, 0, 1],
  "o": [0, 0, 1, 1, 1, 0, 1],
  "O": [1, 1, 1, 1, 1, 1, 0],
  "P": [1, 1, 0, 0, 1, 1, 1],
  "r": [0, 0, 0, 0, 1, 0, 1],
  "S": [1, 0, 1, 1, 0, 1, 1],
  "t": [0, 0, 0, 1, 1, 1, 1],
  "U": [0, 1, 1, 1, 1, 1, 0],
  "u": [0, 0, 1, 1, 1, 0, 0],
  "y": [0, 1, 1, 1, 0, 1, 1],
  "!": [0, 1, 0, 0, 0, 0, 0],
};

const MODE_DEFINITIONS = [
  { id: 1, name: "Clock", desc: "Digital Clock & Alarm (12H / 24H)" },
  { id: 2, name: "Countdown 1m", duration: 60, desc: "1 Minute Timer" },
  { id: 3, name: "Countdown 2m", duration: 120, desc: "2 Minutes Timer" },
  { id: 4, name: "Countdown 3m", duration: 180, desc: "3 Minutes Timer" },
  { id: 5, name: "Countdown 4m", duration: 240, desc: "4 Minutes Timer" },
  { id: 6, name: "Countdown 5m", duration: 300, desc: "5 Minutes Timer" },
  { id: 7, name: "Countdown 10m", duration: 600, desc: "10 Minutes Timer" },
  { id: 8, name: "Countdown 15m", duration: 900, desc: "15 Minutes Timer" },
  { id: 9, name: "Countdown 20m", duration: 1200, desc: "20 Minutes Timer" },
  { id: 10, name: "Countdown 25m", duration: 1500, desc: "25 Minutes Timer" },
  { id: 11, name: "Countdown 30m", duration: 1800, desc: "30 Minutes Timer" },
  { id: 12, name: "Countdown 40m", duration: 2400, desc: "40 Minutes Timer" },
  { id: 13, name: "Countdown 50m", duration: 3000, desc: "50 Minutes Timer" },
  { id: 14, name: "Countdown 60m", duration: 3600, desc: "1 Hour Timer" },
  { id: 15, name: "Countdown 90m", duration: 5400, desc: "1.5 Hours Timer" },
  { id: 16, name: "Countdown 2h", duration: 7200, desc: "2 Hours Timer" },
  { id: 17, name: "Countdown 2.5h", duration: 9000, desc: "2.5 Hours Timer" },
  { id: 18, name: "Countdown 3h", duration: 10800, desc: "3 Hours Timer" },
  { id: 19, name: "Stopwatch", desc: "Stopwatch with Lap Times & Averaging" },
  { id: 20, name: "Counter", desc: "Tally Counter (0000 to 9999)" },
  { id: 21, name: "Reaction Timer", desc: "Reflex Reaction Speed Game (in ms)" },
  { id: 22, name: "Interval Timer", desc: "Workout / Study Timer (45s Work / 15s Rest)" },
  { id: 23, name: "Simon Says", desc: "Musical Memory Sequence Game" },
  { id: 24, name: "Chess Clock", desc: "2-Player Configurable Chess Clock" },
];

class ShieldSimulator {
  constructor() {
    this.sound = new WebAudioSound();

    this.currentMode = 1; // 1 to 24
    this.displayText = "P-01";
    this.colonActive = false;
    this.dotsActive = [false, false, false, false];
    this.leds = [false, false, false, false]; // D1, D2, D3, D4

    // Intro screen timer
    this.isShowingIntro = true;
    this.introTimeout = null;

    // Timer / State machine variables
    this.isRunning = false;
    this.isPaused = false;
    this.timerSeconds = 0;
    this.totalDuration = 0;

    // Mode 1: Clock
    this.clock24Hour = false;
    this.clockUptime = 0;

    // Mode 19: Stopwatch
    this.stopwatchMs = 0;
    this.stopwatchLaps = [];
    this.stopwatchLapView = 0; // 0=none, 1=best, 2=avg

    // Mode 20: Counter
    this.counterVal = 0;

    // Mode 21: Reaction Timer
    this.reactionState = "PUSH"; // PUSH, WAIT, GO, RESULT, ERLY
    this.reactionStartTime = 0;
    this.reactionDelayTimeout = null;
    this.reactionHistory = [];
    this.reactionStatView = 0; // 0=none, 1=best, 2=avg

    // Mode 22: Interval Timer
    this.intervalPhase = "WORK"; // WORK (45s), REST (15s)
    this.intervalSeconds = 45;

    // Mode 23: Simon Says
    this.simonState = "IDLE"; // IDLE, SHOWING, WAITING_INPUT, GOOD, FAIL, WIN
    this.simonSequence = [];
    this.simonPlayerStep = 0;
    this.simonRound = 1;
    this.simonFastMode = false;
    this.simonBestRound = 0;

    // Mode 24: Chess Clock
    this.chessPresets = [
      { name: "5+0", time: 300, inc: 0, code: "C050" },
      { name: "5+3", time: 300, inc: 3, code: "C053" },
      { name: "10+0", time: 600, inc: 0, code: "C100" },
      { name: "10+5", time: 600, inc: 5, code: "C105" },
      { name: "15+10", time: 900, inc: 10, code: "C151" },
      { name: "30+0", time: 1800, inc: 0, code: "C300" },
    ];
    this.chessPresetIndex = 0;
    this.chessState = "PRESET"; // PRESET, RUNNING, PAUSED, END
    this.chessPlayer1Time = 300;
    this.chessPlayer2Time = 300;
    this.chessActivePlayer = 1; // 1 or 2

    // Main 100ms clock loop
    this.mainInterval = null;
    this.blinkState = false;

    // Button hold tracker
    this.btnHoldTimers = {};
    this.btnHoldTriggered = {};

    this.initDOM();
    this.bindEvents();
    this.startMainLoop();
    this.setMode(1);
  }

  initDOM() {
    this.digitElements = [
      document.getElementById("digit-0"),
      document.getElementById("digit-1"),
      document.getElementById("digit-2"),
      document.getElementById("digit-3"),
    ];
    this.colonElement = document.getElementById("colon-dots");
    this.ledElements = [
      document.getElementById("led-d1"),
      document.getElementById("led-d2"),
      document.getElementById("led-d3"),
      document.getElementById("led-d4"),
    ];

    this.btnB1 = document.getElementById("btn-b1");
    this.btnB2 = document.getElementById("btn-b2");
    this.btnB3 = document.getElementById("btn-b3");
    this.btnRst = document.getElementById("btn-rst");
    this.btnMute = document.getElementById("btn-mute-toggle");

    this.modeTitle = document.getElementById("current-mode-title");
    this.modeDesc = document.getElementById("current-mode-desc");
    this.b1Action = document.getElementById("hint-b1");
    this.b2Action = document.getElementById("hint-b2");
    this.b3Action = document.getElementById("hint-b3");

    this.modeSelector = document.getElementById("mode-selector");
  }

  bindEvents() {
    this.setupButton(this.btnB1, "B1", () => this.handleB1Short(), () => this.handleB1Long());
    this.setupButton(this.btnB2, "B2", () => this.handleB2Short(), () => this.handleB2Long());
    this.setupButton(this.btnB3, "B3", () => this.handleB3Short(), () => this.handleB3Long());

    if (this.btnRst) {
      this.btnRst.addEventListener("click", () => this.resetShield());
    }

    if (this.btnMute) {
      this.btnMute.addEventListener("click", () => this.toggleMute());
    }

    // Keyboard Shortcuts
    window.addEventListener("keydown", (e) => {
      if (e.repeat) return;
      if (e.key === "1" || e.key === "ArrowLeft") this.handleB1Short();
      else if (e.key === "2" || e.key === " " || e.key === "ArrowDown") this.handleB2Short();
      else if (e.key === "3" || e.key === "ArrowRight") this.handleB3Short();
      else if (e.key === "r" || e.key === "R") this.resetShield();
      else if (e.key === "m" || e.key === "M") this.toggleMute();
    });

    // Populate mode selector pills
    if (this.modeSelector) {
      this.modeSelector.innerHTML = "";
      MODE_DEFINITIONS.forEach((m) => {
        const pill = document.createElement("button");
        pill.className = `mode-card text-left px-3 py-2 rounded-lg border border-slate-200 text-xs transition-all hover:border-blue-400 hover:bg-slate-50 flex items-center justify-between ${
          m.id === this.currentMode ? "active-mode font-bold" : "text-slate-700 font-medium"
        }`;
        pill.innerHTML = `
          <span>${String(m.id).padStart(2, "0")}. ${m.name}</span>
          <span class="text-[10px] text-slate-400">${m.id <= 18 && m.id > 1 ? "Timer" : m.id >= 21 ? "Game" : "Tool"}</span>
        `;
        pill.addEventListener("click", () => this.setMode(m.id));
        this.modeSelector.appendChild(pill);
      });
    }
  }

  setupButton(el, name, onShort, onLong) {
    if (!el) return;

    const startHold = (e) => {
      e.preventDefault();
      this.sound.init();
      el.classList.add("pressed", "holding");
      this.btnHoldTriggered[name] = false;

      this.btnHoldTimers[name] = setTimeout(() => {
        this.btnHoldTriggered[name] = true;
        this.sound.longPressBeep();
        if (onLong) onLong();
      }, 750);
    };

    const endHold = (e) => {
      el.classList.remove("pressed", "holding");
      clearTimeout(this.btnHoldTimers[name]);

      if (!this.btnHoldTriggered[name]) {
        this.sound.buttonClick();
        if (onShort) onShort();
      }
    };

    el.addEventListener("mousedown", startHold);
    el.addEventListener("mouseup", endHold);
    el.addEventListener("mouseleave", () => {
      el.classList.remove("pressed", "holding");
      clearTimeout(this.btnHoldTimers[name]);
    });

    el.addEventListener("touchstart", startHold, { passive: false });
    el.addEventListener("touchend", endHold);
  }

  toggleMute() {
    this.sound.silent = !this.sound.silent;
    if (this.btnMute) {
      this.btnMute.textContent = this.sound.silent ? "🔇 Unmute Audio" : "🔊 Sound ON";
      this.btnMute.classList.toggle("bg-red-50", this.sound.silent);
      this.btnMute.classList.toggle("text-red-600", this.sound.silent);
    }
  }

  setMode(modeId) {
    if (modeId < 1 || modeId > 24) return;
    this.currentMode = modeId;

    // Reset runtime states
    this.isRunning = false;
    this.isPaused = false;
    clearTimeout(this.reactionDelayTimeout);

    // Intro Screen (P-01 to P-24)
    this.displayText = `P-${String(modeId).padStart(2, "0")}`;
    this.colonActive = false;
    this.isShowingIntro = true;
    clearTimeout(this.introTimeout);

    // Update hardware LEDs matching mode definition
    this.updateLeds();

    // Mode-specific initialization
    if (modeId >= 2 && modeId <= 18) {
      this.totalDuration = MODE_DEFINITIONS[modeId - 1].duration;
      this.timerSeconds = this.totalDuration;
    } else if (modeId === 19) {
      this.stopwatchMs = 0;
      this.stopwatchLaps = [];
    } else if (modeId === 20) {
      this.counterVal = 0;
    } else if (modeId === 21) {
      this.reactionState = "PUSH";
    } else if (modeId === 22) {
      this.intervalPhase = "WORK";
      this.intervalSeconds = 45;
    } else if (modeId === 23) {
      this.simonState = "IDLE";
      this.simonRound = 1;
    } else if (modeId === 24) {
      this.chessState = "PRESET";
      this.chessPresetIndex = 0;
      this.chessPlayer1Time = this.chessPresets[0].time;
      this.chessPlayer2Time = this.chessPresets[0].time;
      this.chessActivePlayer = 1;
    }

    // Dismiss intro screen after 800ms
    this.introTimeout = setTimeout(() => {
      this.isShowingIntro = false;
      this.updateDisplayFromCurrentState();
    }, 800);

    this.updateHints();
    this.renderDisplay();
  }

  updateLeds() {
    this.leds = [false, false, false, false];
    if (this.currentMode >= 2 && this.currentMode <= 6) {
      this.leds[0] = true; // D1
    } else if (this.currentMode >= 7 && this.currentMode <= 10) {
      this.leds[1] = true; // D2
    } else if (this.currentMode >= 11 && this.currentMode <= 14) {
      this.leds[2] = true; // D3
    } else if (this.currentMode >= 15 && this.currentMode <= 18) {
      this.leds[3] = true; // D4
    } else if (this.currentMode === 24 && this.chessState === "RUNNING") {
      this.leds[0] = this.chessActivePlayer === 1;
      this.leds[1] = this.chessActivePlayer === 2;
    }
  }

  updateDisplayFromCurrentState() {
    if (this.isShowingIntro) return;

    if (this.currentMode === 1) {
      // Clock
      const now = new Date();
      let h = now.getHours();
      const m = now.getMinutes();
      if (!this.clock24Hour) {
        h = h % 12 || 12;
      }
      this.displayText = `${String(h).padStart(2, " ")}${String(m).padStart(2, "0")}`;
      this.colonActive = now.getSeconds() % 2 === 0;
    } else if (this.currentMode >= 2 && this.currentMode <= 18) {
      // Countdowns
      if (this.timerSeconds === 0) {
        this.displayText = "END";
      } else if (this.timerSeconds >= 3600) {
        const h = Math.floor(this.timerSeconds / 3600);
        const m = Math.floor((this.timerSeconds % 3600) / 60);
        this.displayText = `${h}H${String(m).padStart(2, "0")}`;
      } else {
        const m = Math.floor(this.timerSeconds / 60);
        const s = this.timerSeconds % 60;
        this.displayText = `${String(m).padStart(2, "0")}${String(s).padStart(2, "0")}`;
        this.colonActive = true;
      }
    } else if (this.currentMode === 19) {
      // Stopwatch
      const totalSec = Math.floor(this.stopwatchMs / 1000);
      const tenths = Math.floor((this.stopwatchMs % 1000) / 100);
      if (totalSec < 60) {
        this.displayText = `${String(totalSec).padStart(2, "0")}.${tenths}s`;
      } else {
        const m = Math.floor(totalSec / 60);
        const s = totalSec % 60;
        this.displayText = `${String(m).padStart(2, "0")}${String(s).padStart(2, "0")}`;
        this.colonActive = true;
      }
    } else if (this.currentMode === 20) {
      // Counter
      this.displayText = String(this.counterVal).padStart(4, "0");
      this.colonActive = false;
    } else if (this.currentMode === 21) {
      // Reaction Timer
      this.displayText = this.reactionState;
      this.colonActive = false;
    } else if (this.currentMode === 22) {
      // Interval Timer
      this.displayText = `${this.intervalPhase === "WORK" ? "45" : "15"}`;
      this.colonActive = false;
    } else if (this.currentMode === 23) {
      // Simon Says
      if (this.simonState === "IDLE") this.displayText = "SiMn";
    } else if (this.currentMode === 24) {
      // Chess Clock
      if (this.chessState === "PRESET") {
        this.displayText = this.chessPresets[this.chessPresetIndex].code;
      } else {
        const activeTime = this.chessActivePlayer === 1 ? this.chessPlayer1Time : this.chessPlayer2Time;
        const m = Math.floor(activeTime / 60);
        const s = activeTime % 60;
        this.displayText = `${String(m).padStart(2, "0")}${String(s).padStart(2, "0")}`;
        this.colonActive = true;
      }
    }
  }

  startMainLoop() {
    this.mainInterval = setInterval(() => {
      this.blinkState = !this.blinkState;

      // 1. Clock mode auto update
      if (this.currentMode === 1 && !this.isShowingIntro) {
        this.updateDisplayFromCurrentState();
      }

      // 2. Countdown timers running
      if (this.currentMode >= 2 && this.currentMode <= 18 && this.isRunning && !this.isPaused) {
        if (this.timerSeconds > 0) {
          this.timerSeconds--;
          if (this.timerSeconds === 0) {
            this.isRunning = false;
            this.sound.alarmBuzzer();
          }
        }
        this.updateDisplayFromCurrentState();
      }

      // 3. Stopwatch running
      if (this.currentMode === 19 && this.isRunning && !this.isPaused) {
        this.stopwatchMs += 100;
        this.updateDisplayFromCurrentState();
      }

      // 4. Interval Timer
      if (this.currentMode === 22 && this.isRunning && !this.isPaused) {
        this.intervalSeconds--;
        if (this.intervalSeconds <= 0) {
          if (this.intervalPhase === "WORK") {
            this.intervalPhase = "REST";
            this.intervalSeconds = 15;
            this.sound.playTone(800, 250);
          } else {
            this.intervalPhase = "WORK";
            this.intervalSeconds = 45;
            this.sound.playTone(1400, 250);
          }
        }
        const m = Math.floor(this.intervalSeconds / 60);
        const s = this.intervalSeconds % 60;
        this.displayText = `${this.intervalPhase === "WORK" ? "W" : "r"}${String(s).padStart(2, "0")}`;
      }

      // 5. Chess Clock
      if (this.currentMode === 24 && this.chessState === "RUNNING") {
        if (this.chessActivePlayer === 1) {
          if (this.chessPlayer1Time > 0) this.chessPlayer1Time--;
          else { this.chessState = "END"; this.sound.alarmBuzzer(); }
        } else {
          if (this.chessPlayer2Time > 0) this.chessPlayer2Time--;
          else { this.chessState = "END"; this.sound.alarmBuzzer(); }
        }
        this.updateDisplayFromCurrentState();
      }

      this.renderDisplay();
    }, 100);
  }

  resetShield() {
    this.sound.buttonClick();
    this.setMode(1);
  }

  // Button Action Handlers
  handleB1Short() {
    if (this.currentMode === 23 && this.simonState === "WAITING_INPUT") {
      this.handleSimonInput(1);
      return;
    }
    if (this.currentMode === 24 && this.chessState === "RUNNING") {
      // Player 1 finishes move, handoff to Player 2
      if (this.chessActivePlayer === 1) {
        this.chessPlayer1Time += this.chessPresets[this.chessPresetIndex].inc;
        this.chessActivePlayer = 2;
        this.updateLeds();
        this.sound.buttonClick();
      }
      return;
    }
    if (this.currentMode === 24 && this.chessState === "PRESET") {
      this.chessPresetIndex = (this.chessPresetIndex - 1 + this.chessPresets.length) % this.chessPresets.length;
      this.displayText = this.chessPresets[this.chessPresetIndex].code;
      this.renderDisplay();
      return;
    }

    // Default global action: Next mode
    if (!this.isRunning) {
      this.setMode(this.currentMode >= 24 ? 1 : this.currentMode + 1);
    }
  }

  handleB1Long() {
    // Default global action: Previous mode
    if (!this.isRunning) {
      this.setMode(this.currentMode <= 1 ? 24 : this.currentMode - 1);
    }
  }

  handleB2Short() {
    if (this.currentMode === 1) {
      // Toggle 12/24H
      this.clock24Hour = !this.clock24Hour;
      this.updateDisplayFromCurrentState();
      return;
    }

    if (this.currentMode >= 2 && this.currentMode <= 18) {
      // Start / Pause countdown
      if (!this.isRunning) {
        this.isRunning = true;
        this.isPaused = false;
      } else {
        this.isPaused = !this.isPaused;
      }
      return;
    }

    if (this.currentMode === 19) {
      // Stopwatch start / pause
      if (!this.isRunning) {
        this.isRunning = true;
        this.isPaused = false;
      } else {
        this.isPaused = !this.isPaused;
      }
      return;
    }

    if (this.currentMode === 20) {
      // Counter +1
      this.counterVal = (this.counterVal + 1) % 10000;
      this.updateDisplayFromCurrentState();
      return;
    }

    if (this.currentMode === 21) {
      // Reaction Timer
      if (this.reactionState === "PUSH" || this.reactionState === "ERLY" || !isNaN(Number(this.reactionState))) {
        this.reactionState = "----";
        this.renderDisplay();
        const delay = 1500 + Math.random() * 3000;
        this.reactionDelayTimeout = setTimeout(() => {
          if (this.reactionState === "----") {
            this.reactionState = "GO";
            this.reactionStartTime = performance.now();
            this.sound.reactionGo();
            this.renderDisplay();
          }
        }, delay);
      } else if (this.reactionState === "----") {
        // Pressed too early!
        clearTimeout(this.reactionDelayTimeout);
        this.reactionState = "ERLY";
        this.sound.failBuzz();
        this.renderDisplay();
      } else if (this.reactionState === "GO") {
        // Hit!
        const elapsed = Math.round(performance.now() - this.reactionStartTime);
        this.reactionHistory.push(elapsed);
        this.reactionState = String(elapsed).padStart(4, " ");
        this.sound.successChime();
        this.renderDisplay();
      }
      return;
    }

    if (this.currentMode === 22) {
      // Interval timer start/pause
      this.isRunning = !this.isRunning;
      return;
    }

    if (this.currentMode === 23) {
      // Simon says
      if (this.simonState === "WAITING_INPUT") {
        this.handleSimonInput(2);
      } else if (this.simonState === "IDLE" || this.simonState === "FAIL" || this.simonState === "WIN") {
        this.startSimonGame();
      }
      return;
    }

    if (this.currentMode === 24) {
      // Chess clock
      if (this.chessState === "PRESET") {
        const preset = this.chessPresets[this.chessPresetIndex];
        this.chessPlayer1Time = preset.time;
        this.chessPlayer2Time = preset.time;
        this.chessState = "RUNNING";
        this.chessActivePlayer = 1;
        this.updateLeds();
      } else if (this.chessState === "RUNNING") {
        this.chessState = "PAUSED";
      } else if (this.chessState === "PAUSED") {
        this.chessState = "RUNNING";
      }
      return;
    }
  }

  handleB2Long() {
    if (this.currentMode === 20) {
      // Counter -1
      if (this.counterVal > 0) this.counterVal--;
      this.updateDisplayFromCurrentState();
      return;
    }
    if (this.currentMode === 21) {
      // Reaction stats (best / avg)
      if (this.reactionHistory.length > 0) {
        const best = Math.min(...this.reactionHistory);
        this.displayText = `b${String(best).padStart(3, " ")}`;
        this.renderDisplay();
      } else {
        this.displayText = "none";
        this.renderDisplay();
      }
      return;
    }
    if (this.currentMode === 23 && this.simonState === "IDLE") {
      this.simonFastMode = !this.simonFastMode;
      this.displayText = this.simonFastMode ? "FAST" : "SiMn";
      this.renderDisplay();
      return;
    }
  }

  handleB3Short() {
    if (this.currentMode === 23 && this.simonState === "WAITING_INPUT") {
      this.handleSimonInput(3);
      return;
    }

    if (this.currentMode === 24 && this.chessState === "RUNNING") {
      // Player 2 finishes move, handoff to Player 1
      if (this.chessActivePlayer === 2) {
        this.chessPlayer2Time += this.chessPresets[this.chessPresetIndex].inc;
        this.chessActivePlayer = 1;
        this.updateLeds();
        this.sound.buttonClick();
      }
      return;
    }
    if (this.currentMode === 24 && this.chessState === "PRESET") {
      this.chessPresetIndex = (this.chessPresetIndex + 1) % this.chessPresets.length;
      this.displayText = this.chessPresets[this.chessPresetIndex].code;
      this.renderDisplay();
      return;
    }

    if (this.currentMode >= 2 && this.currentMode <= 18) {
      // Stop & reset countdown
      this.isRunning = false;
      this.isPaused = false;
      this.timerSeconds = this.totalDuration;
      this.updateDisplayFromCurrentState();
      return;
    }

    if (this.currentMode === 19) {
      // Stopwatch lap or reset
      if (this.isRunning) {
        this.stopwatchLaps.push(this.stopwatchMs);
      } else {
        this.stopwatchMs = 0;
        this.stopwatchLaps = [];
        this.updateDisplayFromCurrentState();
      }
      return;
    }

    if (this.currentMode === 20) {
      this.counterVal = 0;
      this.updateDisplayFromCurrentState();
      return;
    }

    if (this.currentMode === 21) {
      clearTimeout(this.reactionDelayTimeout);
      this.reactionState = "PUSH";
      this.updateDisplayFromCurrentState();
      return;
    }
  }

  handleB3Long() {
    // Global Home: Returns to Clock mode
    this.setMode(1);
  }

  // Simon Says Engine
  startSimonGame() {
    this.simonRound = 1;
    this.simonSequence = [Math.floor(Math.random() * 3) + 1];
    this.playSimonSequence();
  }

  playSimonSequence() {
    this.simonState = "SHOWING";
    const speed = this.simonFastMode ? 350 : 650;
    let idx = 0;

    const playNext = () => {
      if (idx < this.simonSequence.length) {
        const btn = this.simonSequence[idx];
        this.displayText = `bt${btn}`;
        this.sound.simonTone(btn);
        this.leds = [btn === 1, btn === 2, btn === 3, false];
        this.renderDisplay();

        setTimeout(() => {
          this.displayText = "    ";
          this.leds = [false, false, false, false];
          this.renderDisplay();
          idx++;
          setTimeout(playNext, speed * 0.4);
        }, speed * 0.6);
      } else {
        this.simonState = "WAITING_INPUT";
        this.simonPlayerStep = 0;
        this.displayText = "go  ";
        this.renderDisplay();
      }
    };

    playNext();
  }

  handleSimonInput(btn) {
    this.sound.simonTone(btn);
    this.leds = [btn === 1, btn === 2, btn === 3, false];
    this.renderDisplay();
    setTimeout(() => {
      this.leds = [false, false, false, false];
      this.renderDisplay();
    }, 150);

    if (this.simonSequence[this.simonPlayerStep] === btn) {
      this.simonPlayerStep++;
      if (this.simonPlayerStep === this.simonSequence.length) {
        // Round won!
        if (this.simonRound === 10) {
          this.simonState = "WIN";
          this.displayText = "WIN!";
          this.sound.successChime();
        } else {
          this.simonRound++;
          this.simonSequence.push(Math.floor(Math.random() * 3) + 1);
          this.simonState = "GOOD";
          this.displayText = "GooD";
          this.sound.successChime();
          setTimeout(() => this.playSimonSequence(), 1200);
        }
      }
    } else {
      // Wrong button!
      this.simonState = "FAIL";
      this.displayText = "FAIL";
      this.sound.failBuzz();
    }
  }

  // 7-Segment SVG Segment Rendering
  renderDisplay() {
    const text = String(this.displayText).padEnd(4, " ").substring(0, 4);

    for (let i = 0; i < 4; i++) {
      const char = text[i] || " ";
      const segs = SEGMENT_MAP[char] || SEGMENT_MAP[" "];
      const digitEl = this.digitElements[i];

      if (digitEl) {
        const segNames = ["a", "b", "c", "d", "e", "f", "g"];
        segNames.forEach((name, sIdx) => {
          const segEl = digitEl.querySelector(`.seg-${name}`);
          if (segEl) {
            segEl.classList.toggle("active", segs[sIdx] === 1);
          }
        });
      }
    }

    if (this.colonElement) {
      this.colonElement.classList.toggle("active", this.colonActive);
    }

    // Render LEDs
    this.ledElements.forEach((el, idx) => {
      if (el) el.classList.toggle("active", this.leds[idx]);
    });
  }

  updateHints() {
    const m = MODE_DEFINITIONS[this.currentMode - 1];
    if (this.modeTitle) this.modeTitle.textContent = `Mode ${m.id}: ${m.name}`;
    if (this.modeDesc) this.modeDesc.textContent = m.desc;

    // Highlight active card in selector
    document.querySelectorAll(".mode-card").forEach((card, idx) => {
      card.classList.toggle("active-mode", idx + 1 === this.currentMode);
      card.classList.toggle("font-bold", idx + 1 === this.currentMode);
    });

    if (this.currentMode === 1) {
      this.b1Action.textContent = "Next Mode (Hold: Prev)";
      this.b2Action.textContent = "Toggle 12/24 Hour";
      this.b3Action.textContent = "Hold: Home";
    } else if (this.currentMode >= 2 && this.currentMode <= 18) {
      this.b1Action.textContent = "Next Mode (When Stopped)";
      this.b2Action.textContent = "Start / Pause";
      this.b3Action.textContent = "Stop / Reset (Hold: Home)";
    } else if (this.currentMode === 19) {
      this.b1Action.textContent = "Next Mode";
      this.b2Action.textContent = "Start / Pause";
      this.b3Action.textContent = "Record Lap / Reset";
    } else if (this.currentMode === 20) {
      this.b1Action.textContent = "Next Mode";
      this.b2Action.textContent = "Add 1 (Hold: -1)";
      this.b3Action.textContent = "Reset to 0 (Hold: Home)";
    } else if (this.currentMode === 21) {
      this.b1Action.textContent = "Next Mode";
      this.b2Action.textContent = "Start / React / Stats";
      this.b3Action.textContent = "Cancel (Hold: Home)";
    } else if (this.currentMode === 23) {
      this.b1Action.textContent = "Simon Button 1";
      this.b2Action.textContent = "Simon Button 2 / Start";
      this.b3Action.textContent = "Simon Button 3 / Reset";
    } else if (this.currentMode === 24) {
      this.b1Action.textContent = "Player 1 Move / Prev Preset";
      this.b2Action.textContent = "Start / Pause Game";
      this.b3Action.textContent = "Player 2 Move / Next Preset";
    }
  }
}

document.addEventListener("DOMContentLoaded", () => {
  window.shieldApp = new ShieldSimulator();
});

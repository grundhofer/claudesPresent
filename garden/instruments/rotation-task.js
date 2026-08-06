// Rotation-task instrument for note 006 — "North of Your Foot"
// A top-down table with three coloured chips. The reader memorises the arrangement,
// gets rotated 180°, and chooses between two reconstructions — revealing which
// spatial frame of reference their mind defaults to.

const ROTATE_I18N = {
  en: {
    look: "Memorise this arrangement.",
    ready: "Got it",
    rotated: "You've been turned around. Make it the same.",
    pick: "Pick the arrangement that matches:",
    absoluteLabel: "same compass direction",
    relativeLabel: "same side of you",
    absoluteFeedback: "You used an absolute frame — you preserved the chips' compass directions, like a speaker of Guugu Yimithirr.",
    relativeFeedback: "You used a relative frame — you preserved the left-to-right order from where you sit, like a speaker of English.",
    reset: "Try again",
    north: "N",
    you: "you",
  },
  de: {
    look: "Präg dir die Anordnung ein.",
    ready: "Fertig",
    rotated: "Du wurdest umgedreht. Stell es wieder genauso hin.",
    pick: "Welche Anordnung passt?",
    absoluteLabel: "gleiche Himmelsrichtung",
    relativeLabel: "gleiche Seite von dir",
    absoluteFeedback: "Du hast ein absolutes Bezugssystem benutzt — die Himmelsrichtung der Chips blieb erhalten, wie bei einem Sprecher des Guugu Yimithirr.",
    relativeFeedback: "Du hast ein relatives Bezugssystem benutzt — die Links-Rechts-Reihenfolge aus deiner Sicht blieb erhalten, wie bei einem Sprecher des Englischen.",
    reset: "Nochmal",
    north: "N",
    you: "du",
  }
};

let rotateLang = "en";
function rotateT(key) { return (ROTATE_I18N[rotateLang] || ROTATE_I18N.en)[key] || key; }

function __rotateSetLang(lang) {
  rotateLang = lang;
  // repaint on next draw cycle
  const el = document.getElementById("rotateCanvas");
  if (el && el._needsRepaint) el._needsRepaint();
}

function buildRotationInstrument() {
  const canvas = document.getElementById("rotateCanvas");
  if (!canvas) throw new Error("#rotateCanvas is missing");
  const ctx = canvas.getContext("2d");

  // ---- layout constants ----
  const dpr = Math.min(devicePixelRatio || 1, 2);
  let W, H; // CSS pixels

  const CHIP_R = 16;
  const CHIP_COLORS = ["#e05555", "#5588d8", "#55a855"]; // red, blue, green
  const CHIP_POSITIONS = [ // [x, y] relative to table centre, in CSS px
    [-90, 0],
    [0, 0],
    [90, 0],
  ];

  const TABLE_W = 280, TABLE_H = 160, TABLE_R = 14;

  // ---- state ----
  let phase = "memorise"; // memorise | rotated | chose_absolute | chose_relative
  let viewerTop = false;  // true when viewer is at the top (after rotation)
  let animT = 0;          // 0 = viewer at bottom, 1 = viewer at top
  let targetAnimT = 0;

  // ---- helpers ----
  function tableCX() { return W / 2; }
  function tableCY() { return H / 2; }
  function viewerY() { return tableCY() + (TABLE_H / 2 + 44) * (animT * 2 - 1); }
  function viewerDir() { return animT > 0.5 ? -1 : 1; } // -1 = facing down, 1 = facing up

  function px(n) { return n; } // all coords in CSS px already

  // ---- drawing ----
  function drawCompass(cx, cy) {
    const r = 22;
    ctx.save();
    ctx.translate(cx, cy);
    // circle
    ctx.strokeStyle = "var(--ink-3, #8899aa)";
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.arc(0, 0, r, 0, Math.PI * 2);
    ctx.stroke();
    // N arrow (always points up = north)
    ctx.fillStyle = "var(--ink-1, #334455)";
    ctx.beginPath();
    ctx.moveTo(0, -r + 4);
    ctx.lineTo(-5, -r + 12);
    ctx.lineTo(5, -r + 12);
    ctx.closePath();
    ctx.fill();
    // S tick
    ctx.beginPath();
    ctx.moveTo(0, r - 4);
    ctx.lineTo(0, r - 10);
    ctx.stroke();
    // E, W ticks
    ctx.beginPath();
    ctx.moveTo(r - 4, 0); ctx.lineTo(r - 10, 0);
    ctx.moveTo(-r + 4, 0); ctx.lineTo(-r + 10, 0);
    ctx.stroke();
    // label
    ctx.fillStyle = "var(--ink-2, #667788)";
    ctx.font = "11px 'SF Mono', 'Fira Code', 'Cascadia Code', monospace";
    ctx.textAlign = "center";
    ctx.fillText(rotateT("north"), 0, -r - 6);
    ctx.restore();
  }

  function drawChip(x, y, colorIdx, alpha = 1.0) {
    ctx.save();
    ctx.globalAlpha = alpha;
    const col = CHIP_COLORS[colorIdx];
    // shadow
    ctx.fillStyle = "rgba(0,0,0,0.12)";
    ctx.beginPath();
    ctx.arc(x + 2, y + 2, CHIP_R, 0, Math.PI * 2);
    ctx.fill();
    // body
    const grad = ctx.createRadialGradient(x - 3, y - 4, CHIP_R * 0.1, x, y, CHIP_R);
    grad.addColorStop(0, "#ffffff88");
    grad.addColorStop(0.6, col);
    grad.addColorStop(1, "#00000033");
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.arc(x, y, CHIP_R, 0, Math.PI * 2);
    ctx.fill();
    // rim
    ctx.strokeStyle = "rgba(0,0,0,0.15)";
    ctx.lineWidth = 1;
    ctx.stroke();
    ctx.restore();
  }

  function drawViewer(x, y, dir) {
    ctx.save();
    ctx.translate(x, y);
    ctx.scale(1, dir); // flip vertically if facing down
    // head
    ctx.fillStyle = "var(--ink-1, #334455)";
    ctx.beginPath();
    ctx.arc(0, -12, 6, 0, Math.PI * 2);
    ctx.fill();
    // body
    ctx.strokeStyle = "var(--ink-1, #334455)";
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(0, -6);
    ctx.lineTo(0, 8);
    ctx.stroke();
    // arms
    ctx.beginPath();
    ctx.moveTo(-10, -2);
    ctx.lineTo(10, -2);
    ctx.stroke();
    // legs
    ctx.beginPath();
    ctx.moveTo(0, 8);
    ctx.lineTo(-8, 18);
    ctx.moveTo(0, 8);
    ctx.lineTo(8, 18);
    ctx.stroke();
    // label
    ctx.fillStyle = "var(--ink-2, #667788)";
    ctx.font = "11px 'SF Mono', 'Fira Code', 'Cascadia Code', monospace";
    ctx.textAlign = "center";
    ctx.fillText(rotateT("you"), 0, 30);
    ctx.restore();
  }

  function drawChipsOnTable(chipXs) {
    // chipXs: array of 3 x-positions (CSS px, relative to canvas) for the chips
    for (let i = 0; i < 3; i++) {
      drawChip(chipXs[i], tableCY(), i);
    }
  }

  function drawAnswerMini(x, y, chipXs, label, isSelected) {
    // small preview card showing a chip arrangement
    const mw = 120, mh = 60;
    ctx.save();
    ctx.translate(x - mw / 2, y);
    // card bg
    ctx.fillStyle = isSelected ? "var(--accent-muted, rgba(74,144,144,0.15))" : "var(--surface-2, rgba(128,140,152,0.08))";
    ctx.strokeStyle = isSelected ? "var(--accent, #4a9090)" : "var(--ink-4, #aabbcc)";
    ctx.lineWidth = isSelected ? 2 : 1;
    ctx.beginPath();
    ctx.roundRect(0, 0, mw, mh, 8);
    ctx.fill();
    ctx.stroke();
    // mini chips
    for (let i = 0; i < 3; i++) {
      ctx.fillStyle = CHIP_COLORS[i];
      ctx.beginPath();
      ctx.arc(25 + i * 35, mh / 2, 8, 0, Math.PI * 2);
      ctx.fill();
    }
    // label
    ctx.fillStyle = "var(--ink-2, #667788)";
    ctx.font = "11px -apple-system, 'Inter', sans-serif";
    ctx.textAlign = "center";
    ctx.fillText(label, mw / 2, mh - 8);
    ctx.restore();
  }

  function drawTable() {
    // table surface
    const tx = tableCX() - TABLE_W / 2, ty = tableCY() - TABLE_H / 2;
    ctx.fillStyle = "var(--surface-1, #f5f2ed)";
    ctx.strokeStyle = "var(--ink-4, #aabbcc)";
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.roundRect(tx, ty, TABLE_W, TABLE_H, TABLE_R);
    ctx.fill();
    ctx.stroke();
  }

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    const cx = tableCX(), cy = tableCY();

    drawTable();

    // chips — in "memorise" and "rotated" phases, chips stay in absolute positions
    if (phase === "memorise" || phase === "rotated") {
      for (let i = 0; i < 3; i++) {
        const [dx, dy] = CHIP_POSITIONS[i];
        drawChip(cx + dx, cy + dy, i);
      }
    } else if (phase === "chose_absolute") {
      // absolute: chips in same physical positions (same compass dirs)
      for (let i = 0; i < 3; i++) {
        const [dx, dy] = CHIP_POSITIONS[i];
        drawChip(cx + dx, cy + dy, i);
      }
    } else if (phase === "chose_relative") {
      // relative: chips reversed (same L-R order from viewer's new perspective)
      for (let i = 0; i < 3; i++) {
        const [dx, dy] = CHIP_POSITIONS[2 - i]; // reversed
        drawChip(cx + dx, cy + dy, i);
      }
    }

    // compass
    drawCompass(cx + TABLE_W / 2 + 28, cy - TABLE_H / 2 - 2);

    // viewer
    drawViewer(cx, viewerY(), viewerDir());
  }

  // ---- animation loop ----
  function tick() {
    // smooth animation toward target
    const speed = 0.08;
    if (Math.abs(animT - targetAnimT) > 0.001) {
      animT += (targetAnimT - animT) * speed;
      draw();
      requestAnimationFrame(tick);
    } else {
      if (Math.abs(animT - targetAnimT) > 0) {
        animT = targetAnimT;
      }
      draw();
    }
  }

  function startAnim() {
    if (animT !== targetAnimT) {
      requestAnimationFrame(tick);
    }
  }

  // ---- public API for repaint ----
  canvas._needsRepaint = () => { draw(); };

  // ---- resize ----
  function resize() {
    const rect = canvas.getBoundingClientRect();
    W = rect.width;
    H = Math.round(W * 0.62); // aspect ratio
    canvas.style.height = H + "px";
    canvas.width = Math.round(W * dpr);
    canvas.height = Math.round(H * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    draw();
  }

  window.addEventListener("resize", resize);

  // ---- HTML controls ----
  const readyBtn = document.getElementById("rotateReady");
  const pickRow = document.getElementById("rotatePickRow");
  const absBtn = document.getElementById("rotateAbsolute");
  const relBtn = document.getElementById("rotateRelative");
  const feedback = document.getElementById("rotateFeedback");
  const resetBtn = document.getElementById("rotateReset");
  const instructEl = document.getElementById("rotateInstruct");

  if (!readyBtn || !pickRow || !absBtn || !relBtn || !feedback || !resetBtn) {
    throw new Error("Rotation instrument controls missing");
  }

  function updateUI() {
    instructEl.textContent = phase === "memorise" ? rotateT("look") : rotateT("rotated");
    readyBtn.style.display = phase === "memorise" ? "" : "none";
    pickRow.style.display = phase === "rotated" ? "" : "none";
    feedback.style.display = (phase === "chose_absolute" || phase === "chose_relative") ? "" : "none";
    resetBtn.style.display = (phase === "chose_absolute" || phase === "chose_relative") ? "" : "none";

    if (phase === "chose_absolute") {
      feedback.innerHTML = "<strong>" + rotateT("absoluteFeedback") + "</strong>";
    } else if (phase === "chose_relative") {
      feedback.innerHTML = "<strong>" + rotateT("relativeFeedback") + "</strong>";
    }

    // update answer button labels
    absBtn.textContent = rotateT("absoluteLabel");
    relBtn.textContent = rotateT("relativeLabel");
    readyBtn.textContent = rotateT("ready");
    resetBtn.textContent = rotateT("reset");
  }

  readyBtn.addEventListener("click", () => {
    if (phase !== "memorise") return;
    phase = "rotated";
    targetAnimT = 1;
    updateUI();
    startAnim();
  });

  absBtn.addEventListener("click", () => {
    if (phase !== "rotated") return;
    phase = "chose_absolute";
    updateUI();
    draw();
  });

  relBtn.addEventListener("click", () => {
    if (phase !== "rotated") return;
    phase = "chose_relative";
    updateUI();
    draw();
  });

  resetBtn.addEventListener("click", () => {
    phase = "memorise";
    targetAnimT = 0;
    updateUI();
    startAnim();
  });

  // ---- init ----
  resize();
  updateUI();
  targetAnimT = 0;
  animT = 0;

  // register for theme repaints
  repaint.push(() => draw());

  return {
    setLang(lang) {
      rotateLang = lang;
      updateUI();
      draw();
    }
  };
}

(() => {
  const ASSET = {
    logo: "./bobba-helper-tweaker-assets/bobba-client-logo-splash.png",
    check: "./bobba-helper-tweaker-assets/checkbox.png",
    flower: "./bobba-helper-tweaker-assets/bobba-flower.png",
    discord: "./bobba-helper-tweaker-assets/bobba-discord-btn.png",
    settings: "./bobba-helper-tweaker-assets/bobba-settings-btn.png",
  };

  // Defaults match cleanswf/.../bobba/BobbaHelperView.as layout constants.
  const DEFAULTS = {
    VIEW_W: 378,
    VIEW_H: 394,
    LOGO_X: 27,
    LOGO_Y: 16,
    LOGO_SCALE: 1,
    TEXT_X: 177,
    TEXT_RIGHT_PAD: 14,
    HEADLINE_Y: 27,
    HEADLINE_SIZE: 15,
    SUBTITLE_SIZE: 12,
    VERSION_SIZE: 10,
    SUBTITLE_GAP: 3,
    VERSION_GAP: 4,
    CHECK_SCALE: 1,
    CHECK_LABEL_GAP: 4,
    COL_LEFT_X: 22,
    COL_RIGHT_X: 199,
    EXTRA_LEFT_X: 70,
    COL_WIDTH: 195,
    OPTION_SIZE: 12,
    TITLE_SIZE: 13,
    TITLE_TO_ROW: 22,
    ROW_SPACING: 24,
    SECTION1_Y: 128,
    SECTION2_Y: 203,
    EXTRA_Y: 298,
    BUTTON_Y: 352,
    DISCORD_X: 70,
    SETTINGS_X: 199,
    FLOWER_X: 15,
    FLOWER_SCALE: 1,
  };

  const GROUPS = [
    {
      id: "g-window",
      keys: [
        ["VIEW_W", 320, 700, 1],
        ["VIEW_H", 320, 700, 1],
      ],
    },
    {
      id: "g-logo",
      keys: [
        ["LOGO_X", 0, 200, 1],
        ["LOGO_Y", 0, 120, 1],
        ["LOGO_SCALE", 1, 3, 1],
      ],
    },
    {
      id: "g-copy",
      keys: [
        ["TEXT_X", 80, 320, 1],
        ["TEXT_RIGHT_PAD", 0, 40, 1],
        ["HEADLINE_Y", 0, 120, 1],
        ["HEADLINE_SIZE", 10, 24, 1],
        ["SUBTITLE_SIZE", 8, 18, 1],
        ["VERSION_SIZE", 8, 16, 1],
        ["SUBTITLE_GAP", 0, 24, 1],
        ["VERSION_GAP", 0, 40, 1],
      ],
    },
    {
      id: "g-cols",
      keys: [
        ["COL_LEFT_X", 0, 120, 1],
        ["COL_RIGHT_X", 120, 360, 1],
        ["EXTRA_LEFT_X", 0, 200, 1],
        ["COL_WIDTH", 100, 280, 1],
        ["CHECK_SCALE", 1, 3, 1],
        ["CHECK_LABEL_GAP", 0, 24, 1],
        ["OPTION_SIZE", 8, 18, 1],
        ["TITLE_SIZE", 10, 20, 1],
        ["TITLE_TO_ROW", 10, 48, 1],
        ["ROW_SPACING", 14, 48, 1],
      ],
    },
    {
      id: "g-sections",
      keys: [
        ["SECTION1_Y", 80, 280, 1],
        ["SECTION2_Y", 140, 400, 1],
        ["EXTRA_Y", 200, 500, 1],
      ],
    },
    {
      id: "g-buttons",
      keys: [
        ["BUTTON_Y", 280, 620, 1],
        ["DISCORD_X", 0, 360, 1],
        ["SETTINGS_X", 0, 360, 1],
      ],
    },
    {
      id: "g-flower",
      keys: [
        ["FLOWER_X", 0, 120, 1],
        ["FLOWER_SCALE", 1, 3, 1],
      ],
    },
  ];

  const state = { ...DEFAULTS };
  const imgs = {};

  const stage = document.getElementById("stage");
  const statusEl = document.getElementById("status");
  const out = document.getElementById("out");
  const showGuides = document.getElementById("showGuides");

  function loadImage(src) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = () => reject(new Error(src));
      img.src = src;
    });
  }

  /** Crop a horizontal spritesheet frame without canvas (file:// safe). */
  function spriteFrame(sheet, index, count, displayW, displayH) {
    const wrap = document.createElement("div");
    wrap.style.width = displayW + "px";
    wrap.style.height = displayH + "px";
    wrap.style.overflow = "hidden";
    wrap.style.flexShrink = "0";
    wrap.style.imageRendering = "pixelated";
    const i = sheet.cloneNode(true);
    i.draggable = false;
    i.style.display = "block";
    i.style.width = displayW * count + "px";
    i.style.height = displayH + "px";
    i.style.maxWidth = "none";
    i.style.marginLeft = -index * displayW + "px";
    i.style.imageRendering = "pixelated";
    wrap.appendChild(i);
    return wrap;
  }

  function ctrl(key, min, max, step) {
    const wrap = document.createElement("label");
    wrap.className = "ctrl";
    wrap.innerHTML = `<span>${key}</span>`;
    const range = document.createElement("input");
    range.type = "range";
    range.min = min;
    range.max = max;
    range.step = step;
    range.value = state[key];
    const num = document.createElement("input");
    num.type = "number";
    num.min = min;
    num.max = max;
    num.step = step;
    num.value = state[key];
    const sync = (v) => {
      const n = Number(v);
      if (!Number.isFinite(n)) return;
      state[key] = n;
      range.value = n;
      num.value = n;
      render();
      exportAs3(false);
    };
    range.addEventListener("input", () => sync(range.value));
    num.addEventListener("change", () => sync(num.value));
    wrap.appendChild(range);
    wrap.appendChild(num);
    return wrap;
  }

  function buildControls() {
    for (const g of GROUPS) {
      const host = document.getElementById(g.id);
      host.innerHTML = "";
      for (const [key, min, max, step] of g.keys) {
        host.appendChild(ctrl(key, min, max, step));
      }
    }
  }

  function refreshControlValues() {
    for (const g of GROUPS) {
      const host = document.getElementById(g.id);
      for (const el of host.querySelectorAll("label.ctrl")) {
        const key = el.querySelector("span").textContent;
        const range = el.querySelector('input[type=range]');
        const num = el.querySelector('input[type=number]');
        range.value = state[key];
        num.value = state[key];
      }
    }
  }

  function el(tag, cls, style) {
    const n = document.createElement(tag);
    if (cls) n.className = cls;
    if (style) Object.assign(n.style, style);
    return n;
  }

  function textNode(str, x, y, size, color, bold, width) {
    const t = el("div", "txt" + (bold ? " bold" : ""), {
      left: x + "px",
      top: y + "px",
      width: width + "px",
      fontSize: size + "px",
      color,
      fontWeight: bold ? "700" : "400",
      lineHeight: "1.25",
    });
    t.textContent = str;
    return t;
  }

  function measureTextHeight(str, size, bold, width) {
    const probe = textNode(str, -9999, -9999, size, "#fff", bold, width);
    probe.style.visibility = "hidden";
    document.body.appendChild(probe);
    const h = probe.offsetHeight;
    probe.remove();
    return h;
  }

  function addToggle(parent, label, x, y, on, greenWord) {
    if (!imgs.check) return;
    const checkSize = 18 * state.CHECK_SCALE;
    const row = el("div", "chk-row", { left: x + "px", top: y + "px" });
    row.appendChild(spriteFrame(imgs.check, on ? 1 : 0, 2, checkSize, checkSize));
    const lbl = el("span", "lbl", {
      marginLeft: state.CHECK_LABEL_GAP + "px",
      fontSize: state.OPTION_SIZE + "px",
      maxWidth: state.COL_WIDTH - checkSize - state.CHECK_LABEL_GAP + "px",
    });
    if (greenWord && label.includes(greenWord)) {
      const i = label.indexOf(greenWord);
      lbl.innerHTML =
        label.slice(0, i) +
        `<span class="green">${greenWord}</span>` +
        label.slice(i + greenWord.length);
    } else {
      lbl.textContent = label;
    }
    row.appendChild(lbl);
    parent.appendChild(row);
  }

  function addTitle(parent, title, x, y) {
    parent.appendChild(
      textNode(title, x, y, state.TITLE_SIZE, "#fff", true, state.VIEW_W - x - 14)
    );
  }

  function render() {
    const s = state;
    stage.style.width = s.VIEW_W + "px";
    stage.style.height = s.VIEW_H + "px";
    stage.innerHTML = "";

    // logo
    if (imgs.logo) {
      const logo = document.createElement("img");
      logo.src = imgs.logo.src;
      logo.className = "layer";
      logo.style.left = s.LOGO_X + "px";
      logo.style.top = s.LOGO_Y + "px";
      logo.style.width = imgs.logo.naturalWidth * s.LOGO_SCALE + "px";
      logo.style.height = imgs.logo.naturalHeight * s.LOGO_SCALE + "px";
      stage.appendChild(logo);
    }

    const copyW = s.VIEW_W - s.TEXT_X - s.TEXT_RIGHT_PAD;
    const headline = textNode(
      "Customize a sua experiência de jogo",
      s.TEXT_X,
      s.HEADLINE_Y,
      s.HEADLINE_SIZE,
      "#fff",
      true,
      copyW
    );
    stage.appendChild(headline);
    const headlineH = measureTextHeight(
      "Customize a sua experiência de jogo",
      s.HEADLINE_SIZE,
      true,
      copyW
    );
    const subY = Math.round(s.HEADLINE_Y + headlineH + s.SUBTITLE_GAP);
    const subtitle = textNode(
      "Utilize esse menu interativo para fazer as configurações iniciais :)",
      s.TEXT_X,
      subY,
      s.SUBTITLE_SIZE,
      "#d8d4d3",
      false,
      copyW
    );
    stage.appendChild(subtitle);
    const subH = measureTextHeight(
      "Utilize esse menu interativo para fazer as configurações iniciais :)",
      s.SUBTITLE_SIZE,
      false,
      copyW
    );
    const verY = Math.round(subY + subH + s.VERSION_GAP);
    stage.appendChild(
      textNode("Versão 0.1.0", s.TEXT_X, verY, s.VERSION_SIZE, "#6e6e6e", false, copyW)
    );

    // sections — mirrors BobbaHelperView.buildSections()
    addTitle(stage, "Funções de usuário", s.COL_LEFT_X, s.SECTION1_Y);
    addToggle(stage, "Anti AFK", s.COL_LEFT_X, s.SECTION1_Y + s.TITLE_TO_ROW, true);
    addToggle(stage, "Auto drop", s.COL_LEFT_X, s.SECTION1_Y + s.TITLE_TO_ROW + s.ROW_SPACING, false);
    addToggle(stage, "Bloquear giro", s.COL_RIGHT_X, s.SECTION1_Y + s.TITLE_TO_ROW, true);

    addTitle(stage, "Qualidade de vida", s.COL_LEFT_X, s.SECTION2_Y);
    addToggle(stage, "Chat em grupo", s.COL_LEFT_X, s.SECTION2_Y + s.TITLE_TO_ROW, true);
    addToggle(stage, "Desativar 67", s.COL_LEFT_X, s.SECTION2_Y + s.TITLE_TO_ROW + s.ROW_SPACING, true);
    addToggle(stage, "Desativar Habbicons", s.COL_LEFT_X, s.SECTION2_Y + s.TITLE_TO_ROW + s.ROW_SPACING * 2, false);
    addToggle(stage, "Sussurro em grupo", s.COL_RIGHT_X, s.SECTION2_Y + s.TITLE_TO_ROW, true);
    addToggle(stage, "Mover item de parede", s.COL_RIGHT_X, s.SECTION2_Y + s.TITLE_TO_ROW + s.ROW_SPACING, true);

    addTitle(stage, "Extra", s.EXTRA_LEFT_X, s.EXTRA_Y);
    addToggle(stage, "Traxmachine", s.EXTRA_LEFT_X, s.EXTRA_Y + s.TITLE_TO_ROW, true);
    addToggle(stage, "Ver visuais Bobba", s.COL_RIGHT_X, s.EXTRA_Y + s.TITLE_TO_ROW, true);

    // buttons
    if (imgs.discord) {
      const fw = Math.floor(imgs.discord.naturalWidth / 3);
      const fh = imgs.discord.naturalHeight;
      const d = spriteFrame(imgs.discord, 0, 3, fw, fh);
      d.className = "btn-sprite";
      d.style.left = s.DISCORD_X + "px";
      d.style.top = s.BUTTON_Y + "px";
      d.style.position = "absolute";
      stage.appendChild(d);
    }
    if (imgs.settings) {
      const fw = Math.floor(imgs.settings.naturalWidth / 3);
      const fh = imgs.settings.naturalHeight;
      const b = spriteFrame(imgs.settings, 0, 3, fw, fh);
      b.className = "btn-sprite";
      b.style.left = s.SETTINGS_X + "px";
      b.style.top = s.BUTTON_Y + "px";
      b.style.position = "absolute";
      stage.appendChild(b);
    }

    // flower
    if (imgs.flower) {
      const f = document.createElement("img");
      f.src = imgs.flower.src;
      f.className = "layer";
      const fh = imgs.flower.naturalHeight * s.FLOWER_SCALE;
      f.style.left = s.FLOWER_X + "px";
      f.style.top = s.VIEW_H - fh + "px";
      f.style.width = imgs.flower.naturalWidth * s.FLOWER_SCALE + "px";
      f.style.height = fh + "px";
      stage.appendChild(f);
    }

    if (showGuides.checked) {
      const guides = el("div", "guides");
      for (const x of [s.COL_LEFT_X, s.COL_RIGHT_X, s.TEXT_X, s.EXTRA_LEFT_X, s.DISCORD_X, s.SETTINGS_X]) {
        const line = el("div", "guide-line v");
        line.style.left = x + "px";
        guides.appendChild(line);
      }
      for (const y of [s.SECTION1_Y, s.SECTION2_Y, s.EXTRA_Y, s.BUTTON_Y, s.HEADLINE_Y]) {
        const line = el("div", "guide-line h");
        line.style.top = y + "px";
        guides.appendChild(line);
      }
      stage.appendChild(guides);
    }
  }

  function exportAs3(writeStatus) {
    const frameW = state.VIEW_W + 12;
    const frameH = state.VIEW_H + 36;
    const lines = [
      "// BobbaHelperView layout — paste into constants block",
      "// Keep BobbaHelperEditor.as frame/canvas XML in sync:",
      `//   layout/frame width="${frameW}" height="${frameH}"`,
      `//   canvas width="${state.VIEW_W}" height="${state.VIEW_H}"`,
      "",
      `public static const VIEW_W:int = ${state.VIEW_W};`,
      `public static const VIEW_H:int = ${state.VIEW_H};`,
      "",
      `private static const LOGO_SCALE:int = ${state.LOGO_SCALE};`,
      `private static const FLOWER_SCALE:int = ${state.FLOWER_SCALE};`,
      `private static const CHECK_SCALE:int = ${state.CHECK_SCALE};`,
      `private static const LOGO_X:Number = ${state.LOGO_X};`,
      `private static const LOGO_Y:Number = ${state.LOGO_Y};`,
      `private static const TEXT_X:Number = ${state.TEXT_X};`,
      `private static const TEXT_RIGHT_PAD:Number = ${state.TEXT_RIGHT_PAD};`,
      `private static const HEADLINE_Y:Number = ${state.HEADLINE_Y};`,
      `private static const HEADLINE_SIZE:int = ${state.HEADLINE_SIZE};`,
      `private static const SUBTITLE_SIZE:int = ${state.SUBTITLE_SIZE};`,
      `private static const VERSION_SIZE:int = ${state.VERSION_SIZE};`,
      `private static const SUBTITLE_GAP:Number = ${state.SUBTITLE_GAP};`,
      `private static const VERSION_GAP:Number = ${state.VERSION_GAP};`,
      `private static const CHECK_LABEL_GAP:Number = ${state.CHECK_LABEL_GAP};`,
      `private static const COL_LEFT_X:Number = ${state.COL_LEFT_X};`,
      `private static const COL_RIGHT_X:Number = ${state.COL_RIGHT_X};`,
      `private static const EXTRA_LEFT_X:Number = ${state.EXTRA_LEFT_X};`,
      `private static const COL_WIDTH:Number = ${state.COL_WIDTH};`,
      `private static const OPTION_SIZE:int = ${state.OPTION_SIZE};`,
      `private static const TITLE_SIZE:int = ${state.TITLE_SIZE};`,
      `private static const TITLE_TO_ROW:Number = ${state.TITLE_TO_ROW};`,
      `private static const ROW_SPACING:Number = ${state.ROW_SPACING};`,
      `private static const SECTION1_Y:Number = ${state.SECTION1_Y};`,
      `private static const SECTION2_Y:Number = ${state.SECTION2_Y};`,
      `private static const EXTRA_Y:Number = ${state.EXTRA_Y};`,
      `private static const BUTTON_Y:Number = ${state.BUTTON_Y};`,
      `private static const DISCORD_X:Number = ${state.DISCORD_X};`,
      `private static const SETTINGS_X:Number = ${state.SETTINGS_X};`,
      `private static const FLOWER_X:Number = ${state.FLOWER_X};`,
      "",
      "// JSON snapshot",
      "/*",
      JSON.stringify(state, null, 2),
      "*/",
    ];
    out.value = lines.join("\n");
    if (writeStatus) statusEl.textContent = "Exported AS3 constants.";
  }

  function loadExport() {
    const text = out.value;
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      try {
        const data = JSON.parse(jsonMatch[0]);
        Object.assign(state, data);
        refreshControlValues();
        render();
        exportAs3(false);
        statusEl.textContent = "Loaded JSON snapshot.";
        return;
      } catch (_) {}
    }
    const re = /(?:const\s+)?([A-Z0-9_]+)\s*(?::\w+)?\s*=\s*(-?\d+(?:\.\d+)?)/g;
    let m;
    let n = 0;
    while ((m = re.exec(text))) {
      if (m[1] in state) {
        state[m[1]] = Number(m[2]);
        n++;
      }
    }
    refreshControlValues();
    render();
    exportAs3(false);
    statusEl.textContent = n ? `Loaded ${n} constants from export.` : "No recognizable values found.";
  }

  document.getElementById("btnExport").onclick = () => exportAs3(true);
  document.getElementById("btnCopy").onclick = async () => {
    exportAs3(false);
    try {
      await navigator.clipboard.writeText(out.value);
      statusEl.textContent = "Copied to clipboard.";
    } catch {
      out.select();
      statusEl.textContent = "Select+copy manually (clipboard blocked).";
    }
  };
  document.getElementById("btnApply").onclick = loadExport;
  document.getElementById("btnReset").onclick = () => {
    Object.assign(state, DEFAULTS);
    refreshControlValues();
    render();
    exportAs3(false);
    statusEl.textContent = "Reset to defaults.";
  };
  showGuides.addEventListener("change", render);

  buildControls();

  Promise.allSettled([
    loadImage(ASSET.logo).then((img) => { imgs.logo = img; }),
    loadImage(ASSET.check).then((img) => { imgs.check = img; }),
    loadImage(ASSET.flower).then((img) => { imgs.flower = img; }),
    loadImage(ASSET.discord).then((img) => { imgs.discord = img; }),
    loadImage(ASSET.settings).then((img) => { imgs.settings = img; }),
  ]).then((results) => {
    const failed = [];
    const names = ["logo", "check", "flower", "discord", "settings"];
    results.forEach((r, i) => {
      if (r.status === "rejected") failed.push(names[i]);
    });
    if (failed.length) {
      statusEl.textContent = "Some assets failed: " + failed.join(", ");
    } else {
      statusEl.textContent = "Ready — tweak sliders, then Export / Copy.";
    }
    render();
    exportAs3(false);
  });
})();

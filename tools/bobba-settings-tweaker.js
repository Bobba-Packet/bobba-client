(() => {
  const ASSET = {
    check: "./bobba-helper-tweaker-assets/checkbox.png",
  };

  /** Content catalogue mirrored from docs/settings-window-spec.md */
  const CATEGORIES = [
    {
      id: "cliente",
      label: "Cliente",
      topics: [
        {
          title: "Aparência",
          hint: "Bottom-bar blend needs alt style; seasonal colours override pickers.",
          rows: [
            { label: "Cor da barra de título", control: "color", status: "Ready" },
            { label: "Cor da barra inferior", control: "color", status: "Ready" },
            { label: "Transparência da janela", control: "slider", status: "Ready" },
            { label: "Transparência da barra inferior", control: "slider", status: "Ready", disabledWhen: "altBar" },
            { label: "Estilo alternativo da barra inferior", control: "toggle", status: "Ready", key: "altBar" },
            { label: "Cores sazonais", control: "toggle", status: "Ready", on: true },
          ],
        },
        {
          title: "Desempenho",
          rows: [
            { label: "FPS do cliente", control: "slider", status: "Ready" },
            { label: "Desbloquear FPS das animações", control: "toggle", status: "Ready" },
            { label: "Otimização em FPS baixo", control: "dropdown", status: "Ready" },
            { label: "Bloquear anúncios (MPU)", control: "toggle", status: "Ready" },
          ],
        },
        {
          title: "Áudio",
          rows: [
            { label: "Volume da interface", control: "slider", status: "Server" },
            { label: "Volume dos mobis", control: "slider", status: "Server" },
            { label: "Volume das músicas (Trax)", control: "slider", status: "Server" },
          ],
        },
      ],
    },
    {
      id: "chat",
      label: "Chat",
      topics: [
        {
          title: "Aparência do chat",
          rows: [
            { label: "Tamanho da fonte do chat", control: "slider", status: "Ready" },
            { label: "Largura do balão", control: "segmented", status: "Server" },
            { label: "Modo do chat", control: "segmented", status: "Server" },
            { label: "Velocidade de rolagem", control: "segmented", status: "Server" },
          ],
        },
        {
          title: "Balões",
          rows: [
            { label: "Mostrar todos os estilos de balão", control: "toggle", status: "Ready" },
            { label: "Forçar estilo de balão", control: "dropdown", status: "Ready" },
            { label: "Cor de texto personalizada", control: "toggle", status: "Ready" },
            { label: "Indicador de digitação", control: "toggle", status: "Ready", on: true },
          ],
        },
        {
          title: "Silenciar e filtrar",
          rows: [
            { label: "Silenciar chat do quarto", control: "toggle", status: "Ready" },
            { label: "Silenciar pets", control: "toggle", status: "Ready" },
            { label: "Silenciar bots", control: "toggle", status: "Ready" },
            { label: "Silenciar comandos", control: "toggle", status: "Ready" },
            { label: "Ocultar balões de ignorados", control: "toggle", status: "Ready" },
            { label: "Filtro de palavras", control: "list", status: "Server" },
          ],
        },
        {
          title: "Entrada e comandos",
          rows: [
            { label: "Destaque de cor e autocompletar", control: "toggle", status: "Ready", on: true },
            { label: "Palavra de alerta sonoro", control: "text", status: "Session" },
            { label: "Texto de flood", control: "text", status: "Session" },
            { label: "Intervalo do flood", control: "stepper", status: "Session" },
          ],
        },
      ],
    },
    {
      id: "quarto",
      label: "Quarto",
      topics: [
        {
          title: "Renderização e cores",
          rows: [
            { label: "Luz do quarto", control: "slider", status: "Ready" },
            { label: "Luz de fundo", control: "slider", status: "Ready" },
            { label: "Cor de fundo do quarto", control: "color", status: "Ready" },
          ],
        },
        {
          title: "Zoom e câmera",
          rows: [
            { label: "Zoom fracionado", control: "slider", status: "Ready" },
            { label: "Gestos de zoom", control: "toggle", status: "Ready" },
            { label: "Desativar câmera seguindo o usuário", control: "toggle", status: "Server" },
          ],
        },
        {
          title: "Mobis",
          rows: [
            { label: "Duplo clique em mobis", control: "toggle", status: "Ready", on: true },
            { label: "Ctrl para usar mobi com um clique", control: "toggle", status: "Ready" },
            { label: "Usar mobi com um clique", control: "toggle", status: "Session" },
            { label: "Mover item de parede", control: "toggle", status: "Ready" },
            { label: "Auto drop", control: "toggle", status: "Ready" },
            { label: "Autoclique", control: "toggle", status: "Session", key: "autoclick" },
            { label: "Intervalo do autoclique", control: "stepper", status: "Session", disabledWhen: "autoclick" },
          ],
        },
        {
          title: "Bloqueios",
          rows: [
            { label: "Modo click-through", control: "toggle", status: "Ready" },
            { label: "Bloquear giro do avatar", control: "toggle", status: "Ready" },
            { label: "Bloquear WiredClickUser", control: "toggle", status: "Ready" },
            { label: "Shift para bloquear caminhada", control: "toggle", status: "Ready" },
            { label: "Bloquear caminhada", control: "toggle", status: "Session" },
            { label: "Bloquear trocas", control: "toggle", status: "Session" },
          ],
        },
        {
          title: "Sobreposições",
          rows: [
            { label: "Ocultar infostand", control: "toggle", status: "Ready" },
            { label: "Mostrar IDs dos objetos", control: "toggle", status: "Ready" },
            { label: "Mostrar IDs das missões", control: "toggle", status: "Ready" },
          ],
        },
      ],
    },
    {
      id: "avatar",
      label: "Avatar e Social",
      topics: [
        {
          title: "Avatar",
          rows: [
            { label: "Efeito (FX) personalizado", control: "dropdown", status: "Ready" },
            { label: "Anti AFK", control: "toggle", status: "Ready" },
            { label: "Visuais salvos", control: "list", status: "Ready" },
          ],
        },
        {
          title: "Amigos",
          rows: [
            { label: "Destacar entrada de amigos", control: "toggle", status: "Ready", on: true },
            { label: "Notificar amigo online", control: "segmented", status: "Ready" },
          ],
        },
        {
          title: "Notificações e privacidade",
          rows: [
            { label: "Alertas de moderação", control: "toggle", status: "Ready", on: true },
            { label: "Ignorar convites de quarto", control: "toggle", status: "Server" },
            { label: "Desativar sussurro de wired", control: "toggle", status: "Server" },
          ],
        },
        {
          title: "Extras Bobba",
          rows: [
            { label: "Chat em grupo", control: "toggle", status: "Stub" },
            { label: "Sussurro em grupo", control: "toggle", status: "Stub" },
            { label: "Desativar 67", control: "toggle", status: "Ready" },
            { label: "Desativar Habbicons", control: "toggle", status: "Ready" },
            { label: "Ver visuais Bobba", control: "toggle", status: "Ready", on: true },
          ],
        },
      ],
    },
    {
      id: "avancado",
      label: "Avançado",
      topics: [
        {
          title: "Atalhos",
          rows: [
            { label: "Atalhos de teclado", control: "keylist", status: "Ready" },
            { label: "Modo de acionamento", control: "segmented", status: "Ready" },
          ],
        },
        {
          title: "Ping",
          rows: [
            { label: "Texto antes do ping", control: "text", status: "Ready" },
            { label: "Texto depois do ping", control: "text", status: "Ready" },
            { label: "Estilo do balão do ping", control: "dropdown", status: "Ready" },
            { label: "Dizer ping publicamente", control: "toggle", status: "Session" },
          ],
        },
        {
          title: "Desenvolvedor",
          rows: [
            { label: "Mostrar erros críticos", control: "toggle", status: "Ready" },
          ],
        },
        {
          title: "Dados",
          rows: [
            { label: "Exportar configurações", control: "button", status: "Ready" },
            { label: "Importar configurações", control: "button", status: "Ready", danger: true },
            { label: "Restaurar padrões", control: "button", status: "Ready", danger: true },
          ],
        },
      ],
    },
  ];

  const DEFAULTS = {
    VIEW_W: 520,
    VIEW_H: 420,
    TOP_H: 40,
    TOP_PAD_X: 12,
    TOP_PAD_Y: 8,
    SEARCH_H: 24,
    SIDEBAR_W: 148,
    NAV_PAD_X: 10,
    NAV_PAD_Y: 10,
    NAV_ITEM_H: 28,
    NAV_GAP: 2,
    CONTENT_PAD_X: 14,
    CONTENT_PAD_Y: 12,
    TOPIC_GAP: 18,
    TOPIC_TITLE_SIZE: 13,
    TOPIC_TITLE_TO_ROWS: 10,
    TOPIC_HINT_GAP: 4,
    ROW_H: 28,
    ROW_GAP: 4,
    CTRL_W: 140,
    LABEL_SIZE: 12,
  };

  const GROUPS = [
    {
      id: "g-window",
      keys: [
        ["VIEW_W", 400, 800, 1],
        ["VIEW_H", 320, 700, 1],
      ],
    },
    {
      id: "g-top",
      keys: [
        ["TOP_H", 28, 72, 1],
        ["TOP_PAD_X", 4, 32, 1],
        ["TOP_PAD_Y", 2, 24, 1],
        ["SEARCH_H", 18, 36, 1],
      ],
    },
    {
      id: "g-sidebar",
      keys: [
        ["SIDEBAR_W", 100, 240, 1],
        ["NAV_PAD_X", 4, 24, 1],
        ["NAV_PAD_Y", 4, 24, 1],
        ["NAV_ITEM_H", 22, 40, 1],
        ["NAV_GAP", 0, 12, 1],
      ],
    },
    {
      id: "g-content",
      keys: [
        ["CONTENT_PAD_X", 6, 32, 1],
        ["CONTENT_PAD_Y", 6, 32, 1],
        ["TOPIC_GAP", 8, 40, 1],
        ["TOPIC_TITLE_SIZE", 10, 18, 1],
        ["TOPIC_TITLE_TO_ROWS", 4, 24, 1],
        ["TOPIC_HINT_GAP", 0, 12, 1],
        ["ROW_H", 22, 40, 1],
        ["ROW_GAP", 0, 12, 1],
        ["CTRL_W", 80, 220, 1],
        ["LABEL_SIZE", 10, 16, 1],
      ],
    },
  ];

  const state = { ...DEFAULTS };
  let activeCat = 0;
  let checkImg = null;

  const stage = document.getElementById("stage");
  const statusEl = document.getElementById("status");
  const out = document.getElementById("out");
  const meta = document.getElementById("meta");
  const showSearch = document.getElementById("showSearch");
  const showBadges = document.getElementById("showBadges");
  const showDisabled = document.getElementById("showDisabled");
  const showGuides = document.getElementById("showGuides");
  const hideStubs = document.getElementById("hideStubs");

  function loadImage(src) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = () => reject(new Error(src));
      img.src = src;
    });
  }

  function spriteFrame(sheet, index, count, displayW, displayH) {
    const wrap = document.createElement("div");
    wrap.className = "fake-toggle";
    wrap.style.width = displayW + "px";
    wrap.style.height = displayH + "px";
    wrap.style.overflow = "hidden";
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

  function buildCatTabs() {
    const host = document.getElementById("catTabs");
    host.innerHTML = "";
    CATEGORIES.forEach((cat, i) => {
      const b = document.createElement("button");
      b.textContent = cat.label;
      if (i === activeCat) b.className = "active";
      b.onclick = () => {
        activeCat = i;
        buildCatTabs();
        render();
      };
      host.appendChild(b);
    });
  }

  function countRows(cat) {
    let n = 0;
    for (const t of cat.topics) {
      for (const r of t.rows) {
        if (hideStubs.checked && r.status === "Stub") continue;
        n++;
      }
    }
    return n;
  }

  function el(tag, cls, style) {
    const n = document.createElement(tag);
    if (cls) n.className = cls;
    if (style) Object.assign(n.style, style);
    return n;
  }

  function controlPreview(row) {
    const host = el("div", "s-ctrl");
    host.style.width = state.CTRL_W + "px";
    const c = row.control;
    if (c === "toggle") {
      if (checkImg) {
        host.appendChild(spriteFrame(checkImg, row.on ? 1 : 0, 2, 18, 18));
      } else {
        const box = el("div", "fake-toggle");
        box.style.background = row.on ? "#31a342" : "#333";
        box.style.border = "1px solid #555";
        host.appendChild(box);
      }
    } else if (c === "slider") {
      const s = el("div", "fake-slider");
      s.style.width = Math.max(60, state.CTRL_W - 40) + "px";
      const v = el("span", "val");
      v.textContent = "60";
      s.appendChild(v);
      host.appendChild(s);
    } else if (c === "segmented") {
      const seg = el("div", "fake-seg");
      ["A", "B", "C"].forEach((t, i) => {
        const sp = el("span", i === 1 ? "on" : "");
        sp.textContent = t;
        seg.appendChild(sp);
      });
      host.appendChild(seg);
    } else if (c === "dropdown") {
      const d = el("div", "fake-drop");
      d.textContent = "Opção ▾";
      d.style.width = "100%";
      host.appendChild(d);
    } else if (c === "text") {
      const d = el("div", "fake-input");
      d.textContent = "texto…";
      d.style.width = "100%";
      host.appendChild(d);
    } else if (c === "stepper") {
      const d = el("div", "fake-step");
      d.textContent = "− 1000 +";
      host.appendChild(d);
    } else if (c === "color") {
      const d = el("div", "fake-color");
      const sw = el("i");
      sw.style.background = "#C13270";
      d.appendChild(sw);
      d.appendChild(document.createTextNode("#C13270"));
      host.appendChild(d);
    } else if (c === "button") {
      const d = el("div", "fake-btn" + (row.danger ? " danger" : ""));
      d.textContent = row.label.split(" ")[0] + "…";
      host.appendChild(d);
    } else if (c === "list" || c === "keylist") {
      const d = el("div", "fake-list");
      d.textContent = c === "keylist" ? "Gerenciar atalhos…" : "Gerenciar lista…";
      d.style.width = "100%";
      host.appendChild(d);
    } else {
      const d = el("div", "fake-input");
      d.textContent = c;
      host.appendChild(d);
    }
    return host;
  }

  function flagMap(cat) {
    const flags = {};
    for (const t of cat.topics) {
      for (const r of t.rows) {
        if (r.key) flags[r.key] = !!r.on;
      }
    }
    return flags;
  }

  function render() {
    const s = state;
    const cat = CATEGORIES[activeCat];
    const flags = flagMap(cat);

    stage.style.width = s.VIEW_W + "px";
    stage.style.height = s.VIEW_H + "px";
    stage.innerHTML = "";

    // top bar
    if (showSearch.checked) {
      const top = el("div", "s-top", {
        height: s.TOP_H + "px",
        padding: s.TOP_PAD_Y + "px " + s.TOP_PAD_X + "px",
      });
      const wrap = el("div", "s-search-wrap", { height: s.SEARCH_H + "px" });
      const input = el("div", "s-search", {
        height: s.SEARCH_H + "px",
        lineHeight: s.SEARCH_H - 2 + "px",
      });
      input.textContent = "Buscar configurações…";
      wrap.appendChild(input);
      top.appendChild(wrap);
      stage.appendChild(top);
    }

    const body = el("div", "s-body");
    body.style.height =
      s.VIEW_H - (showSearch.checked ? s.TOP_H : 0) + "px";

    // sidebar
    const side = el("div", "s-sidebar", {
      width: s.SIDEBAR_W + "px",
      padding: s.NAV_PAD_Y + "px " + s.NAV_PAD_X + "px",
    });
    CATEGORIES.forEach((c, i) => {
      const btn = el("button", "s-nav" + (i === activeCat ? " active" : ""), {
        height: s.NAV_ITEM_H + "px",
        marginBottom: s.NAV_GAP + "px",
        padding: "0 8px",
        fontSize: "12px",
      });
      btn.innerHTML =
        c.label + '<span class="count">' + countRows(c) + "</span>";
      btn.onclick = () => {
        activeCat = i;
        buildCatTabs();
        render();
      };
      side.appendChild(btn);
    });
    body.appendChild(side);

    // content
    const content = el("div", "s-content", {
      padding: s.CONTENT_PAD_Y + "px " + s.CONTENT_PAD_X + "px",
    });

    cat.topics.forEach((topic, ti) => {
      const block = el("div", "s-topic", {
        marginBottom: ti < cat.topics.length - 1 ? s.TOPIC_GAP + "px" : "0",
      });
      const title = el("div", "s-topic-title", {
        fontSize: s.TOPIC_TITLE_SIZE + "px",
      });
      title.textContent = topic.title;
      block.appendChild(title);
      if (topic.hint) {
        const hint = el("div", "s-topic-hint", {
          marginTop: s.TOPIC_HINT_GAP + "px",
        });
        hint.textContent = topic.hint;
        block.appendChild(hint);
      }

      const rowsWrap = el("div", "", {
        marginTop: s.TOPIC_TITLE_TO_ROWS + "px",
        display: "flex",
        flexDirection: "column",
        gap: s.ROW_GAP + "px",
      });

      for (const row of topic.rows) {
        if (hideStubs.checked && row.status === "Stub") continue;
        const disabled =
          showDisabled.checked &&
          row.disabledWhen &&
          !flags[row.disabledWhen];
        const rowEl = el("div", "s-row" + (disabled ? " disabled" : ""), {
          height: s.ROW_H + "px",
          padding: "0 4px",
        });
        const label = el("div", "label", { fontSize: s.LABEL_SIZE + "px" });
        label.textContent = row.label;
        label.title = row.label + " · " + row.control + " · " + row.status;
        rowEl.appendChild(label);
        if (showBadges.checked && row.status !== "Ready") {
          const badge = el(
            "span",
            "badge " + row.status.toLowerCase()
          );
          badge.textContent = row.status;
          rowEl.appendChild(badge);
        }
        rowEl.appendChild(controlPreview(row));
        rowsWrap.appendChild(rowEl);
      }
      block.appendChild(rowsWrap);
      content.appendChild(block);
    });

    body.appendChild(content);
    stage.appendChild(body);

    if (showGuides.checked) {
      const guides = el("div", "guides");
      const vx = [s.SIDEBAR_W, s.SIDEBAR_W + s.CONTENT_PAD_X];
      for (const x of vx) {
        const line = el("div", "guide-line v");
        line.style.left = x + "px";
        guides.appendChild(line);
      }
      if (showSearch.checked) {
        const line = el("div", "guide-line h");
        line.style.top = s.TOP_H + "px";
        guides.appendChild(line);
      }
      stage.appendChild(guides);
    }

    const totalSettings = CATEGORIES.reduce((a, c) => a + countRows(c), 0);
    const frameW = s.VIEW_W + 12;
    const frameH = s.VIEW_H + 36;
    meta.innerHTML =
      "<strong>" +
      cat.label +
      "</strong> · " +
      countRows(cat) +
      " rows · " +
      cat.topics.length +
      " topics · canvas <strong>" +
      s.VIEW_W +
      "×" +
      s.VIEW_H +
      "</strong> · frame ~<strong>" +
      frameW +
      "×" +
      frameH +
      "</strong> · catalogue <strong>" +
      totalSettings +
      "</strong> settings across " +
      CATEGORIES.length +
      " categories";
  }

  function exportAs3(writeStatus) {
    const frameW = state.VIEW_W + 12;
    const frameH = state.VIEW_H + 36;
    const lines = [
      "// BobbaSettingsView / BobbaSettingsEditor layout — from bobba-settings-tweaker",
      "// Frame XML: width=\"" + frameW + "\" height=\"" + frameH + "\"",
      "// Canvas: width=\"" + state.VIEW_W + "\" height=\"" + state.VIEW_H + "\"",
      "// Margins: left=6 top=30 right=6 bottom=6  →  frame = VIEW + 12 × VIEW + 36",
      "",
      "public static const VIEW_W:int = " + state.VIEW_W + ";",
      "public static const VIEW_H:int = " + state.VIEW_H + ";",
      "",
      "private static const TOP_H:Number = " + state.TOP_H + ";",
      "private static const TOP_PAD_X:Number = " + state.TOP_PAD_X + ";",
      "private static const TOP_PAD_Y:Number = " + state.TOP_PAD_Y + ";",
      "private static const SEARCH_H:Number = " + state.SEARCH_H + ";",
      "private static const SHOW_SEARCH:Boolean = " + showSearch.checked + ";",
      "",
      "private static const SIDEBAR_W:Number = " + state.SIDEBAR_W + ";",
      "private static const NAV_PAD_X:Number = " + state.NAV_PAD_X + ";",
      "private static const NAV_PAD_Y:Number = " + state.NAV_PAD_Y + ";",
      "private static const NAV_ITEM_H:Number = " + state.NAV_ITEM_H + ";",
      "private static const NAV_GAP:Number = " + state.NAV_GAP + ";",
      "",
      "private static const CONTENT_PAD_X:Number = " + state.CONTENT_PAD_X + ";",
      "private static const CONTENT_PAD_Y:Number = " + state.CONTENT_PAD_Y + ";",
      "private static const TOPIC_GAP:Number = " + state.TOPIC_GAP + ";",
      "private static const TOPIC_TITLE_SIZE:int = " + state.TOPIC_TITLE_SIZE + ";",
      "private static const TOPIC_TITLE_TO_ROWS:Number = " + state.TOPIC_TITLE_TO_ROWS + ";",
      "private static const TOPIC_HINT_GAP:Number = " + state.TOPIC_HINT_GAP + ";",
      "private static const ROW_H:Number = " + state.ROW_H + ";",
      "private static const ROW_GAP:Number = " + state.ROW_GAP + ";",
      "private static const CTRL_W:Number = " + state.CTRL_W + ";",
      "private static const LABEL_SIZE:int = " + state.LABEL_SIZE + ";",
      "",
      "// Suggested decisions from this tweaker:",
      "// - Navigation: left sidebar (" + CATEGORIES.length + " categories)",
      "// - Scrolling: content pane scrolls; sidebar fixed",
      "// - Search: " + (showSearch.checked ? "enabled in top bar" : "hidden"),
      "",
      "// JSON snapshot",
      "/*",
      JSON.stringify(
        {
          ...state,
          SHOW_SEARCH: showSearch.checked,
          activeCat,
        },
        null,
        2
      ),
      "*/",
    ];
    out.value = lines.join("\n");
    if (writeStatus) statusEl.textContent = "Exported AS3 layout constants.";
  }

  function loadExport() {
    const text = out.value;
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      try {
        const data = JSON.parse(jsonMatch[0]);
        Object.keys(DEFAULTS).forEach((k) => {
          if (k in data) state[k] = data[k];
        });
        if (typeof data.SHOW_SEARCH === "boolean") {
          showSearch.checked = data.SHOW_SEARCH;
        }
        if (typeof data.activeCat === "number") {
          activeCat = Math.max(0, Math.min(CATEGORIES.length - 1, data.activeCat));
        }
        refreshControlValues();
        buildCatTabs();
        render();
        exportAs3(false);
        statusEl.textContent = "Loaded JSON snapshot.";
        return;
      } catch (_) {}
    }
    const re = /(?:const\s+)?([A-Z0-9_]+)\s*(?::\w+)?\s*=\s*(-?\d+(?:\.\d+)?|true|false)/g;
    let m;
    let n = 0;
    while ((m = re.exec(text))) {
      if (m[1] === "SHOW_SEARCH") {
        showSearch.checked = m[2] === "true";
        n++;
        continue;
      }
      if (m[1] in state) {
        state[m[1]] = Number(m[2]);
        n++;
      }
    }
    refreshControlValues();
    render();
    exportAs3(false);
    statusEl.textContent = n
      ? "Loaded " + n + " constants from export."
      : "No recognizable values found.";
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
    showSearch.checked = true;
    showBadges.checked = true;
    showDisabled.checked = true;
    showGuides.checked = false;
    hideStubs.checked = false;
    activeCat = 0;
    refreshControlValues();
    buildCatTabs();
    render();
    exportAs3(false);
    statusEl.textContent = "Reset to defaults.";
  };

  [showSearch, showBadges, showDisabled, showGuides, hideStubs].forEach((el) => {
    el.addEventListener("change", () => {
      render();
      exportAs3(false);
    });
  });

  buildControls();
  buildCatTabs();

  loadImage(ASSET.check)
    .then((img) => {
      checkImg = img;
      statusEl.textContent = "Ready — tweak layout, then Export / Copy.";
      render();
      exportAs3(false);
    })
    .catch(() => {
      statusEl.textContent = "Checkbox asset missing — using fallback boxes.";
      render();
      exportAs3(false);
    });
})();

const ASSET_W = 838, ASSET_H = 302, VIEW_SCALE = 1.25;
const ORDER = [1, 4, 0, 3, 2];
const TEXT_SIZE_RATIO = 0.072;
const BOTTOM_PAD_RATIO = 0.08;
const RIGHT_INSET_RATIO = 0.04;
const DEFAULTS = [
  { cx: 116, cy: 124, rot: -7, size: 179, nameDx: 0, nameDy: 0, likesDx: 0, likesDy: 0, textScale: 1 },
  { cx: 264, cy: 106, rot: 5.9, size: 122, nameDx: 0, nameDy: 0, likesDx: 0, likesDy: 0, textScale: 1 },
  { cx: 413, cy: 111, rot: 0, size: 174, nameDx: 0, nameDy: 0, likesDx: 0, likesDy: 0, textScale: 1 },
  { cx: 549, cy: 97, rot: -16.5, size: 124, nameDx: 0, nameDy: 0, likesDx: 0, likesDy: 0, textScale: 1 },
  { cx: 703, cy: 138, rot: 21.5, size: 183, nameDx: 0, nameDy: 0, likesDx: 0, likesDy: 0, textScale: 1 },
];
const COLORS = ["#dc3c3c", "#3cb450", "#3c78dc", "#dcb428", "#b43cc8"];
const SAMPLE_NAMES = ["HabboUser", "PixelQueen", "RoomBuilder", "BobbaFan", "HotelGuest"];
const SAMPLE_LIKES = [3, 12, 0, 7, 1];

let slots = DEFAULTS.map((s) => ({ ...s }));
let selected = 0;
let overlay = new Image();
let photos = [];
let authors = SAMPLE_NAMES.slice();
let likes = SAMPLE_LIKES.slice();
let dragging = false;
let dragTarget = "photo"; // photo | name | likes
let dragOff = { x: 0, y: 0 };

function formatCaption(name) {
  return name != null ? String(name) : "";
}

function likesText(likeCount) {
  if (likeCount == null || likeCount < 0) return "";
  return String(likeCount);
}

function fontSizeFor(s) {
  const scale = s.textScale > 0 ? s.textScale : 1;
  return Math.max(7, Math.round(s.size * TEXT_SIZE_RATIO * scale));
}

function bottomLocalY(s) {
  return s.size * 0.5 + s.size * BOTTOM_PAD_RATIO + (s.nameDy || 0);
}

function likesBottomLocalY(s) {
  return s.size * 0.5 + s.size * BOTTOM_PAD_RATIO + (s.likesDy || 0);
}

/** Photo-local -> asset coords */
function localToAsset(s, lx, ly) {
  const rad = (s.rot * Math.PI) / 180;
  const c = Math.cos(rad);
  const sn = Math.sin(rad);
  return {
    x: s.cx + lx * c - ly * sn,
    y: s.cy + lx * sn + ly * c,
  };
}

function nameAnchor(s) {
  return localToAsset(s, s.nameDx || 0, bottomLocalY(s));
}

function likesAnchor(s) {
  const lx = s.size * 0.5 - s.size * RIGHT_INSET_RATIO + (s.likesDx || 0);
  return localToAsset(s, lx, likesBottomLocalY(s));
}

const cv = document.getElementById("cv");
const ctx = cv.getContext("2d");
const tabs = document.getElementById("tabs");
const photoIds = ["cx", "cy", "rot", "size"];
const nameIds = ["nameDx", "nameDy", "textScale"];
const likesIds = ["likesDx", "likesDy"];
const ids = photoIds.concat(nameIds, likesIds);

function stageLayout() {
  const scale = VIEW_SCALE;
  const w = ASSET_W * scale;
  const h = ASSET_H * scale;
  return { scale, x: (1280 - w) * 0.5, y: (800 - h) * 0.38, w, h };
}

function draw() {
  const L = stageLayout();
  ctx.clearRect(0, 0, 1280, 800);
  ctx.fillStyle = "#14161e";
  ctx.fillRect(0, 0, 1280, 800);

  for (const idx of ORDER) {
    const s = slots[idx];
    ctx.save();
    ctx.translate(L.x + s.cx * L.scale, L.y + s.cy * L.scale);
    ctx.rotate((s.rot * Math.PI) / 180);
    const half = (s.size * L.scale) / 2;
    ctx.beginPath();
    ctx.rect(-half, -half, half * 2, half * 2);
    ctx.clip();
    if (photos[idx]) {
      const img = photos[idx];
      const sc = Math.max((s.size * L.scale) / img.width, (s.size * L.scale) / img.height);
      const iw = img.width * sc;
      const ih = img.height * sc;
      ctx.drawImage(img, -iw / 2, -ih / 2, iw, ih);
    } else {
      ctx.fillStyle = COLORS[idx];
      ctx.fillRect(-half, -half, half * 2, half * 2);
    }
    if (document.getElementById("showNums").checked) {
      ctx.fillStyle = "#fff";
      ctx.font = "bold 18px sans-serif";
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      ctx.fillText(String(idx), 0, 0);
    }
    if (idx === selected && dragTarget === "photo") {
      ctx.strokeStyle = "#ffe14a";
      ctx.lineWidth = 2;
      ctx.strokeRect(-half, -half, half * 2, half * 2);
    }
    ctx.restore();
  }

  if (overlay.complete && overlay.naturalWidth) {
    ctx.drawImage(overlay, L.x, L.y, L.w, L.h);
  }

  if (document.getElementById("showNames").checked) {
    for (let idx = 0; idx < 5; idx++) {
      const s = slots[idx];
      const name = formatCaption(authors[idx] || SAMPLE_NAMES[idx]);
      const likeStr = likesText(likes[idx]);
      const fontPx = Math.max(8, fontSizeFor(s) * L.scale);

      // Draw in photo-local space so text follows tilt
      ctx.save();
      ctx.translate(L.x + s.cx * L.scale, L.y + s.cy * L.scale);
      ctx.rotate((s.rot * Math.PI) / 180);
      ctx.font = "bold " + fontPx + "px \"Volter Bold\", monospace";
      ctx.textBaseline = "middle";
      ctx.fillStyle = "#000000";

      const nameLy = (s.size * 0.5 + s.size * BOTTOM_PAD_RATIO + (s.nameDy || 0)) * L.scale;
      const nameLx = (s.nameDx || 0) * L.scale;
      ctx.textAlign = "center";
      ctx.fillText(name, nameLx, nameLy);
      if (idx === selected && dragTarget === "name") {
        const w = ctx.measureText(name).width + 10;
        ctx.strokeStyle = "#7dffb3";
        ctx.lineWidth = 2;
        ctx.strokeRect(nameLx - w / 2, nameLy - fontPx, w, fontPx * 2);
      }

      if (likeStr) {
        const likesLy = (s.size * 0.5 + s.size * BOTTOM_PAD_RATIO + (s.likesDy || 0)) * L.scale;
        const likesLx = (s.size * 0.5 - s.size * RIGHT_INSET_RATIO + (s.likesDx || 0)) * L.scale;
        ctx.textAlign = "right";
        ctx.fillText(likeStr, likesLx, likesLy);
        if (idx === selected && dragTarget === "likes") {
          const w = ctx.measureText(likeStr).width + 10;
          ctx.strokeStyle = "#7db3ff";
          ctx.lineWidth = 2;
          ctx.strokeRect(likesLx - w, likesLy - fontPx, w, fontPx * 2);
        }
      }
      ctx.restore();
    }
  }

  ctx.strokeStyle = "#fff";
  ctx.strokeRect(440, 700, 400, 25);
  ctx.fillStyle = "#ff8c32";
  ctx.fillRect(442, 702, 158, 21);
}

function syncControls() {
  const s = slots[selected];
  const mode = dragTarget === "likes" ? " · likes" : dragTarget === "name" ? " · author" : " · photo";
  document.getElementById("slotTitle").textContent =
    "Slot " + selected + mode + " · font~" + fontSizeFor(s) + "px";
  for (const k of ids) {
    document.getElementById(k).value = s[k];
    document.getElementById(k + "N").value = s[k];
  }
  [...tabs.children].forEach((b, i) => b.classList.toggle("active", i === selected));
  draw();
  exportText(false);
}

function bind() {
  for (let i = 0; i < 5; i++) {
    const b = document.createElement("button");
    b.textContent = String(i);
    b.onclick = () => {
      selected = i;
      syncControls();
    };
    tabs.appendChild(b);
  }

  for (const k of ids) {
    const sync = () => {
      let v = parseFloat(document.getElementById(k).value);
      if (k === "rot" || k === "textScale") v = Math.round(v * 100) / 100;
      else v = Math.round(v);
      slots[selected][k] = v;
      document.getElementById(k + "N").value = v;
      draw();
      exportText(false);
    };
    const syncN = () => {
      let v = parseFloat(document.getElementById(k + "N").value);
      if (Number.isNaN(v)) return;
      if (k === "rot" || k === "textScale") v = Math.round(v * 100) / 100;
      else v = Math.round(v);
      slots[selected][k] = v;
      document.getElementById(k).value = v;
      draw();
      exportText(false);
    };
    document.getElementById(k).addEventListener("input", sync);
    document.getElementById(k + "N").addEventListener("change", syncN);
  }

  ["showNums", "showNames"].forEach((id) => {
    document.getElementById(id).onchange = draw;
  });
  document.getElementById("usePhotos").onchange = () => {
    if (document.getElementById("usePhotos").checked) loadPhotos();
    else {
      photos = [];
      authors = SAMPLE_NAMES.slice();
      likes = SAMPLE_LIKES.slice();
      draw();
    }
  };

  document.getElementById("btnExport").onclick = () => exportText(true);
  document.getElementById("btnCopy").onclick = async () => {
    exportText(true);
    try {
      await navigator.clipboard.writeText(document.getElementById("out").value);
    } catch (e) {}
  };
  document.getElementById("btnApply").onclick = () => {
    applyExport(document.getElementById("out").value);
    syncControls();
  };
  document.getElementById("btnReset").onclick = () => {
    slots = DEFAULTS.map((s) => ({ ...s }));
    syncControls();
  };

  cv.addEventListener("pointerdown", (e) => {
    const p = canvasToAsset(e);
    if (e.ctrlKey || e.metaKey) {
      for (let idx = 0; idx < 5; idx++) {
        if (hitLikes(idx, p.ax, p.ay)) {
          startLikesDrag(idx, p);
          return;
        }
      }
    }
    if (e.altKey) {
      for (let idx = 0; idx < 5; idx++) {
        if (hitName(idx, p.ax, p.ay)) {
          startNameDrag(idx, p);
          return;
        }
      }
    }
    for (let idx = 0; idx < 5; idx++) {
      if (hitLikes(idx, p.ax, p.ay)) {
        startLikesDrag(idx, p);
        return;
      }
    }
    for (let idx = 0; idx < 5; idx++) {
      if (hitName(idx, p.ax, p.ay)) {
        startNameDrag(idx, p);
        return;
      }
    }
    for (const idx of [...ORDER].reverse()) {
      if (hit(idx, p.ax, p.ay)) {
        selected = idx;
        dragTarget = "photo";
        dragging = true;
        dragOff.x = slots[idx].cx - p.ax;
        dragOff.y = slots[idx].cy - p.ay;
        syncControls();
        return;
      }
    }
  });
  cv.addEventListener("pointermove", (e) => {
    if (!dragging) return;
    const p = canvasToAsset(e);
    const s = slots[selected];
    if (dragTarget === "name") {
      const local = assetToLocal(s, p.ax + dragOff.x, p.ay + dragOff.y);
      const baseY = s.size * 0.5 + s.size * BOTTOM_PAD_RATIO;
      s.nameDx = Math.round(local.x);
      s.nameDy = Math.round(local.y - baseY);
    } else if (dragTarget === "likes") {
      const local = assetToLocal(s, p.ax + dragOff.x, p.ay + dragOff.y);
      const baseX = s.size * 0.5 - s.size * RIGHT_INSET_RATIO;
      const baseY = s.size * 0.5 + s.size * BOTTOM_PAD_RATIO;
      s.likesDx = Math.round(local.x - baseX);
      s.likesDy = Math.round(local.y - baseY);
    } else {
      s.cx = Math.round(p.ax + dragOff.x);
      s.cy = Math.round(p.ay + dragOff.y);
    }
    syncControls();
  });
  window.addEventListener("pointerup", () => {
    dragging = false;
  });
  cv.addEventListener(
    "wheel",
    (e) => {
      e.preventDefault();
      if (e.ctrlKey || e.metaKey || dragTarget === "likes") {
        if (e.shiftKey) {
          slots[selected].likesDy = Math.max(-40, Math.min(40, slots[selected].likesDy + (e.deltaY > 0 ? 1 : -1)));
        } else {
          slots[selected].likesDx = Math.max(-60, Math.min(60, slots[selected].likesDx + (e.deltaY > 0 ? 1 : -1)));
        }
        dragTarget = "likes";
      } else if (e.altKey || dragTarget === "name") {
        if (e.shiftKey) {
          slots[selected].textScale = Math.max(
            0.5,
            Math.min(2, Math.round((slots[selected].textScale + (e.deltaY > 0 ? -0.05 : 0.05)) * 100) / 100)
          );
        } else {
          slots[selected].nameDy = Math.max(-40, Math.min(40, slots[selected].nameDy + (e.deltaY > 0 ? 1 : -1)));
        }
        dragTarget = "name";
      } else if (e.shiftKey) {
        slots[selected].rot = Math.round((slots[selected].rot + (e.deltaY > 0 ? -0.5 : 0.5)) * 10) / 10;
      } else {
        slots[selected].size = Math.max(40, Math.min(240, slots[selected].size + (e.deltaY > 0 ? -1 : 1)));
      }
      syncControls();
    },
    { passive: false }
  );
}

function startNameDrag(idx, p) {
  selected = idx;
  dragTarget = "name";
  dragging = true;
  const a = nameAnchor(slots[idx]);
  dragOff.x = a.x - p.ax;
  dragOff.y = a.y - p.ay;
  syncControls();
}

function startLikesDrag(idx, p) {
  selected = idx;
  dragTarget = "likes";
  dragging = true;
  const a = likesAnchor(slots[idx]);
  dragOff.x = a.x - p.ax;
  dragOff.y = a.y - p.ay;
  syncControls();
}

function canvasToAsset(e) {
  const r = cv.getBoundingClientRect();
  const x = (e.clientX - r.left) * (cv.width / r.width);
  const y = (e.clientY - r.top) * (cv.height / r.height);
  const L = stageLayout();
  return { x, y, ax: (x - L.x) / L.scale, ay: (y - L.y) / L.scale };
}

function assetToLocal(s, ax, ay) {
  const rad = (-s.rot * Math.PI) / 180;
  const dx = ax - s.cx;
  const dy = ay - s.cy;
  return {
    x: dx * Math.cos(rad) - dy * Math.sin(rad),
    y: dx * Math.sin(rad) + dy * Math.cos(rad),
  };
}

function hit(idx, ax, ay) {
  const s = slots[idx];
  const local = assetToLocal(s, ax, ay);
  const h = s.size * 0.5;
  return Math.abs(local.x) <= h && Math.abs(local.y) <= h;
}

function hitName(idx, ax, ay) {
  const a = nameAnchor(slots[idx]);
  return Math.abs(ax - a.x) < 55 && Math.abs(ay - a.y) < 22;
}

function hitLikes(idx, ax, ay) {
  const a = likesAnchor(slots[idx]);
  return ax <= a.x + 8 && ax >= a.x - 40 && Math.abs(ay - a.y) < 18;
}

function exportText(select) {
  const lines = [
    "POLAROID_SLOTS_V2",
    "ASSET=" + ASSET_W + "x" + ASSET_H,
    "SCALE=" + VIEW_SCALE,
    "ORDER=" + ORDER.join(","),
    "TEXT_SIZE_RATIO=" + TEXT_SIZE_RATIO,
    "BOTTOM_PAD_RATIO=" + BOTTOM_PAD_RATIO,
  ];
  slots.forEach((s, i) => {
    lines.push(
      "SLOT " +
        i +
        ": cx=" +
        s.cx +
        " cy=" +
        s.cy +
        " rot=" +
        s.rot +
        " size=" +
        s.size +
        " nameDx=" +
        s.nameDx +
        " nameDy=" +
        s.nameDy +
        " likesDx=" +
        s.likesDx +
        " likesDy=" +
        s.likesDy +
        " textScale=" +
        s.textScale
    );
  });
  const t = lines.join("\n");
  const out = document.getElementById("out");
  out.value = t;
  if (select) out.select();
}

function applyExport(text) {
  const lines = String(text || "").split(/\r?\n/);
  for (const line of lines) {
    const m = line.match(
      /^SLOT\s+(\d+)\s*:\s*cx=([-\d.]+)\s+cy=([-\d.]+)\s+rot=([-\d.]+)\s+size=([-\d.]+)(?:\s+nameDx=([-\d.]+)\s+nameDy=([-\d.]+))?(?:\s+likesDx=([-\d.]+)\s+likesDy=([-\d.]+))?(?:\s+textScale=([-\d.]+))?/i
    );
    if (!m) continue;
    const i = +m[1];
    if (i < 0 || i > 4) continue;
    const cur = slots[i] || { ...DEFAULTS[i] };
    slots[i] = {
      cx: +m[2],
      cy: +m[3],
      rot: +m[4],
      size: +m[5],
      nameDx: m[6] != null ? +m[6] : cur.nameDx || 0,
      nameDy: m[7] != null ? +m[7] : cur.nameDy || 0,
      likesDx: m[8] != null ? +m[8] : cur.likesDx || 0,
      likesDy: m[9] != null ? +m[9] : cur.likesDy || 0,
      textScale: m[10] != null ? +m[10] : cur.textScale || 1,
    };
  }
}

async function loadPhotos() {
  try {
    const res = await fetch("https://www.habbo.com.br/extradata/public/photos");
    const data = await res.json();
    const picks = data.sort(() => Math.random() - 0.5).slice(0, 5);
    authors = picks.map((p) => p.creator_name || "Habbo");
    likes = picks.map((p) => (Array.isArray(p.likes) ? p.likes.length : p.likes != null ? +p.likes : -1));
    photos = await Promise.all(
      picks.map(async (p) => {
        let url = p.previewUrl || p.url || "";
        if (url.startsWith("//")) url = "https:" + url;
        try {
          const img = new Image();
          img.crossOrigin = "anonymous";
          await new Promise((ok, err) => {
            img.onload = ok;
            img.onerror = err;
            img.src = url;
          });
          return img;
        } catch (e) {
          return null;
        }
      })
    );
  } catch (e) {
    photos = [];
    authors = SAMPLE_NAMES.slice();
    likes = SAMPLE_LIKES.slice();
  }
  draw();
}

function boot(dataUri) {
  document.fonts.load('12px "Volter Bold"').finally(() => {
    overlay.onload = () => {
      bind();
      syncControls();
      if (document.getElementById("usePhotos").checked) loadPhotos();
    };
    overlay.src = dataUri;
    if (overlay.complete) overlay.onload();
  });
}

if (window.POLAROID_OVERLAY_DATA_URI) {
  boot(window.POLAROID_OVERLAY_DATA_URI);
} else {
  boot("../brand-pack/splash_pictures_no_pixel.png");
}

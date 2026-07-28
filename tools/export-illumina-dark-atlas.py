"""Slice habbo_skin_illumina_dark atlas into categorized folders with usage notes."""
from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(r"D:\projetos\habbo\HabboAirBobba")
SRC = ROOT / r"cleanswf\scripts\_assets\2332_habbo_skin_illumina_dark_1_png.png"
OUT = ROOT / r"client-assets\illumina-dark-atlas"
SCALE = 8


def crop(img: Image.Image, box: tuple[int, int, int, int], path: Path) -> None:
    x, y, w, h = box
    piece = img.crop((x, y, x + w, y + h))
    path.parent.mkdir(parents=True, exist_ok=True)
    piece.save(path)
    preview = piece.resize((w * SCALE, h * SCALE), Image.NEAREST)
    preview.save(path.with_name(f"{path.stem}_x{SCALE}.png"))


def main() -> None:
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)

    img = Image.open(SRC).convert("RGBA")
    (OUT / "_source.png").write_bytes(SRC.read_bytes())

    categories = {
        "01_frame": {
            "used_by": [
                "Window frames when Illumina Dark theme is active (style 200)",
                "Skin: illumina_dark_skin_frame (2812_illumina_dark_skin_frame_1_xml.bin)",
                "Element: type=frame style=200 -> illumina_dark_skin_frame_xml",
                "Layout wrapper: illumina_dark_frame_1_xml",
            ],
            "atlas_block": (0, 0, 28, 30),
            "pieces": {
                "top_left": (0, 0, 4, 4),
                "top_center": (4, 0, 20, 4),
                "top_right": (24, 0, 4, 4),
                "center_left": (0, 4, 4, 21),
                "center_center": (4, 4, 20, 21),
                "center_right": (24, 4, 4, 21),
                "bottom_left": (0, 25, 4, 5),
                "bottom_center": (4, 25, 20, 5),
                "bottom_right": (24, 25, 4, 5),
            },
        },
        "02_button": {
            "used_by": [
                "Buttons / container_buttons when Illumina Dark theme is active (style 200)",
                "Skin: illumina_dark_skin_button (1816_illumina_dark_skin_button_1_xml.bin)",
                "Element: type=button|container_button style=200 -> illumina_dark_skin_button_xml",
                "Layout wrapper: illumina_dark_button_1_xml",
            ],
            "atlas_block": (33, 0, 28, 29),
            "pieces": {
                "top_left": (33, 0, 4, 4),
                "top_center": (37, 0, 20, 4),
                "top_right": (57, 0, 4, 4),
                "center_left": (33, 4, 4, 20),
                "center_center": (37, 4, 20, 20),
                "center_right": (57, 4, 4, 20),
                "bottom_left": (33, 24, 4, 5),
                "bottom_center": (37, 24, 20, 5),
                "bottom_right": (57, 24, 4, 5),
            },
        },
        "03_border_and_header": {
            "used_by": [
                "Borders AND title headers share the SAME atlas region",
                "Skin border: illumina_dark_skin_border (2733_illumina_dark_skin_border_1_xml.bin)",
                "Skin header: illumina_dark_skin_header (2074_illumina_dark_skin_header_1_xml.bin)",
                "Element: type=border style=200 -> illumina_dark_skin_border_xml",
                "Element: type=header style=200 -> illumina_dark_skin_header_xml",
                "Also used by IlluminaBorderWidget when border_style=illumina_dark",
            ],
            "atlas_block": (68, 0, 38, 30),
            "pieces": {
                "top_left": (68, 0, 3, 3),
                "top_center": (71, 0, 32, 3),
                "top_right": (103, 0, 3, 3),
                "center_left": (68, 3, 3, 24),
                "center_center": (71, 3, 32, 24),
                "center_right": (103, 3, 3, 24),
                "bottom_left": (68, 27, 3, 3),
                "bottom_center": (71, 27, 32, 3),
                "bottom_right": (103, 27, 3, 3),
            },
        },
    }

    extras = {
        "04_extra_unreferenced": {
            "used_by": [
                "Present in habbo_skin_illumina_dark atlas but NOT referenced by current dark skin XMLs",
                "Likely leftover button states (hover/pressed) never wired up",
                "Skin XMLs only use the first button block at (33,0)",
            ],
            "blocks": {
                "button_block_y34": (33, 34, 28, 29),
                "button_block_y68": (33, 68, 28, 29),
                "button_block_y102": (33, 102, 28, 29),
            },
        },
    }

    index: list[dict] = []

    for folder, meta in categories.items():
        d = OUT / folder
        d.mkdir(parents=True, exist_ok=True)
        crop(img, meta["atlas_block"], d / "_full_block.png")
        for name, box in meta["pieces"].items():
            crop(img, box, d / f"{name}.png")
        (d / "USAGE.txt").write_text("\n".join(meta["used_by"]) + "\n", encoding="utf-8")
        index.append(
            {
                "folder": folder,
                "used_by": meta["used_by"],
                "atlas_block": meta["atlas_block"],
                "pieces": meta["pieces"],
            }
        )

    for folder, meta in extras.items():
        d = OUT / folder
        d.mkdir(parents=True, exist_ok=True)
        for name, box in meta["blocks"].items():
            crop(img, box, d / f"{name}.png")
        (d / "USAGE.txt").write_text("\n".join(meta["used_by"]) + "\n", encoding="utf-8")
        index.append(
            {
                "folder": folder,
                "used_by": meta["used_by"],
                "blocks": meta["blocks"],
            }
        )

    pad = 40
    canvas = Image.new("RGBA", (img.width + 20, img.height + pad + 80), (20, 20, 20, 255))
    canvas.paste(img, (10, pad))
    draw = ImageDraw.Draw(canvas)
    colors = {
        "01_frame": (0, 200, 255, 255),
        "02_button": (255, 180, 0, 255),
        "03_border_and_header": (120, 255, 120, 255),
        "04_extra_unreferenced": (255, 80, 80, 255),
    }
    for folder, meta in categories.items():
        x, y, w, h = meta["atlas_block"]
        draw.rectangle([10 + x, pad + y, 10 + x + w - 1, pad + y + h - 1], outline=colors[folder], width=1)
        draw.text((10 + x, max(0, pad + y - 12)), folder[3:], fill=colors[folder])
    for folder, meta in extras.items():
        for _name, (x, y, w, h) in meta["blocks"].items():
            draw.rectangle([10 + x, pad + y, 10 + x + w - 1, pad + y + h - 1], outline=colors[folder], width=1)
    draw.text(
        (10, pad + img.height + 8),
        "cyan=frame  orange=button  green=border/header  red=unreferenced extras",
        fill=(200, 200, 200, 255),
    )
    canvas.save(OUT / "_atlas_annotated.png")
    canvas.resize((canvas.width * 3, canvas.height * 3), Image.NEAREST).save(OUT / "_atlas_annotated_x3.png")

    (OUT / "index.json").write_text(json.dumps(index, indent=2), encoding="utf-8")
    # Docs live in repo-root README.md (Illumina Dark atlas section)

    for p in sorted(OUT.rglob("*")):
        if p.is_file() and f"_x{SCALE}" not in p.name:
            print(p.relative_to(OUT).as_posix())
    print(f"Done -> {OUT}")


if __name__ == "__main__":
    main()

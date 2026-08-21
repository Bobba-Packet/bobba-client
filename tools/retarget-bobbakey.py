"""Retarget BobbaKey.swf from Metakey/fx.212 to BobbaKey/fx.9001 via FFDec XML."""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SWF_IN = ROOT / "client-assets" / "local_include" / "BobbaKey.swf"
SWF_OUT = ROOT / "client-assets" / "local_include" / "BobbaKey.swf"
TMP = Path.home() / "AppData" / "Local" / "Temp"


def ffdec_cli() -> Path:
    for c in (
        ROOT / "ffdec" / "ffdec-cli.exe",
        ROOT.parent / "traxmachine" / "ffdec" / "ffdec-cli.exe",
    ):
        if c.is_file():
            return c
    raise SystemExit("ffdec-cli not found")


def patch_hex(match: re.Match[str]) -> str:
    raw = bytes.fromhex(match.group(1))
    try:
        s = raw.decode("utf-8")
    except UnicodeDecodeError:
        return match.group(0)
    s = s.replace("fx.212", "fx.9001").replace("fx212", "fx9001")
    s = s.replace('id="Metakey"', 'id="BobbaKey"').replace('desc="Metakey"', 'desc="BobbaKey"')
    return 'binaryData="' + s.encode("utf-8").hex() + '"'


def retarget_xml(text: str) -> str:
    text = re.sub(r'binaryData="([0-9a-fA-F]+)"', patch_hex, text)
    text = text.replace("fx212", "fx9001")
    text = text.replace("Metakey_h_std", "BobbaKey_h_std")
    text = text.replace("Metakey_manifest", "BobbaKey_manifest")
    text = text.replace("Metakey_animation", "BobbaKey_animation")
    text = text.replace('name="Metakey"', 'name="BobbaKey"')
    text = text.replace("<item>Metakey</item>", "<item>BobbaKey</item>")
    return text


def main() -> int:
    cli = ffdec_cli()
    src_xml = TMP / "bobbakey.xml"
    dst_xml = TMP / "bobbakey-retarget.xml"
    tmp_swf = TMP / "BobbaKey-retarget.swf"
    if not src_xml.is_file():
        subprocess.check_call([str(cli), "-swf2xml", str(SWF_IN), str(src_xml)])
    text = retarget_xml(src_xml.read_text(encoding="utf-8"))
    dst_xml.write_text(text, encoding="utf-8")
    leftover = len(re.findall(r"Metakey(?!_)", text))
    print("wrote", dst_xml, "bytes", dst_xml.stat().st_size)
    print("BobbaKey count", text.count("BobbaKey"))
    print("fx9001 count", text.count("fx9001"))
    print("leftover Metakey", leftover)
    print("leftover fx212", text.count("fx212"))
    subprocess.check_call([str(cli), "-xml2swf", str(dst_xml), str(tmp_swf)])
    SWF_OUT.write_bytes(tmp_swf.read_bytes())
    print("wrote", SWF_OUT, "bytes", SWF_OUT.stat().st_size)
    return 0


if __name__ == "__main__":
    sys.exit(main())

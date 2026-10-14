"""Renders docs/progression.json (exported from the game's real data) as docs/progression.svg.

    godot --headless --path godot --script tools/export_graph.gd
    python tools/make_graph.py

One swimlane per era. Nodes are actions; an arrow A -> B means "B needs something A gives you".
Dashed arrows: "this place only appears after...". Cyan dotted: do the source action N times first (xN). Orange tags: needs something from an earlier era.
"""
import json
import os
import textwrap
from html import escape

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
data = json.load(open(os.path.join(ROOT, "docs", "progression.json"), encoding="utf-8"))
NOTES = data["notes"]

NW, NH = 192, 56          # node size
DX, DY = 46, 14           # gaps
LANE_PAD_TOP, LANE_PAD_BOT = 40, 22
LEFT = 40
LANE_GAP = 26

# ------------------------------------------------------------------ build graph
nodes = []
giver = {}
for ei, era in enumerate(data["eras"]):
    for hi, h in enumerate(era["hotspots"]):
        for a in h["acts"]:
            n = dict(a)
            n.update(era=ei, hot=h["name"], show=h["show"] if a is h["acts"][0] else [], idx=len(nodes))
            nodes.append(n)
            for g in a["give"]:
                giver.setdefault(g, []).append(n["idx"])

# flags that follow automatically (the brass key comes with the last of three notes)
for rule in data.get("auto", []):
    for w in rule.get("when", []):
        for i in list(giver.get(w, [])):
            giver.setdefault(rule["give"], []).append(i)
    for c in rule.get("counts", []):
        for n in nodes:
            if n["id"] == c[0]:
                giver.setdefault(rule["give"], []).append(n["idx"])

edges = []  # (src, dst, flag, kind)
for n in nodes:
    seen = set()
    for f in n["req"]:
        for s in giver.get(f, []):
            if (s, f) not in seen:
                edges.append((s, n["idx"], f, "req"))
                seen.add((s, f))
    for f in n["show"]:
        for s in giver.get(f, []):
            if (s, f) not in seen:
                edges.append((s, n["idx"], f, "show"))
                seen.add((s, f))

# "do this N times first" links
by_id = {n["id"]: n for n in nodes}
for n in nodes:
    for need in n.get("needs", []):
        src = by_id.get(need[0])
        if src is not None:
            edges.append((src["idx"], n["idx"], "x%d" % int(need[1]), "needs"))

# relative depth inside each era (cross-era edges ignored for layout)
depth = {}


def get_depth(i):
    if i in depth:
        return depth[i]
    depth[i] = 0
    d = 0
    for s, t, f, k in edges:
        if t == i and nodes[s]["era"] == nodes[i]["era"]:
            d = max(d, get_depth(s) + 1)
    depth[i] = d
    return d


for n in nodes:
    get_depth(n["idx"])

# ----------------------------------------------------------------------- layout
cells = {}
for n in nodes:
    cells.setdefault((n["era"], depth[n["idx"]]), []).append(n["idx"])

lane_rows = []
for ei in range(len(data["eras"])):
    rows = max([len(v) for (e, d), v in cells.items() if e == ei] or [1])
    lane_rows.append(rows)

lane_y = []
y = 90
for ei in range(len(data["eras"])):
    lane_y.append(y)
    y += LANE_PAD_TOP + lane_rows[ei] * (NH + DY) + LANE_PAD_BOT + LANE_GAP
H = y + 40

pos = {}
max_d = 0
for (ei, d), idxs in cells.items():
    max_d = max(max_d, d)
    lane_h = lane_rows[ei] * (NH + DY)
    block = len(idxs) * (NH + DY)
    y0 = lane_y[ei] + LANE_PAD_TOP + (lane_h - block) / 2.0
    for r, i in enumerate(idxs):
        pos[i] = (LEFT + d * (NW + DX), y0 + r * (NH + DY))
W = LEFT * 2 + (max_d + 1) * (NW + DX)

# ---------------------------------------------------------------------- styling
BG = "#0b0d1a"
LANE = ["#12162b", "#0f1325"]
C_SEARCH = ("#3a2e12", "#ffcd75")
C_ONCE = ("#241c3c", "#c8a0ff")
C_REPEAT = ("#102a3a", "#73eff7")
C_EXIT = ("#12321f", "#7aef98")
TXT = "#e8e6dc"
DIM = "#8a93b0"


def style(n):
    if n["exit"]:
        return C_EXIT
    if n["search"]:
        return C_SEARCH
    if n["once"]:
        return C_ONCE
    return C_REPEAT


def fmt_years(y):
    if y == 0:
        return ""
    if y < 1.0 / 365.25 * 1.5:
        h = y * 365.25 * 24
        return "%d min" % round(h * 60) if h < 1 else "%d h" % round(h)
    if y < 1:
        return "%d days" % round(y * 365.25)
    if y < 1000:
        return "%g y" % y
    if y < 1e6:
        return "{:,.0f} y".format(y)
    if y < 1e9:
        return "%g My" % (y / 1e6)
    if y < 1e12:
        return "%g Gy" % (y / 1e9)
    return "10^%d y" % round(__import__("math").log10(y))


out = []
out.append('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" font-family="Segoe UI, Arial, sans-serif">' % (W, H, W, H))
out.append('<defs>'
           '<marker id="ar" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#7a86b8"/></marker>'
           '<marker id="ao" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#ff9a4a"/></marker>'
           '</defs>')
out.append('<rect width="%d" height="%d" fill="%s"/>' % (W, H, BG))
out.append('<text x="%d" y="38" fill="%s" font-size="26" font-weight="600">Passing Time - progression graph</text>' % (LEFT, TXT))
n_search = sum(1 for n in nodes if n["search"])
n_flags = len(giver)
out.append('<text x="%d" y="60" fill="%s" font-size="13">%d actions · %d discoveries · %d eras. An arrow A → B means B needs something A gives you. '
           'Dashed: a place that only appears after. Orange tags: needs something found in an earlier era (the number is that era).</text>' % (LEFT, DIM, len(nodes), n_flags, len(data["eras"])))
# legend
lx = W - 640
for i, (label, col) in enumerate([("search / find something", C_SEARCH), ("one-time discovery", C_ONCE), ("repeatable time-lapse", C_REPEAT), ("era exit", C_EXIT)]):
    out.append('<rect x="%d" y="22" width="14" height="14" rx="3" fill="%s" stroke="%s"/>' % (lx + i * 160, col[0], col[1]))
    out.append('<text x="%d" y="34" fill="%s" font-size="12">%s</text>' % (lx + i * 160 + 20, DIM, label))

# lanes
for ei, era in enumerate(data["eras"]):
    top = lane_y[ei]
    hh = LANE_PAD_TOP + lane_rows[ei] * (NH + DY) + LANE_PAD_BOT
    out.append('<rect x="14" y="%d" width="%d" height="%d" rx="10" fill="%s"/>' % (top, W - 28, hh, LANE[ei % 2]))
    out.append('<text x="%d" y="%d" fill="#ffcd75" font-size="15" font-weight="600">%d · %s</text>' % (LEFT, top + 24, ei + 1, escape(era["name"].upper())))

# edges first (under nodes)
chips = {}
for s, t, f, kind in edges:
    sx, sy = pos[s]
    tx, ty = pos[t]
    cross = nodes[s]["era"] != nodes[t]["era"]
    title = "%s: %s" % (f, NOTES.get(f, ""))
    if cross:
        chips.setdefault(t, []).append("← %s (%d)" % (nodes[s]["name"], nodes[s]["era"] + 1))
        continue
    else:
        x1, y1 = sx + NW, sy + NH / 2
        x2, y2 = tx, ty + NH / 2
        dx = max(30, (x2 - x1) / 2)
        d = "M%.1f,%.1f C%.1f,%.1f %.1f,%.1f %.1f,%.1f" % (x1, y1, x1 + dx, y1, x2 - dx, y2, x2, y2)
        dash = ' stroke-dasharray="4 4"' if kind == "show" else ""
        col = "#7a86b8"
        if kind == "needs":
            col = "#73eff7"
            dash = ' stroke-dasharray="2 3"'
        out.append('<path d="%s" fill="none" stroke="%s" stroke-width="1.4" stroke-opacity="0.8"%s marker-end="url(#ar)"><title>%s</title></path>' % (d, col, dash, escape(title)))

# nodes
for n in nodes:
    x, y = pos[n["idx"]]
    fill, stroke = style(n)
    out.append('<g><title>%s</title>' % escape("%s - %s%s" % (n["hot"], n["name"], (" · gives: " + ", ".join(n["give"])) if n["give"] else "")))
    out.append('<rect x="%.1f" y="%.1f" width="%d" height="%d" rx="7" fill="%s" stroke="%s" stroke-width="1.5"/>' % (x, y, NW, NH, fill, stroke))
    name = n["name"] if n["name"] else "?"
    lines = textwrap.wrap(name, 29)[:2]
    for i, l in enumerate(lines):
        out.append('<text x="%.1f" y="%.1f" fill="%s" font-size="12" font-weight="600">%s</text>' % (x + 8, y + 17 + i * 14, TXT, escape(l)))
    sub = n["hot"]
    d = fmt_years(n["years"])
    if d:
        sub += " · " + d
    out.append('<text x="%.1f" y="%.1f" fill="%s" font-size="10.5">%s</text>' % (x + 8, y + NH - 6, DIM, escape(sub)))
    if n["give"]:
        out.append('<circle cx="%.1f" cy="%.1f" r="4" fill="%s"/>' % (x + NW - 8, y + NH - 9, stroke))
    for ci, chip in enumerate(chips.get(n["idx"], [])[:3]):
        label = chip if len(chip) <= 34 else chip[:33] + "…"
        out.append('<text x="%.1f" y="%.1f" fill="#ff9a4a" font-size="9.5">%s</text>' % (x + 2, y - 5 - ci * 11, escape(label)))
    out.append('</g>')
out.append('</svg>')

path = os.path.join(ROOT, "docs", "progression.svg")
open(path, "w", encoding="utf-8").write("\n".join(out))
print("wrote", path, "(%dx%d)" % (W, H), len(nodes), "actions,", len(edges), "links")

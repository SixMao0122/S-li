"""
Generate a 100% native vector SVG showcasing S-li themes and separator styles.
Zero foreignObject dependencies, guaranteed 100% renderability on GitHub.
"""

import os

SVG_PATH = os.path.join(os.path.dirname(__file__), "..", "docs", "images", "themes-showcase.svg")

# Data for 8 showcase rows
ROWS = [
    {
        "label": "Sunset • Arrow",
        "style": "arrow",
        "sep_w": 14,
        "segments": [
            {"text": "SxiMao", "bg": "#7b2cbf", "fg": "#ffffff"},
            {"text": "S-li", "bg": "#d94676", "fg": "#ffffff"},
            {"text": "→ (main)", "bg": "#f08a5d", "fg": "#ffffff"},
            {"text": "♡ 15:05", "bg": "#4385be", "fg": "#ffffff"},
        ]
    },
    {
        "label": "Cyberpunk • Flame",
        "style": "flame",
        "sep_w": 15,
        "segments": [
            {"text": "SxiMao", "bg": "#00f5d4", "fg": "#0b090a"},
            {"text": "S-li", "bg": "#7b2cbf", "fg": "#ffffff"},
            {"text": "* 🔥 master", "bg": "#f72585", "fg": "#ffffff"},
            {"text": "⚡ 15:06", "bg": "#fee440", "fg": "#0b090a"},
        ]
    },
    {
        "label": "Tokyo • Slanted",
        "style": "slanted",
        "sep_w": 14,
        "segments": [
            {"text": "SxiMao", "bg": "#3d59a1", "fg": "#ffffff"},
            {"text": "🐍 (venv) S-li", "bg": "#7aa2f7", "fg": "#1a1b26"},
            {"text": " (dev)", "bg": "#bb9af7", "fg": "#1a1b26"},
            {"text": "🌙 15:07", "bg": "#2ac3de", "fg": "#1a1b26"},
        ]
    },
    {
        "label": "Nord • Rounded",
        "style": "rounded",
        "sep_w": 14,
        "segments": [
            {"text": "SxiMao", "bg": "#5e81ac", "fg": "#ffffff"},
            {"text": "S-li", "bg": "#81a1c1", "fg": "#2e3440"},
            {"text": "→ (release)", "bg": "#88c0d0", "fg": "#2e3440"},
            {"text": "❄ 15:08", "bg": "#8fbcbb", "fg": "#2e3440"},
        ]
    },
    {
        "label": "Sakura • Wave",
        "style": "wave",
        "sep_w": 14,
        "segments": [
            {"text": "SxiMao", "bg": "#ff758f", "fg": "#ffffff"},
            {"text": "S-li", "bg": "#ff4d6d", "fg": "#ffffff"},
            {"text": "🌸 (main)", "bg": "#c9184a", "fg": "#ffffff"},
            {"text": "♡ 15:09", "bg": "#a4133c", "fg": "#ffffff"},
        ]
    },
    {
        "label": "Dracula • Slant Down",
        "style": "slant_down",
        "sep_w": 14,
        "segments": [
            {"text": "SxiMao", "bg": "#6272a4", "fg": "#ffffff"},
            {"text": "S-li", "bg": "#bd93f9", "fg": "#282a36"},
            {"text": "*  (hotfix)", "bg": "#ff79c6", "fg": "#282a36"},
            {"text": "💀 15:10", "bg": "#50fa7b", "fg": "#282a36"},
        ]
    },
    {
        "label": "Matrix • Pixel",
        "style": "pixel",
        "sep_w": 14,
        "segments": [
            {"text": "SxiMao", "bg": "#003b00", "fg": "#00ff41"},
            {"text": "S-li", "bg": "#005f00", "fg": "#00ff41"},
            {"text": "💻 (main)", "bg": "#008f11", "fg": "#000000"},
            {"text": "⚡ 15:11", "bg": "#00ff41", "fg": "#000000"},
        ]
    },
    {
        "label": "Minimalist • Flat",
        "style": "flat",
        "sep_w": 0,
        "segments": [
            {"text": "SxiMao", "bg": "#24292e", "fg": "#ffffff"},
            {"text": "S-li", "bg": "#0366d6", "fg": "#ffffff"},
            {"text": "→ (main)", "bg": "#28a745", "fg": "#ffffff"},
            {"text": "✨ 15:12", "bg": "#6f42c1", "fg": "#ffffff"},
        ]
    }
]

def make_sep_path(style, x, y, h, w):
    if style == "arrow":
        return f'<polygon points="{x},{y} {x+w},{y+h/2} {x},{y+h}" />'
    elif style == "rounded":
        r = h / 2
        return f'<path d="M {x} {y} A {r} {r} 0 0 1 {x} {y+h} Z" />'
    elif style == "slanted":
        return f'<polygon points="{x},{y} {x+w},{y+h} {x},{y+h}" />'
    elif style == "slant_down":
        return f'<polygon points="{x},{y} {x+w},{y} {x},{y+h}" />'
    elif style == "flame":
        return (f'<path d="M {x} {y} '
                f'Q {x+w*0.6} {y+h*0.25} {x+w} {y+h*0.35} '
                f'Q {x+w*0.4} {y+h*0.65} {x+w} {y+h*0.75} '
                f'Q {x+w*0.5} {y+h*0.9} {x} {y+h} Z" />')
    elif style == "pixel":
        # 3-step pixel stair
        s1 = h * 0.33
        s2 = h * 0.66
        w1 = w * 0.35
        w2 = w * 0.7
        return (f'<path d="M {x} {y} H {x+w1} V {y+s1} H {x+w2} V {y+s2} '
                f'H {x+w} V {y+h} H {x} Z" />')
    elif style == "wave":
        return (f'<path d="M {x} {y} '
                f'C {x+w*0.9} {y+h*0.2} {x+w*0.2} {y+h*0.8} {x+w} {y+h} '
                f'L {x} {y+h} Z" />')
    elif style == "flat":
        return ""
    return ""

def approx_text_width(text):
    # Monospace estimate: roughly 8.5px per standard ASCII char, 14px for emoji/cjk
    w = 0
    for ch in text:
        if ord(ch) > 127:
            w += 14.5
        else:
            w += 8.2
    return int(w) + 18  # plus internal padding

def build_svg():
    width = 900
    height = 620
    seg_height = 28
    start_y = 66
    row_gap = 65

    lines = []
    lines.append('<?xml version="1.0" encoding="UTF-8"?>')
    lines.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">')
    
    # Styles
    lines.append("""  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#141721" />
      <stop offset="100%" stop-color="#0e1017" />
    </linearGradient>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="16" stdDeviation="24" flood-color="#000000" flood-opacity="0.5" />
    </filter>
  </defs>""")

    # Background window
    lines.append(f'  <!-- Terminal Window Background -->')
    lines.append(f'  <rect x="10" y="10" width="{width-20}" height="{height-20}" rx="14" fill="url(#bgGrad)" stroke="#232736" stroke-width="1.5" filter="url(#shadow)" />')

    # Window header
    lines.append(f'  <!-- Header Bar -->')
    lines.append(f'  <circle cx="36" cy="30" r="5.5" fill="#ff5f56" />')
    lines.append(f'  <circle cx="54" cy="30" r="5.5" fill="#ffbd2e" />')
    lines.append(f'  <circle cx="72" cy="30" r="5.5" fill="#27c93f" />')
    lines.append(f'  <text x="{width/2}" y="34" font-family="-apple-system, BlinkMacSystemFont, \'Segoe UI\', Ubuntu, sans-serif" font-size="12" font-weight="600" fill="#69728a" text-anchor="middle">S-li — Multi-Theme &amp; Separator Styles Showcase</text>')
    lines.append(f'  <line x1="10" y1="48" x2="{width-10}" y2="48" stroke="#1d212e" stroke-width="1" />')

    # Rows
    for i, row in enumerate(ROWS):
        y = start_y + (i * row_gap)
        style = row["style"]
        sep_w = row["sep_w"]
        
        # Label on left
        label_text = row["label"]
        lines.append(f'  <!-- Row {i+1}: {label_text} -->')
        lines.append(f'  <g transform="translate(0, {y})">')
        lines.append(f'    <text x="32" y="18" font-family="\'JetBrains Mono\', \'Cascadia Code\', monospace" font-size="11.5" font-weight="700" fill="#75809c" letter-spacing="0.5">{label_text}</text>')
        
        # Prompt segments starting at x = 185
        curr_x = 195
        segs = row["segments"]
        
        # Draw background base rectangles and texts
        for s_idx, seg in enumerate(segs):
            tw = approx_text_width(seg["text"])
            
            # Draw segment rectangle
            lines.append(f'    <rect x="{curr_x}" y="0" width="{tw}" height="{seg_height}" fill="{seg["bg"]}" />')
            
            # Draw segment text
            text_x = curr_x + (tw / 2)
            lines.append(f'    <text x="{text_x}" y="18" font-family="\'JetBrains Mono\', \'Cascadia Code\', monospace" font-size="12.5" font-weight="600" fill="{seg["fg"]}" text-anchor="middle">{seg["text"]}</text>')
            
            # Next segment or closing
            if s_idx < len(segs) - 1:
                next_bg = segs[s_idx + 1]["bg"]
                if sep_w > 0:
                    # Draw underlying rect with next segment bg so arrow has contrasting background
                    lines.append(f'    <rect x="{curr_x + tw}" y="0" width="{sep_w}" height="{seg_height}" fill="{next_bg}" />')
                    # Draw separator glyph in current segment bg
                    sep_svg = make_sep_path(style, curr_x + tw, 0, seg_height, sep_w)
                    if sep_svg:
                        lines.append(f'    <g fill="{seg["bg"]}">{sep_svg}</g>')
                curr_x += tw + sep_w
            else:
                # Closing separator
                if sep_w > 0:
                    sep_svg = make_sep_path(style, curr_x + tw, 0, seg_height, sep_w)
                    if sep_svg:
                        lines.append(f'    <g fill="{seg["bg"]}">{sep_svg}</g>')
                    curr_x += tw + sep_w
                else:
                    curr_x += tw
        
        # Prompt command simulation cursor
        lines.append(f'    <rect x="{curr_x + 8}" y="5" width="7" height="18" fill="#ffffff" opacity="0.85" rx="1" />')
        lines.append(f'  </g>')

    lines.append('</svg>')
    
    content = "\n".join(lines)
    with open(SVG_PATH, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"SVG written successfully to {SVG_PATH}")

if __name__ == "__main__":
    build_svg()

"""
Render a pixel-perfect, ultra-high-definition (2x Retina) terminal screenshot preview.png.
Features realistic macOS/Windows Terminal styling, ambient drop shadows, S-li Powerline pills,
real-time git statuses, python venv badges, flame/arrow separators, and interactive command sessions.
"""

import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "..", "docs", "images", "preview.png")

# Palette constants
CANVAS_W = 1600
CANVAS_H = 1000

WIN_X1 = 100
WIN_Y1 = 80
WIN_X2 = 1500
WIN_Y2 = 920
WIN_R = 18

HEADER_H = 48
BG_TERMINAL = (18, 20, 29)
BG_HEADER = (25, 28, 40)
BORDER_COLOR = (45, 50, 70)

# Colors
C_WHITE = (248, 248, 242)
C_GRAY = (140, 148, 168)
C_DARKGRAY = (85, 95, 115)
C_GREEN = (80, 250, 123)
C_CYAN = (139, 233, 253)
C_YELLOW = (241, 250, 140)
C_ORANGE = (255, 184, 108)

# Load fonts
FONT_BOLD_24 = ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 24)
FONT_REG_24 = ImageFont.truetype("C:/Windows/Fonts/consola.ttf", 24)
FONT_BOLD_20 = ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 20)
FONT_REG_20 = ImageFont.truetype("C:/Windows/Fonts/consola.ttf", 20)
FONT_TITLE = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 17)

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

def draw_separator(draw, style, x, y, h, w, bg_color):
    """Draw smooth vector separator connecting segments."""
    if style == "arrow":
        # Classic Powerline right arrow
        pts = [(x, y), (x + w, y + h / 2), (x, y + h)]
        draw.polygon(pts, fill=bg_color)
    elif style == "rounded":
        # Rounded pill capsule cap
        # Use polygon with arc interpolation
        pts = []
        r = h / 2
        cy = y + r
        for angle in range(-90, 91, 10):
            rad = math.radians(angle)
            px = x + r * math.cos(rad) * (w / r)
            py = cy + r * math.sin(rad)
            pts.append((px, py))
        pts.append((x, y + h))
        pts.append((x, y))
        draw.polygon(pts, fill=bg_color)
    elif style == "flame":
        # Flame curves approximated with polygon points
        pts = [
            (x, y),
            (x + w * 0.5, y + h * 0.2),
            (x + w, y + h * 0.35),
            (x + w * 0.45, y + h * 0.65),
            (x + w, y + h * 0.75),
            (x + w * 0.4, y + h * 0.9),
            (x, y + h)
        ]
        draw.polygon(pts, fill=bg_color)
    elif style == "slanted":
        pts = [(x, y), (x + w, y + h), (x, y + h)]
        draw.polygon(pts, fill=bg_color)

def draw_pill_prompt(draw, x, y, segs, style="arrow", sep_w=18, seg_h=38, font=FONT_BOLD_20):
    """Draw a complete S-li prompt with interconnected colored pills and separators."""
    curr_x = x
    
    for i, seg in enumerate(segs):
        text = seg["text"]
        bg = hex_to_rgb(seg["bg"])
        fg = hex_to_rgb(seg["fg"])
        
        # Measure text width
        bbox = draw.textbbox((0, 0), text, font=font)
        tw = bbox[2] - bbox[0] + 28  # internal padding
        
        # Draw segment rectangle
        draw.rectangle([curr_x, y, curr_x + tw, y + seg_h], fill=bg)
        
        # Draw text centered vertically
        ty = y + (seg_h - (bbox[3] - bbox[1])) / 2 - 3
        draw.text((curr_x + 14, ty), text, fill=fg, font=font)
        
        # Draw separator
        if i < len(segs) - 1:
            next_bg = hex_to_rgb(segs[i + 1]["bg"])
            # Draw underlay in next segment's color
            draw.rectangle([curr_x + tw, y, curr_x + tw + sep_w, y + seg_h], fill=next_bg)
            # Draw separator glyph in current segment's color
            draw_separator(draw, style, curr_x + tw, y, seg_h, sep_w, bg)
            curr_x += tw + sep_w
        else:
            # Closing separator cap
            draw_separator(draw, style, curr_x + tw, y, seg_h, sep_w, bg)
            curr_x += tw + sep_w
            
    return curr_x + 12

def render_preview():
    # 1. Canvas with subtle background ambient gradient
    canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), (10, 12, 17, 255))
    draw_canvas = ImageDraw.Draw(canvas)
    
    # Ambient radial-like gradient
    for r in range(400, 0, -10):
        alpha = int(35 * (1.0 - r / 400.0))
        glow_box = [
            CANVAS_W // 2 - r * 2,
            CANVAS_H // 2 - r,
            CANVAS_W // 2 + r * 2,
            CANVAS_H // 2 + r
        ]
        draw_canvas.ellipse(glow_box, fill=(50, 60, 110, alpha))

    # 2. Shadow Layer for Terminal Window
    shadow_pad = 50
    shadow_img = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_img)
    shadow_draw.rounded_rectangle(
        [WIN_X1 - 10, WIN_Y1 + 16, WIN_X2 + 10, WIN_Y2 + 28],
        radius=WIN_R + 6,
        fill=(0, 0, 0, 140)
    )
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(32))
    canvas.alpha_composite(shadow_img)

    # 3. Terminal Window Base
    win_img = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    win_draw = ImageDraw.Draw(win_img)

    # Window body
    win_draw.rounded_rectangle(
        [WIN_X1, WIN_Y1, WIN_X2, WIN_Y2],
        radius=WIN_R,
        fill=BG_TERMINAL,
        outline=BORDER_COLOR,
        width=2
    )

    # Header bar
    win_draw.rounded_rectangle(
        [WIN_X1, WIN_Y1, WIN_X2, WIN_Y1 + HEADER_H],
        radius=WIN_R,
        fill=BG_HEADER
    )
    # Patch lower corners of header so it seamlessly attaches to body
    win_draw.rectangle([WIN_X1, WIN_Y1 + HEADER_H - 12, WIN_X2, WIN_Y1 + HEADER_H], fill=BG_HEADER)
    win_draw.line([WIN_X1, WIN_Y1 + HEADER_H, WIN_X2, WIN_Y1 + HEADER_H], fill=BORDER_COLOR, width=1)

    # Window Controls (macOS style window dots)
    dot_y = WIN_Y1 + HEADER_H // 2
    win_draw.ellipse([WIN_X1 + 22, dot_y - 7, WIN_X1 + 36, dot_y + 7], fill=(255, 95, 86))
    win_draw.ellipse([WIN_X1 + 46, dot_y - 7, WIN_X1 + 60, dot_y + 7], fill=(255, 189, 46))
    win_draw.ellipse([WIN_X1 + 70, dot_y - 7, WIN_X1 + 84, dot_y + 7], fill=(39, 201, 63))

    # Header Title
    title_text = "pwsh — SxiMao@workstation: ~/Desktop/S-li (PowerShell 7.5)"
    bbox = win_draw.textbbox((0, 0), title_text, font=FONT_TITLE)
    tx = (WIN_X1 + WIN_X2 - (bbox[2] - bbox[0])) / 2
    win_draw.text((tx, WIN_Y1 + 13), title_text, fill=C_GRAY, font=FONT_TITLE)

    # 4. Terminal Interactive Content
    content_x = WIN_X1 + 38
    curr_y = WIN_Y1 + HEADER_H + 32

    # Line 1: Startup Banner
    win_draw.text((content_x, curr_y), "PowerShell 7.5.0-preview.3", fill=C_WHITE, font=FONT_REG_20)
    curr_y += 30
    win_draw.text((content_x, curr_y), "Loading personal profile... S-li (Shell Line Interface) v1.0.0 initialized.", fill=C_GRAY, font=FONT_REG_20)
    curr_y += 46

    # Line 2: First prompt - Sunset Theme with Arrow Style
    p1_segs = [
        {"text": "SxiMao", "bg": "#7b2cbf", "fg": "#ffffff"},
        {"text": "S-li", "bg": "#d94676", "fg": "#ffffff"},
        {"text": "-> (main)", "bg": "#f08a5d", "fg": "#ffffff"},
        {"text": "<3 15:05", "bg": "#4385be", "fg": "#ffffff"}
    ]
    end_x = draw_pill_prompt(win_draw, content_x, curr_y, p1_segs, style="arrow")
    win_draw.text((end_x + 8, curr_y + 7), "git status", fill=C_WHITE, font=FONT_BOLD_24)
    curr_y += 54

    # Output of git status
    win_draw.text((content_x + 10, curr_y), "On branch main", fill=C_GRAY, font=FONT_REG_20)
    curr_y += 28
    win_draw.text((content_x + 10, curr_y), "Your branch is up to date with 'origin/main'.", fill=C_GRAY, font=FONT_REG_20)
    curr_y += 28
    win_draw.text((content_x + 10, curr_y), "Changes not staged for commit:", fill=C_YELLOW, font=FONT_REG_20)
    curr_y += 26
    win_draw.text((content_x + 30, curr_y), "modified:   core/powershell/sli-prompt.ps1", fill=(255, 120, 120), font=FONT_REG_20)
    curr_y += 26
    win_draw.text((content_x + 30, curr_y), "modified:   bin/sli.ps1 (style engine upgraded)", fill=(255, 120, 120), font=FONT_REG_20)
    curr_y += 44

    # Line 3: Second Prompt - Activate Python Venv
    p2_segs = [
        {"text": "SxiMao", "bg": "#7b2cbf", "fg": "#ffffff"},
        {"text": "[py] (.venv) S-li", "bg": "#d94676", "fg": "#ffffff"},
        {"text": "* -> (main)", "bg": "#e26d5c", "fg": "#ffffff"},
        {"text": "<3 15:06", "bg": "#4385be", "fg": "#ffffff"}
    ]
    end_x = draw_pill_prompt(win_draw, content_x, curr_y, p2_segs, style="arrow")
    win_draw.text((end_x + 8, curr_y + 7), "sli style flame", fill=C_CYAN, font=FONT_BOLD_24)
    curr_y += 52

    # Feedback from sli style flame
    win_draw.text((content_x + 10, curr_y), "[OK] Successfully switched separator style to: flame", fill=C_GREEN, font=FONT_REG_20)
    curr_y += 42

    # Line 4: Third Prompt - Flame Style in Action!
    p3_segs = [
        {"text": "SxiMao", "bg": "#7b2cbf", "fg": "#ffffff"},
        {"text": "[py] (.venv) S-li", "bg": "#d94676", "fg": "#ffffff"},
        {"text": "* [fire] (main)", "bg": "#e26d5c", "fg": "#ffffff"},
        {"text": "[star] 15:07", "bg": "#4385be", "fg": "#ffffff"}
    ]
    end_x = draw_pill_prompt(win_draw, content_x, curr_y, p3_segs, style="flame", sep_w=20)
    win_draw.text((end_x + 8, curr_y + 7), "sli theme cyberpunk", fill=C_CYAN, font=FONT_BOLD_24)
    curr_y += 52

    # Feedback from sli theme cyberpunk
    win_draw.text((content_x + 10, curr_y), "[OK] Successfully switched theme to: cyberpunk", fill=C_GREEN, font=FONT_REG_20)
    curr_y += 42

    # Line 5: Fourth Prompt - Cyberpunk Neon + Flame Style + Cursor
    p4_segs = [
        {"text": "SxiMao", "bg": "#00f5d4", "fg": "#0b090a"},
        {"text": "[py] (.venv) S-li", "bg": "#7b2cbf", "fg": "#ffffff"},
        {"text": "* [bolt] (main)", "bg": "#f72585", "fg": "#ffffff"},
        {"text": "[fire] 15:08", "bg": "#fee440", "fg": "#0b090a"}
    ]
    end_x = draw_pill_prompt(win_draw, content_x, curr_y, p4_segs, style="flame", sep_w=20)
    
    # Blinking active terminal cursor
    win_draw.rectangle([end_x + 8, curr_y + 5, end_x + 20, curr_y + 33], fill=(255, 255, 255, 230))

    # Composite window over canvas
    canvas.alpha_composite(win_img)

    # Convert to RGB (for standard PNG without unexpected alpha channel issues)
    final_img = Image.new("RGB", (CANVAS_W, CANVAS_H), (10, 12, 17))
    final_img.paste(canvas, mask=canvas.split()[3])
    
    final_img.save(OUTPUT_PATH, "PNG", quality=95, optimize=True)
    print(f"Terminal screenshot preview generated successfully: {OUTPUT_PATH} ({os.path.getsize(OUTPUT_PATH)} bytes)")

if __name__ == "__main__":
    render_preview()

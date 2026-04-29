"""
App icon generator for house_money_calculator.
Design: Blue gradient background, white house silhouette, amber ₩ symbol.
Run: python3 scripts/generate_icon.py
Output: assets/icons/app_icon_1024.png
"""
from PIL import Image, ImageDraw, ImageFont
import os

SIZE = 1024


def make_gradient_background(draw: ImageDraw.ImageDraw) -> None:
    top_color = (15, 40, 160)
    bottom_color = (31, 79, 255)
    for y in range(SIZE):
        t = y / (SIZE - 1)
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * t)
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * t)
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * t)
        draw.line([(0, y), (SIZE - 1, y)], fill=(r, g, b, 255))


def apply_rounded_corners(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new('L', (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=radius, fill=255)
    img.putalpha(mask)
    return img


def draw_house(draw: ImageDraw.ImageDraw) -> tuple:
    """Draw white house shape. Returns (wall_left, wall_top, wall_right, wall_bottom)."""
    cx = SIZE // 2
    house_w = 560
    roof_overhang = 44
    roof_height = 210
    wall_height = 265
    total_height = roof_height + wall_height
    top_margin = (SIZE - total_height) // 2 - 20

    roof_peak_y = top_margin
    wall_top_y = roof_peak_y + roof_height
    wall_bottom_y = wall_top_y + wall_height
    wall_left = cx - house_w // 2
    wall_right = cx + house_w // 2

    # Walls
    draw.rectangle(
        [wall_left, wall_top_y, wall_right, wall_bottom_y],
        fill=(255, 255, 255, 255),
    )

    # Roof triangle
    roof_pts = [
        (cx, roof_peak_y),
        (wall_left - roof_overhang, wall_top_y),
        (wall_right + roof_overhang, wall_top_y),
    ]
    draw.polygon(roof_pts, fill=(255, 255, 255, 255))

    return wall_left, wall_top_y, wall_right, wall_bottom_y


def draw_won_symbol(
    draw: ImageDraw.ImageDraw,
    wall_left: int,
    wall_top: int,
    wall_right: int,
    wall_bottom: int,
) -> None:
    font_path = '/System/Library/Fonts/AppleSDGothicNeo.ttc'
    font_size = 240
    amber = (245, 158, 11, 255)  # AppColors.warning #F59E0B

    try:
        font = ImageFont.truetype(font_path, font_size, index=7)  # Bold variant
    except Exception:
        font = ImageFont.truetype(font_path, font_size)

    text = '₩'
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]

    cx = (wall_left + wall_right) // 2
    cy = (wall_top + wall_bottom) // 2 + 10

    tx = cx - tw // 2 - bbox[0]
    ty = cy - th // 2 - bbox[1]
    draw.text((tx, ty), text, fill=amber, font=font)


def generate_icon(output_path: str) -> None:
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    make_gradient_background(draw)
    img = apply_rounded_corners(img, radius=220)

    draw = ImageDraw.Draw(img)
    wall_left, wall_top, wall_right, wall_bottom = draw_house(draw)
    draw_won_symbol(draw, wall_left, wall_top, wall_right, wall_bottom)

    img.save(output_path)
    print(f'Icon saved: {output_path}')


if __name__ == '__main__':
    script_dir = os.path.dirname(os.path.abspath(__file__))
    out = os.path.join(script_dir, '../assets/icons/app_icon_1024.png')
    generate_icon(os.path.abspath(out))

"""Gera os ícones do launcher — gota d'água com o gradiente Deep Ocean."""
import math
from PIL import Image, ImageDraw

SIZE = 1024
SS = 4  # supersampling p/ antialias
NAVY = (11, 39, 67, 255)        # #0B2743 - onSurface do tema claro / fundo
WATER_TOP = (124, 208, 251, 255)  # #7CD0FB
WATER_BOTTOM = (14, 124, 216, 255)  # #0E7CD8


def droplet_polygon(cx, cy, r, d, steps=720):
    """Gota = círculo (cx,cy,r) + as duas tangentes vindas do ápice em cy-d."""
    phi = math.acos(r / d)
    apex = (cx, cy - d)
    a1 = math.atan2(-math.cos(phi), math.sin(phi))
    sweep = 2 * math.pi - 2 * phi
    pts = [apex]
    for i in range(steps + 1):
        a = a1 + sweep * i / steps
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def gradient(size, top, bottom):
    g = Image.new("RGBA", (1, size))
    for y in range(size):
        t = y / (size - 1)
        g.putpixel((0, y), tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(4)))
    return g.resize((size, size))


def droplet_layer(size, fill, height_ratio):
    """Camada RGBA transparente com a gota preenchida por `fill` (cor ou imagem)."""
    s = size * SS
    # geometria: altura total da gota = d + r  ->  escala pra height_ratio
    r_unit, d_unit = 1.0, 2.05
    total = d_unit + r_unit
    h = size * height_ratio * SS
    r = h * r_unit / total
    d = h * d_unit / total
    cx = s / 2
    cy = s / 2 + (h / 2) - r  # centraliza a bounding box vertical da gota

    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).polygon(droplet_polygon(cx, cy, r, d), fill=255)
    mask = mask.resize((size, size), Image.LANCZOS)

    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    src = fill if isinstance(fill, Image.Image) else Image.new("RGBA", (size, size), fill)
    layer.paste(src, (0, 0), mask)
    return layer


water = gradient(SIZE, WATER_TOP, WATER_BOTTOM)

# 1. Ícone legado: fundo navy cheio + gota. O launcher aplica a máscara.
legacy = Image.new("RGBA", (SIZE, SIZE), NAVY)
legacy.alpha_composite(droplet_layer(SIZE, water, 0.62))
legacy.save("assets/icon/icon.png")

# 2. Foreground adaptativo: só a gota, menor (zona segura de 66% do canvas).
droplet_layer(SIZE, water, 0.62).save("assets/icon/icon_foreground.png")

# 3. Monocromático (ícones temáticos do Android 13+): silhueta branca opaca;
#    o sistema recolore usando o wallpaper.
droplet_layer(SIZE, (255, 255, 255, 255), 0.62).save("assets/icon/icon_monochrome.png")

print("ok")

# ============================================================
# KALASETU - GOOGLE CLOUD VISION SERVICE
# ============================================================
# Connects to Google Cloud Vision API for visual craft recognition.
# Analyzes product images to detect materials, labels, colors, and craft types.
# ============================================================

import base64
import json
import os
import urllib.request
from pathlib import Path


def _get_api_key() -> str:
    return os.getenv("GOOGLE_CLOUD_VISION_API_KEY", "").strip()


def analyze_image_with_vision(
    image_bytes: bytes | None = None,
    image_path: str | Path | None = None,
    image_base64: str | None = None,
) -> dict:
    """
    Analyze image using Google Cloud Vision API.
    Falls back gracefully to intelligent craft heuristics if API key is not configured.
    """
    api_key = _get_api_key()

    # Prepare base64 string
    b64_content = ""
    if image_base64:
        b64_content = image_base64
    elif image_bytes:
        b64_content = base64.b64encode(image_bytes).decode("utf-8")
    elif image_path and Path(image_path).exists():
        with open(image_path, "rb") as f:
            b64_content = base64.b64encode(f.read()).decode("utf-8")

    # If API key is available and image content is provided, call Google Cloud Vision
    if api_key and b64_content:
        try:
            url = f"https://vision.googleapis.com/v1/images:annotate?key={api_key}"
            payload = {
                "requests": [
                    {
                        "image": {"content": b64_content},
                        "features": [
                            {"type": "LABEL_DETECTION", "maxResults": 10},
                            {"type": "IMAGE_PROPERTIES", "maxResults": 5},
                            {"type": "OBJECT_LOCALIZATION", "maxResults": 5},
                            {"type": "TEXT_DETECTION", "maxResults": 5},
                        ],
                    }
                ]
            }

            req = urllib.request.Request(
                url,
                data=json.dumps(payload).encode("utf-8"),
                headers={"Content-Type": "application/json"},
                method="POST",
            )

            with urllib.request.urlopen(req, timeout=8) as resp:
                result = json.loads(resp.read().decode("utf-8"))
                responses = result.get("responses", [])
                if responses:
                    first_resp = responses[0]
                    labels = [
                        item.get("description", "")
                        for item in first_resp.get("labelAnnotations", [])
                    ]
                    objects = [
                        item.get("name", "")
                        for item in first_resp.get("localizedObjectAnnotations", [])
                    ]
                    texts = [
                        item.get("description", "")
                        for item in first_resp.get("textAnnotations", [])
                    ]

                    # Detect dominant colors
                    dominant_colors = []
                    props = first_resp.get("imagePropertiesAnnotation", {})
                    for color_info in props.get("dominantColors", {}).get("colors", [])[:3]:
                        rgb = color_info.get("color", {})
                        r, g, b = rgb.get("red", 0), rgb.get("green", 0), rgb.get("blue", 0)
                        dominant_colors.append(f"rgb({r},{g},{b})")

                    # Categorize based on labels
                    category = _infer_category(labels + objects)
                    materials = _infer_materials(labels)

                    return {
                        "status": "success",
                        "source": "google_cloud_vision",
                        "labels": labels,
                        "detected_objects": objects,
                        "dominant_colors": dominant_colors,
                        "inferred_category": category,
                        "detected_materials": materials,
                        "detected_text": " ".join(texts[:3]).strip(),
                    }
        except Exception as e:
            print(f"[KalaSetu Vision] Google Cloud Vision error: {e}")

    # Fallback simulation with realistic craft recognition
    return _generate_fallback_vision_data(image_path)


def _infer_category(keywords: list[str]) -> str:
    text = " ".join(keywords).lower()
    if any(k in text for k in ["pot", "clay", "ceramic", "bowl", "vase", "terracotta", "earthenware"]):
        return "Pottery"
    if any(k in text for k in ["basket", "weave", "grass", "wicker", "cane", "jute", "rope"]):
        return "Baskets"
    if any(k in text for k in ["textile", "fabric", "cloth", "embroidery", "silk", "cotton", "shawl", "saree"]):
        return "Textiles"
    if any(k in text for k in ["wood", "carving", "wooden", "sculpture", "furniture"]):
        return "Woodcraft"
    if any(k in text for k in ["jewelry", "jewellery", "bead", "necklace", "earring", "silver", "brass", "bangle"]):
        return "Jewellery"
    if any(k in text for k in ["paint", "art", "madhubani", "canvas", "miniature"]):
        return "Painting"
    return "Pottery"


def _infer_materials(labels: list[str]) -> list[str]:
    materials = []
    text = " ".join(labels).lower()
    if "clay" in text or "pottery" in text or "terracotta" in text:
        materials.append("Natural Riverbed Clay")
    if "glaze" in text or "indigo" in text or "ceramic" in text:
        materials.append("Indigo Mineral Glaze")
    if "grass" in text or "basket" in text or "wicker" in text:
        materials.append("Moonj & Kaasa Grass")
    if "wood" in text or "wooden" in text:
        materials.append("Sheesham Wood")
    if "brass" in text or "metal" in text:
        materials.append("Hand-beaten Brass")
    if not materials:
        materials.append("Handcrafted Organic Materials")
    return materials


def _generate_fallback_vision_data(image_path: str | Path | None) -> dict:
    """Smart fallback when API key is not yet set."""
    filename = str(image_path or "").lower()

    if "basket" in filename:
        return {
            "status": "simulated",
            "source": "kala_vision_engine",
            "labels": ["Woven Basket", "Handicraft", "Grass Coiling", "Natural Fiber", "Home Storage"],
            "detected_objects": ["Basket", "Storage container"],
            "dominant_colors": ["rgb(212,185,148)", "rgb(156,128,95)"],
            "inferred_category": "Baskets",
            "detected_materials": ["Wild Moonj Grass", "Kaasa River Reed"],
            "detected_text": "",
        }
    elif "textile" in filename or "fabric" in filename or "saree" in filename:
        return {
            "status": "simulated",
            "source": "kala_vision_engine",
            "labels": ["Block Print Fabric", "Textile Art", "Indigo Dye", "Handloom Cotton", "Dabu Print"],
            "detected_objects": ["Textile", "Scarf / Shawl"],
            "dominant_colors": ["rgb(25,42,86)", "rgb(230,225,215)"],
            "inferred_category": "Textiles",
            "detected_materials": ["Organic Desi Cotton", "Natural Indigo Dye"],
            "detected_text": "",
        }
    else:
        return {
            "status": "simulated",
            "source": "kala_vision_engine",
            "labels": [
                "Terracotta Pottery",
                "Ceramic Bowl",
                "Indigo Glaze",
                "Earthenware",
                "Wheel Thrown",
                "Handicraft",
            ],
            "detected_objects": ["Ceramic Bowl", "Pottery tableware"],
            "dominant_colors": ["rgb(28,48,74)", "rgb(186,112,79)"],
            "inferred_category": "Pottery",
            "detected_materials": ["Terracotta Clay", "Indigo Mineral Slip"],
            "detected_text": "",
        }

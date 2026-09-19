# ============================================================
# KALASETU - AI & MULTILINGUAL ROUTES
# ============================================================
# Integrates:
# 1. Google Cloud Vision API (Visual Craft Understanding)
# 2. Google Gemini API (Cultural Product Listing & Pricing)
# 3. Bhashini ULCA API (Indian Language Voice & Speech)
# 4. KalaSathi AI Chatbot Assistant
# ============================================================

import base64
from fastapi import APIRouter, File, UploadFile, HTTPException
from pydantic import BaseModel

from ..services.vision_service import analyze_image_with_vision
from ..services.gemini_service import digitize_craft_listing, kalasathi_chat_response
from ..services.bhashini_service import speech_to_text, translate_text, text_to_speech
from ..services.media_service import generate_storage_filename, get_general_directory

router = APIRouter(
    prefix="/api/ai",
    tags=["Artificial Intelligence"]
)


# ============================================================
# SCHEMAS
# ============================================================

class DigitizeProductRequest(BaseModel):
    image_url: str | None = None
    vision_labels: list[str] | None = None
    voice_transcript: str | None = None
    category_hint: str | None = None
    artisan_name: str | None = "Asha Devi"
    artisan_location: str | None = "Jaipur, Rajasthan"


class ChatRequest(BaseModel):
    query: str
    context: str | None = None


class ASRRequest(BaseModel):
    audio_base64: str
    language: str = "hi"


class TranslateRequest(BaseModel):
    text: str
    source_language: str = "hi"
    target_language: str = "en"


class TTSRequest(BaseModel):
    text: str
    language: str = "hi"


# ============================================================
# 1. GOOGLE CLOUD VISION - ANALYZE CRAFT IMAGE
# ============================================================

@router.post("/vision-analyze")
async def vision_analyze(file: UploadFile = File(...)):
    """
    Upload an image to analyze via Google Cloud Vision API.
    Detects craft materials, colors, objects, and attributes.
    """
    if not file.filename:
        raise HTTPException(status_code=400, detail="Filename missing")

    contents = await file.read()
    if not contents:
        raise HTTPException(status_code=400, detail="Empty file uploaded")

    # Save to general uploads for preview
    general_dir = get_general_directory()
    saved_filename = generate_storage_filename(file.filename)
    file_path = general_dir / saved_filename
    with open(file_path, "wb") as f:
        f.write(contents)

    # Analyze with Vision
    vision_result = analyze_image_with_vision(image_bytes=contents, image_path=file_path)
    vision_result["image_url"] = f"/uploads/general/{saved_filename}"

    return vision_result


# ============================================================
# 2. GEMINI + VISION + BHASHINI - COMPLETE PRODUCT DIGITIZATION
# ============================================================

@router.post("/digitize-product")
def digitize_product(req: DigitizeProductRequest):
    """
    Synthesize visual information (Google Cloud Vision) and artisan voice
    (Bhashini) with Google Gemini LLM to auto-create rich cultural listings.
    """
    result = digitize_craft_listing(
        vision_labels=req.vision_labels,
        voice_transcript=req.voice_transcript,
        category_hint=req.category_hint,
        artisan_name=req.artisan_name or "Asha Devi",
        artisan_location=req.artisan_location or "Jaipur, Rajasthan",
    )
    if req.image_url:
        result["image_url"] = req.image_url

    return result


# ============================================================
# 3. KALASATHI AI ASSISTANT CHATBOT
# ============================================================

@router.post("/chat")
def kalasathi_chat(req: ChatRequest):
    """
    Conversational support chatbot powered by Google Gemini.
    Assists with craft packaging, pricing guidance, and order lifecycle.
    """
    if not req.query.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")

    reply = kalasathi_chat_response(req.query)
    return {
        "query": req.query,
        "reply": reply,
        "assistant": "KalaSathi AI",
    }


# ============================================================
# 4. BHASHINI SPEECH RECOGNITION (ASR)
# ============================================================

@router.post("/bhashini/asr")
def bhashini_asr(req: ASRRequest):
    """Convert Indian spoken voice into text."""
    return speech_to_text(
        audio_base64=req.audio_base64,
        source_language=req.language,
    )


# ============================================================
# 5. BHASHINI TRANSLATION (NMT)
# ============================================================

@router.post("/bhashini/translate")
def bhashini_translate(req: TranslateRequest):
    """Translate between Indian regional languages and English."""
    return translate_text(
        text=req.text,
        source_language=req.source_language,
        target_language=req.target_language,
    )


# ============================================================
# 6. BHASHINI TEXT-TO-SPEECH (TTS)
# ============================================================

@router.post("/bhashini/tts")
def bhashini_tts(req: TTSRequest):
    """Convert text into spoken Indian language audio for accessibility."""
    return text_to_speech(
        text=req.text,
        language=req.language,
    )

# ============================================================
# KALASETU - COMPLETE BACKEND INTEGRATION TEST SUITE
# ============================================================

import io
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_all():
    print("\n" + "=" * 60)
    print("RUNNING KALASETU INTEGRATION TESTS")
    print("=" * 60)

    # 1. Health Check
    res = client.get("/api/health")
    assert res.status_code == 200, f"Health check failed: {res.text}"
    print(" [PASSED] 1. API Health Check ->", res.json())

    # 2. Database Health
    res = client.get("/api/health/db")
    assert res.status_code == 200, f"DB check failed: {res.text}"
    print(" [PASSED] 2. Database Health ->", res.json())

    # 3. Request SMS OTP
    phone = "+91 98765 43210"
    res = client.post("/api/auth/request-otp", json={"phone": phone})
    assert res.status_code == 200, f"OTP request failed: {res.text}"
    otp_data = res.json()
    debug_otp = otp_data["debug_otp"]
    print(f" [PASSED] 3. Request OTP for {phone} -> Code: {debug_otp} (Provider: {otp_data.get('provider')})")

    # 4. Login with OTP
    res = client.post("/api/auth/login", json={"phone": phone, "otp": debug_otp})
    assert res.status_code == 200, f"Login failed: {res.text}"
    login_data = res.json()
    token = login_data["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print(f" [PASSED] 4. Login with OTP -> User: {login_data['user']['name']}, Role: {login_data['user']['role']}")

    # 5. Media Upload (Camera photo simulation)
    fake_img = io.BytesIO(b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00H\x00H\x00\x00\xff\xdb\x00C\x00")
    res = client.post(
        "/api/media/upload",
        files={"file": ("pottery_bowl.jpg", fake_img, "image/jpeg")},
    )
    assert res.status_code == 200, f"Media upload failed: {res.text}"
    upload_data = res.json()
    img_url = upload_data["url"]
    print(f" [PASSED] 5. Picture Upload (Camera/Gallery) -> Stored at {img_url}")

    # 6. Vision AI analysis
    fake_img.seek(0)
    res = client.post(
        "/api/ai/vision-analyze",
        files={"file": ("pottery_bowl.jpg", fake_img, "image/jpeg")},
    )
    assert res.status_code == 200, f"Vision analyze failed: {res.text}"
    vision_data = res.json()
    print(f" [PASSED] 6. Vision AI Craft Analysis -> Category: {vision_data.get('inferred_category')}, Labels: {vision_data.get('labels')[:3]}")

    # 7. Gemini LLM Product Digitization
    res = client.post(
        "/api/ai/digitize-product",
        json={
            "image_url": img_url,
            "vision_labels": vision_data.get("labels", []),
            "voice_transcript": "हाथ से बना हुआ गहरा नीला इंडिगो बाउल",
            "category_hint": "Pottery",
        },
    )
    assert res.status_code == 200, f"Digitization failed: {res.text}"
    ai_product = res.json()
    print(f" [PASSED] 7. Gemini NLP Product Digitization -> Title: '{ai_product.get('title')}', Price: Rs.{ai_product.get('suggested_price')}")

    # 8. KalaSathi Chatbot
    res = client.post(
        "/api/ai/chat",
        json={"query": "How do I safely pack delicate pottery for courier delivery?"},
    )
    assert res.status_code == 200, f"KalaSathi chat failed: {res.text}"
    chat_data = res.json()
    print(f" [PASSED] 8. KalaSathi AI Chatbot -> Response length: {len(chat_data.get('reply'))} chars")

    # 9. Bhashini ASR & Translation
    res = client.post(
        "/api/ai/bhashini/translate",
        json={
            "text": "हाथ से बना हुआ गहरा नीला इंडिगो बाउल",
            "source_language": "hi",
            "target_language": "en",
        },
    )
    assert res.status_code == 200, f"Bhashini translate failed: {res.text}"
    print(f" [PASSED] 9. Bhashini Multilingual Translation -> '{res.json().get('translated_text')}'")

    # 10. Razorpay Payments - Create Order & Verify
    res = client.post(
        "/api/payments/create-order",
        json={"amount": 1499.0, "product_name": ai_product.get("title")},
        headers=headers,
    )
    assert res.status_code == 200, f"Razorpay order failed: {res.text}"
    rzp_order = res.json()
    rzp_order_id = rzp_order["id"]
    print(f" [PASSED] 10a. Razorpay Order Creation -> Order ID: {rzp_order_id}, Amount: {rzp_order['amount']} paise")

    # Verify signature
    res = client.post(
        "/api/payments/verify",
        json={
            "razorpay_order_id": rzp_order_id,
            "razorpay_payment_id": "pay_test_kalasetu_12345",
            "razorpay_signature": "test_sig_kalasetu_valid",
        },
        headers=headers,
    )
    assert res.status_code == 200, f"Razorpay verification failed: {res.text}"
    print(f" [PASSED] 10b. Razorpay Signature Verification -> Status: {res.json()['status']}")

    # 11. Artisan Stats & Profile Avatar Update
    res = client.post(
        "/api/artisan/profile/avatar",
        json={"image_url": img_url},
        headers=headers,
    )
    assert res.status_code == 200, f"Avatar update failed: {res.text}"
    print(f" [PASSED] 11a. Artisan Avatar Update -> {res.json()['profile_image']}")

    res = client.get("/api/artisan/stats", headers=headers)
    assert res.status_code == 200, f"Artisan stats failed: {res.text}"
    print(f" [PASSED] 11b. Artisan Workshop Live Stats -> {res.json()}")

    # 12. Artisan Pehchan ID Document Verification
    res = client.post(
        "/api/artisan/verify-pehchan",
        json={
            "document_url": img_url,
            "pehchan_id": "ID-ART-8821",
            "artisan_name": "Asha Devi",
        },
    )
    assert res.status_code == 200, f"Pehchan verification failed: {res.text}"
    pehchan_data = res.json()
    assert pehchan_data["verified"] is True
    print(f" [PASSED] 12. Artisan Pehchan ID Document Verification -> Card: {pehchan_data['pehchan_id']}, Agency: {pehchan_data['verification_agency']}")

    print("\n" + "=" * 60)
    print("ALL 12 BACKEND MODULES & INTEGRATIONS PASSED WITH 100% SUCCESS!")
    print("=" * 60 + "\n")

if __name__ == "__main__":
    test_all()

# 🔑 KalaSetu - API Keys & External Integrations Setup Guide

This guide walks you through acquiring keys for all integrated services in **KalaSetu**.
Once you obtain any key, paste it into `Backend/.env`. The backend automatically detects the key and activates real live calls!

---

## 1. Google Gemini API (Generative AI & Cultural NLP)
**Used for:** Craft title & storytelling description generation, fair pricing logic, and KalaSathi chatbot.

1. Go to [Google AI Studio](https://aistudio.google.com/).
2. Sign in with your Google account.
3. Click the **"Get API key"** button on the top left.
4. Click **"Create API key"** (select an existing Google Cloud project or create a free new one).
5. Copy your key (starts with `AIzaSy...`).
6. Paste into `Backend/.env`:
   ```env
   GEMINI_API_KEY=AIzaSyYourGeneratedGeminiKeyHere
   GEMINI_MODEL=gemini-1.5-flash
   ```

---

## 2. Google Cloud Vision API (Visual Craft Recognition)
**Used for:** Analyzing uploaded product pictures, detecting craft materials (clay, wood, brass, fabric), dominant colors, and text.

1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or select your existing project.
3. Navigate to **APIs & Services > Library**.
4. Search for **"Cloud Vision API"** and click **Enable**.
5. Go to **APIs & Services > Credentials**.
6. Click **Create Credentials > API Key**.
7. Copy the generated API key.
8. Paste into `Backend/.env`:
   ```env
   GOOGLE_CLOUD_VISION_API_KEY=AIzaSyYourCloudVisionKeyHere
   ```

---

## 3. Razorpay Payment Gateway (Test Mode)
**Used for:** Indian checkout supporting UPI (Google Pay, PhonePe, Paytm), QR Code, Cards, and Netbanking.

1. Go to [Razorpay Dashboard](https://dashboard.razorpay.com/) and sign up / log in.
2. In the top banner, ensure you are in **"Test Mode"** (toggle to Test Mode).
3. Navigate to **Account & Settings** (or Settings in left menu) > **API Keys**.
4. Click **"Generate Test Key"** (or Regenerate Key).
5. You will receive:
   - `Key Id` (starts with `rzp_test_...`)
   - `Key Secret`
6. Paste into `Backend/.env`:
   ```env
   RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxxx
   RAZORPAY_KEY_SECRET=your_razorpay_test_secret
   ```

---

## 4. Bhashini ULCA API (Govt. of India Indian Languages Voice & Speech)
**Used for:** Speech-to-Text (ASR), Text-to-Speech (TTS), and translation for Indian languages (Hindi, Tamil, Marathi, Bengali, Telugu, Gujarati, etc.).

1. Visit the [Bhashini Open Innovation Portal](https://bhashini.gov.in/ulca) or [NHA Bhashini Portal](https://nha.bhashini.gov.in/).
2. Register your organization / developer profile.
3. Under API Management, generate:
   - User ID (`userID`)
   - API Key (`ulcaApiKey`)
   - Pipeline ID for ASR/TTS/NMT services
4. Paste into `Backend/.env`:
   ```env
   BHASHINI_USER_ID=your_bhashini_user_id
   BHASHINI_API_KEY=your_bhashini_api_key
   BHASHINI_PIPELINE_ID=your_pipeline_id
   ```
*(Note: If you don't have Bhashini credentials yet, KalaSetu automatically uses high-fidelity speech synthesis and audio transcript simulation!)*

---

## 5. SMS Gateway for Phone OTP (Fast2SMS or Twilio)
**Used for:** Sending live 6-digit verification codes to Indian mobile numbers (+91).

### Option A: Fast2SMS (Simple Indian SMS Gateway)
1. Go to [Fast2SMS](https://www.fast2sms.com/) and sign up.
2. Go to **Dev API** in the dashboard.
3. Copy your API Authorization Key.
4. Paste into `Backend/.env`:
   ```env
   FAST2SMS_API_KEY=your_fast2sms_api_key
   ```

### Option B: Twilio (Global SMS)
1. Go to [Twilio Console](https://console.twilio.com/).
2. Copy your **Account SID**, **Auth Token**, and **Twilio Phone Number**.
3. Paste into `Backend/.env`:
   ```env
   TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   TWILIO_AUTH_TOKEN=your_auth_token
   TWILIO_FROM_NUMBER=+1234567890
   ```

---

## 💡 Dual-Mode Guarantee
If any key is missing or blank, **KalaSetu automatically falls back to built-in simulation mode**:
- OTP login works instantly with code `123456` or the generated code printed in the backend terminal.
- Razorpay simulates instant test payments.
- Gemini & Vision AI provide rich, authentic handicraft metadata for pottery, textiles, baskets, and jewelry.
- The app will **never crash or halt** due to missing API keys!

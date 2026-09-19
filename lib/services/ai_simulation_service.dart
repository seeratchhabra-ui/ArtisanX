import 'dart:async';
import 'api_service.dart';

class AiDigitizedProductResult {
  final String title;
  final String description;
  final List<String> tags;
  final String category;
  final double suggestedPrice;
  final String detectedMaterial;
  final String detectedRegion;
  final String rawSpeechTranscript;
  final String? imageUrl;

  AiDigitizedProductResult({
    required this.title,
    required this.description,
    required this.tags,
    required this.category,
    required this.suggestedPrice,
    required this.detectedMaterial,
    required this.detectedRegion,
    required this.rawSpeechTranscript,
    this.imageUrl,
  });
}

class AiSimulationService {
  /// Bhashini Speech-to-Text conversion
  static Future<String> transcribeVoice({
    required String languageCode,
    String? sampleType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (languageCode == 'hi') {
      return 'यह एक हाथ से बना गहरा नीला इंडिगो चमक वाला टेराकोटा का बड़ा कटोरा है। यह परोसने और सजाने के लिए सबसे बढ़िया है।';
    } else if (languageCode == 'ta') {
      return 'இது கையால் செய்யப்பட்ட நீல நிற டெரகோட்டா கிண்ணம்.';
    } else {
      return 'Handmade natural clay bowl finished with rich deep indigo glaze, shaped on traditional potter wheel.';
    }
  }

  /// Vision AI (Google Cloud Vision) + Gemini LLM metadata generation
  static Future<AiDigitizedProductResult> digitizeCraftProduct({
    String? imagePath,
    String? voiceTranscript,
    String language = 'hi',
  }) async {
    // 1. Try Live Backend (Google Cloud Vision + Google Gemini)
    try {
      final backendAiResult = await ApiService.digitizeProductWithAi(
        imageUrl: imagePath,
        voiceTranscript: voiceTranscript,
      );

      if (backendAiResult != null) {
        return AiDigitizedProductResult(
          title: backendAiResult['title'] ?? 'Indigo Glaze Serving Bowl',
          description: backendAiResult['description'] ??
              'Hand-thrown terracotta bowl finished in a rich indigo glaze, ideal for serving or display.',
          tags: (backendAiResult['tags'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ['#pottery', '#handmade', '#indigo'],
          category: backendAiResult['category'] ?? 'Pottery',
          suggestedPrice:
              (backendAiResult['suggested_price'] as num?)?.toDouble() ?? 1499.0,
          detectedMaterial: backendAiResult['material'] ??
              'Natural Riverbed Clay & Indigo Mineral Slip',
          detectedRegion:
              backendAiResult['made_in'] ?? 'Sanganer, Jaipur, Rajasthan',
          rawSpeechTranscript: voiceTranscript ??
              'हाथ से बना हुआ गहरा नीला इंडिगो बाउल (Bhashini STT)',
          imageUrl: imagePath,
        );
      }
    } catch (_) {}

    // 2. Intelligent Offline Fallback
    await Future.delayed(const Duration(milliseconds: 800));

    final isBasket = (imagePath ?? '').contains('basket') ||
        (voiceTranscript ?? '').contains('टोकरी');

    if (isBasket) {
      return AiDigitizedProductResult(
        title: 'Moonj & Kaasa Grass Storage Basket',
        description:
            'Handcrafted using wild Moonj and Kaasa grass sustainably harvested along eastern riverbeds. Intricately coiled by hand using ancient craft techniques.',
        tags: ['#baskets', '#moonjgrass', '#sustainable', '#handmade'],
        category: 'Baskets',
        suggestedPrice: 1290.0,
        detectedMaterial: 'Moonj & Kaasa Wild Grass',
        detectedRegion: 'Prayagraj, Uttar Pradesh',
        rawSpeechTranscript:
            voiceTranscript ?? 'नदी के किनारे से मूंज घास की टोकरी',
        imageUrl: imagePath,
      );
    }

    return AiDigitizedProductResult(
      title: 'Indigo Glaze Serving Bowl',
      description:
          'Hand-thrown terracotta bowl finished in a rich indigo glaze, ideal for serving or display. Every piece carries gentle variations that make it truly one of a kind.',
      tags: ['#pottery', '#handmade', '#indigo'],
      category: 'Pottery',
      suggestedPrice: 1499.0,
      detectedMaterial: 'Terracotta Clay & Indigo Glaze',
      detectedRegion: 'Jaipur, Rajasthan',
      rawSpeechTranscript: voiceTranscript ??
          'हाथ से बना हुआ गहरा नीला इंडिगो बाउल (Bhashini STT)',
      imageUrl: imagePath,
    );
  }

  /// KalaSathi Chatbot response generator (Google Gemini powered)
  static Future<String> getKalaSathiAnswer(String query) async {
    // 1. Try Live Gemini from backend
    try {
      final reply = await ApiService.askKalaSathi(query);
      if (reply.isNotEmpty) {
        return reply;
      }
    } catch (_) {}

    // 2. Offline fallback
    await Future.delayed(const Duration(milliseconds: 600));

    final q = query.toLowerCase();

    if (q.contains('pack') || q.contains('shipping') || q.contains('पैकिंग')) {
      return 'For terracotta & pottery, wrap with 3 layers of recycled honeycomb paper or bubble wrap. Place in double-walled corrugated box with 2 inches cushioning on all sides.';
    } else if (q.contains('order') ||
        q.contains('ax1048') ||
        q.contains('ऑर्डर')) {
      return 'Order #AX1048 for Indigo Serving Bowl is currently "Processing". The delivery courier pickup is scheduled for tomorrow at 11:30 AM.';
    } else if (q.contains('price') || q.contains('कीमत')) {
      return 'KalaSetu AI suggests pricing by calculating (Raw materials + Labor hours × ₹180) + 20% craft heritage premium.';
    } else if (q.contains('pgvector') || q.contains('search')) {
      return 'KalaSetu uses PostgreSQL pgvector hybrid search! It translates customer queries like "eco-friendly basket" into vector embeddings to match the meaning of your craft descriptions.';
    } else {
      return 'Namaste! I am KalaSathi, your craft companion. You can ask me how to upload products, pack delicate ceramics, check orders, or speak in Hindi/English.';
    }
  }
}

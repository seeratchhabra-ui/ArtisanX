import 'dart:async';

class AiDigitizedProductResult {
  final String title;
  final String description;
  final List<String> tags;
  final String category;
  final double suggestedPrice;
  final String detectedMaterial;
  final String detectedRegion;
  final String rawSpeechTranscript;

  AiDigitizedProductResult({
    required this.title,
    required this.description,
    required this.tags,
    required this.category,
    required this.suggestedPrice,
    required this.detectedMaterial,
    required this.detectedRegion,
    required this.rawSpeechTranscript,
  });
}

class AiSimulationService {
  /// Simulates Bhashini Speech-to-Text conversion
  static Future<String> transcribeVoice({
    required String languageCode,
    String? sampleType,
  }) async {
    // Realistic AI network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (languageCode == 'hi') {
      return 'यह एक हाथ से बना गहरा नीला इंडिगो चमक वाला टेराकोटा का बड़ा कटोरा है। यह परोसने और सजाने के लिए सबसे बढ़िया है।';
    } else if (languageCode == 'ta') {
      return 'இது கையால் செய்யப்பட்ட நீல நிற டெரகோட்டா கிண்ணம்.';
    } else {
      return 'Handmade natural clay bowl finished with rich deep indigo glaze, shaped on traditional potter wheel.';
    }
  }

  /// Simulates Vision AI (Google Cloud Vision) + Gemini LLM metadata generation
  static Future<AiDigitizedProductResult> digitizeCraftProduct({
    String? imagePath,
    String? voiceTranscript,
    String language = 'hi',
  }) async {
    // Simulate Vision AI edge processing and Gemini LLM reasoning
    await Future.delayed(const Duration(milliseconds: 1600));

    return AiDigitizedProductResult(
      title: 'Indigo Glaze Serving Bowl',
      description: 'Hand-thrown terracotta bowl finished in a rich indigo glaze, ideal for serving or display. Every piece carries gentle variations that make it truly one of a kind.',
      tags: ['#pottery', '#handmade', '#indigo'],
      category: 'Pottery',
      suggestedPrice: 1499.0,
      detectedMaterial: 'Terracotta Clay & Indigo Glaze',
      detectedRegion: 'Jaipur, Rajasthan',
      rawSpeechTranscript:
          voiceTranscript ??
          'हाथ से बना हुआ गहरा नीला इंडिगो बाउल (Bhashini STT)',
    );
  }

  /// KalaSathi Chatbot response generator
  static Future<String> getKalaSathiAnswer(String query) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final q = query.toLowerCase();

    if (q.contains('pack') || q.contains('shipping') || q.contains('पैकिंग')) {
      return 'For terracotta & pottery, wrap with 3 layers of recycled honeycomb paper or bubble wrap. Place in double-walled corrugated box with 2 inches cushioning on all sides.';
    } else if (q.contains('order') ||
        q.contains('ax1048') ||
        q.contains('ऑर्डर')) {
      return 'Order #AX1048 for Indigo Serving Bowl is currently "Ready to ship". The delivery courier pickup is scheduled for tomorrow at 11:30 AM.';
    } else if (q.contains('price') || q.contains('कीमत')) {
      return 'KalaSetu AI suggests pricing by calculating (Raw materials + Labor hours × ₹180) + 20% craft heritage premium.';
    } else if (q.contains('pgvector') || q.contains('search')) {
      return 'KalaSetu uses PostgreSQL pgvector hybrid search! It translates customer queries like "eco-friendly basket" into vector embeddings to match the meaning of your craft descriptions.';
    } else {
      return 'Namaste! I am KalaSathi, your craft companion. You can ask me how to upload products, pack delicate ceramics, check orders, or speak in Hindi/English.';
    }
  }
}

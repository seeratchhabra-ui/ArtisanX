import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../services/ai_simulation_service.dart';
import '../../providers/app_state.dart';
import '../../widgets/active_voice_ripple.dart';
import '../../widgets/accessible_speaker_button.dart';

class KalaSathiAssistantScreen extends StatefulWidget {
  const KalaSathiAssistantScreen({super.key});

  @override
  State<KalaSathiAssistantScreen> createState() =>
      _KalaSathiAssistantScreenState();
}

class _KalaSathiAssistantScreenState extends State<KalaSathiAssistantScreen> {
  bool _isListening = false;
  bool _isThinking = false;
  String _userQuery = '';
  String _assistantReply =
      'Namaste! I am KalaSathi, your craft companion. Tap the microphone or select a question below to get voice and AI support.';

  final List<String> _suggestedPrompts = [
    'How do I pack delicate ceramics?',
    'Track my order #AX1048',
    'सुरक्षित पैकेजिंग और शिपिंग कैसे करें?',
    'How does KalaSetu suggest product prices?',
    'Explain pgvector semantic search',
  ];

  void _handleAsk(String query) async {
    setState(() {
      _userQuery = query;
      _isListening = false;
      _isThinking = true;
    });

    final reply = await AiSimulationService.getKalaSathiAnswer(query);

    if (mounted) {
      setState(() {
        _assistantReply = reply;
        _isThinking = false;
      });
    }
  }

  void _toggleListening() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (_isListening) {
      setState(() => _isListening = false);
      appState.setVoiceAssistantActive(false);
    } else {
      setState(() {
        _isListening = true;
        _userQuery = 'Listening to your voice (Bhashini)...';
      });
      appState.setVoiceAssistantActive(true);

      // Simulate voice input processing
      final transcript = await AiSimulationService.transcribeVoice(
        languageCode: 'hi',
      );
      if (mounted) {
        appState.setVoiceAssistantActive(false);
        _handleAsk(transcript);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EC), // Soft cream sand background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'KalaSathi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _userQuery = '';
                _assistantReply =
                    'Namaste! I am KalaSathi. How can I help you today?';
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // Center Microphone with Active Multi-Ring Concentric Ripple Animation
            Center(
              child: GestureDetector(
                onTap: _toggleListening,
                child: ActiveVoiceRipple(
                  isActive: _isListening,
                  ringColor: const Color(0xFFC85A32),
                  minRadius: 52,
                  maxRadius: 110,
                  ringCount: 3,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE08D45),
                          Color(0xFFC85A32),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC85A32).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _isListening
                  ? 'Listening via Bhashini Voice AI...'
                  : _isThinking
                  ? 'KalaSathi is thinking...'
                  : 'Tap mic to speak in any Indian language',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _isListening ? AppTheme.terracotta : AppTheme.textMuted,
              ),
            ),

            const Spacer(flex: 1),

            // Assistant Speech Bubble / Answer Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userQuery.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.person_pin,
                            size: 18,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _userQuery,
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.terracotta.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: AppTheme.terracotta,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _assistantReply,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AccessibleSpeakerButton(
                          textToRead: _assistantReply,
                          tooltip: 'Read reply aloud via Bhashini',
                          size: 34,
                          glowColor: AppTheme.terracotta,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Prompt Suggestions Carousel
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _suggestedPrompts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _suggestedPrompts[index];
                  return InkWell(
                    onTap: () => _handleAsk(prompt),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Text(
                        prompt,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

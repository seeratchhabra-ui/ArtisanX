import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/app_state.dart';
import '../../services/ai_simulation_service.dart';
import '../../services/api_service.dart';
import '../../services/camera_picker_service.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/craft_floating_buttons.dart';

class AiProductUploadScreen extends StatefulWidget {
  const AiProductUploadScreen({super.key});

  @override
  State<AiProductUploadScreen> createState() => _AiProductUploadScreenState();
}

class _AiProductUploadScreenState extends State<AiProductUploadScreen> {
  final TextEditingController _titleController = TextEditingController(
    text: 'Indigo Glaze Serving Bowl',
  );

  final TextEditingController _descController = TextEditingController(
    text:
        'Hand-thrown terracotta bowl finished in a rich indigo glaze, ideal for serving or display.',
  );

  final TextEditingController _priceController = TextEditingController(
    text: '1499',
  );

  String _selectedCategory = 'Pottery';
  String _selectedLanguage = 'हिन्दी';

  List<String> _tags = [
    '#pottery',
    '#handmade',
    '#indigo',
  ];

  bool _isUploadingMedia = false;
  bool _isRecordingVoice = false;
  bool _isAiProcessing = false;
  bool _isPublishing = false;

  String? _previewImageUrl =
      'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80';

  final List<String> _categoryOptions = [
    'Pottery',
    'Baskets',
    'Textiles',
    'Jewellery',
    'Woodcraft',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // VOICE + AI
  // ---------------------------------------------------------------------------

  Future<void> _triggerVoiceInput() async {
    if (_isRecordingVoice || _isAiProcessing) return;

    setState(() {
      _isRecordingVoice = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bhashini Speech Recognition active ($_selectedLanguage)... Speak now!',
        ),
        backgroundColor: AppTheme.forestGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final transcript = await AiSimulationService.transcribeVoice(
        languageCode: _selectedLanguage == 'हिन्दी' ? 'hi' : 'en',
      );

      if (!mounted) return;

      setState(() {
        _isRecordingVoice = false;
        _isAiProcessing = true;
      });

      final aiResult = await AiSimulationService.digitizeCraftProduct(
        imagePath: _previewImageUrl,
        voiceTranscript: transcript,
      );

      if (!mounted) return;

      setState(() {
        _isAiProcessing = false;
        _titleController.text = aiResult.title;
        _descController.text = aiResult.description;
        _priceController.text =
            aiResult.suggestedPrice.toStringAsFixed(0);
        _selectedCategory = aiResult.category;
        _tags = aiResult.tags;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vision AI & Gemini generated product metadata successfully!',
          ),
          backgroundColor: AppTheme.forestGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRecordingVoice = false;
        _isAiProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI voice processing failed: $e'),
          backgroundColor: AppTheme.terracotta,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // CAMERA / GALLERY
  // ---------------------------------------------------------------------------

  Future<void> _openCameraOrGalleryPick() async {
    if (_isAiProcessing || _isPublishing) return;

    final result = await CameraPickerService.pickOrCaptureImage(
      context,
      title: 'Photograph Your Craft',
    );

    if (result == null || !mounted) return;

    setState(() {
      _previewImageUrl = result.imageUrl;
      _isAiProcessing = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Craft photo captured '
          '(${result.sourceDescription ?? "Camera"}). '
          'Running Vision AI & Gemini...',
        ),
        backgroundColor: AppTheme.forestGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final aiResult = await AiSimulationService.digitizeCraftProduct(
        imagePath: result.imageUrl,
        voiceTranscript: _descController.text.isNotEmpty
            ? _descController.text
            : null,
      );

      if (!mounted) return;

      setState(() {
        _isAiProcessing = false;
        _titleController.text = aiResult.title;
        _descController.text = aiResult.description;
        _priceController.text =
            aiResult.suggestedPrice.toStringAsFixed(0);
        _selectedCategory = aiResult.category;
        _tags = aiResult.tags;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAiProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI image processing failed: $e'),
          backgroundColor: AppTheme.terracotta,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PUBLISH PRODUCT
  // ---------------------------------------------------------------------------

  Future<void> _publishProduct() async {
    if (_isPublishing) return;

    final appState = Provider.of<AppState>(
      context,
      listen: false,
    );

    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final price =
        double.tryParse(_priceController.text.trim());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product title.'),
          backgroundColor: AppTheme.terracotta,
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product description.'),
          backgroundColor: AppTheme.terracotta,
        ),
      );
      return;
    }

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid product price.'),
          backgroundColor: AppTheme.terracotta,
        ),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    final currentUser = appState.currentUser;

    final newProduct = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: title,
      description: description,
      price: price,
      category: _selectedCategory,
      stock: 15,
      state: 'Rajasthan',
      sellerId: currentUser?.id ?? 1,
      sellerName: currentUser?.name ?? 'Artisan',
      sellerTitle: 'Artisan',
      sellerLocation: 'Rajasthan',
      imageUrl: _previewImageUrl ??
          'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80',
      tags: _tags,
      material: 'Terracotta',
      madeIn: 'Rajasthan',
    );

    try {
      debugPrint(
        '🟢 Publishing product: ${newProduct.name}',
      );

      await appState.publishProduct(newProduct);

      debugPrint(
        '🟢 publishProduct completed successfully',
      );

      if (!mounted) return;

      // Stop the spinner immediately after the publish operation completes.
      setState(() {
        _isPublishing = false;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.forestGreen,
                  size: 28,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Craft Published!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              '${newProduct.name} is now live on the KalaSetu marketplace with AI semantic search tags.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forestGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Back to Workshop'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // Return to the artisan workshop after successful publishing.
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      debugPrint(
        '🔴 Product publishing failed: $e',
      );
      debugPrint(
        '$stackTrace',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to publish the product: $e',
          ),
          backgroundColor: AppTheme.terracotta,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      // This is the important part:
      // the loading spinner can never remain stuck because of an exception.
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: Column(
          children: [
            // -----------------------------------------------------------------
            // TOP BAR
            // -----------------------------------------------------------------

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                    ),
                    onPressed: _isPublishing
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Create with AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.help_outline,
                      size: 22,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Upload a photo or speak in Hindi/Tamil to let Gemini create the listing.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // SCROLLABLE FORM
            // -----------------------------------------------------------------

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------------------------
                    // MEDIA UPLOAD
                    // ---------------------------------------------------------

                    GestureDetector(
                      onTap: _openCameraOrGalleryPick,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF7F2),
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFDE9E87),
                            width: 1.5,
                            strokeAlign:
                                BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: _isUploadingMedia
                            ? const Center(
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      AppTheme.terracotta,
                                ),
                              )
                            : _previewImageUrl != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(
                                          18,
                                        ),
                                        child: Image.network(
                                          ApiService.resolveImageUrl(
                                            _previewImageUrl!,
                                          ),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: AppTheme
                                                  .surfaceWarm,
                                              child:
                                                  const Center(
                                                child: Icon(
                                                  Icons
                                                      .camera_alt,
                                                  color: AppTheme
                                                      .textMuted,
                                                  size: 36,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        decoration:
                                            BoxDecoration(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(18),
                                          color: Colors.black
                                              .withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration:
                                              BoxDecoration(
                                            color: Colors.white
                                                .withValues(
                                              alpha: 0.9,
                                            ),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons
                                                    .camera_alt,
                                                size: 16,
                                                color: AppTheme
                                                    .textDark,
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                'Change photo or video',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                  color: AppTheme
                                                      .textDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .camera_alt_outlined,
                                        size: 36,
                                        color:
                                            AppTheme.textMuted,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Upload photo or video',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w500,
                                          color: AppTheme
                                              .textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ---------------------------------------------------------
                    // VOICE + LANGUAGE
                    // ---------------------------------------------------------

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _triggerVoiceInput,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isRecordingVoice
                                        ? AppTheme.terracotta
                                        : AppTheme.forestGreen,
                                foregroundColor:
                                    Colors.white,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    22,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              icon: Icon(
                                _isRecordingVoice
                                    ? Icons.mic
                                    : Icons.mic_none,
                                size: 20,
                              ),
                              label: Text(
                                _isRecordingVoice
                                    ? 'Listening...'
                                    : 'Speak product details',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 44,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(22),
                              border: Border.all(
                                color:
                                    AppTheme.borderLight,
                              ),
                            ),
                            child:
                                DropdownButtonHideUnderline(
                              child:
                                  DropdownButton<String>(
                                value:
                                    _selectedLanguage,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color:
                                      AppTheme.textDark,
                                ),
                                items: [
                                  'हिन्दी',
                                  'English',
                                  'தமிழ்',
                                  'বাংলা',
                                ]
                                    .map(
                                      (lang) =>
                                          DropdownMenuItem(
                                        value: lang,
                                        child: Text(
                                          lang,
                                          style:
                                              const TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(
                                      () =>
                                          _selectedLanguage =
                                              val,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------
                    // AI GENERATED DETAILS
                    // ---------------------------------------------------------

                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.mustardGold,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'AI-generated details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        if (_isAiProcessing) ...[
                          const SizedBox(width: 10),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  AppTheme.mustardGold,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ---------------------------------------------------------
                    // TITLE
                    // ---------------------------------------------------------

                    const Text(
                      'Product title',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: _titleController,
                      enabled: !_isPublishing,
                      decoration: const InputDecoration(
                        hintText:
                            'e.g. Indigo Glaze Serving Bowl',
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ---------------------------------------------------------
                    // DESCRIPTION
                    // ---------------------------------------------------------

                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: _descController,
                      enabled: !_isPublishing,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText:
                            'Enter craft description...',
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ---------------------------------------------------------
                    // TAGS
                    // ---------------------------------------------------------

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _tags.map((tag) {
                        return Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF88A932),
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // ---------------------------------------------------------
                    // CATEGORY + PRICE
                    // ---------------------------------------------------------

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CATEGORY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w600,
                                  color:
                                      AppTheme.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 14,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(14),
                                  border: Border.all(
                                    color:
                                        AppTheme.borderLight,
                                  ),
                                ),
                                child:
                                    DropdownButtonHideUnderline(
                                  child:
                                      DropdownButton<String>(
                                    value:
                                        _selectedCategory,
                                    isExpanded: true,
                                    items:
                                        _categoryOptions
                                            .map(
                                              (category) =>
                                                  DropdownMenuItem(
                                                value:
                                                    category,
                                                child: Text(
                                                  category,
                                                  style:
                                                      const TextStyle(
                                                    fontSize:
                                                        13,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        _isPublishing
                                            ? null
                                            : (val) {
                                                if (val !=
                                                    null) {
                                                  setState(
                                                    () =>
                                                        _selectedCategory =
                                                            val,
                                                  );
                                                }
                                              },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SUGGESTED PRICE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w600,
                                  color:
                                      AppTheme.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 14,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(14),
                                  border: Border.all(
                                    color:
                                        AppTheme.borderLight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      '₹',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: AppTheme
                                            .terracotta,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            _priceController,
                                        enabled:
                                            !_isPublishing,
                                        keyboardType:
                                            TextInputType
                                                .number,
                                        style:
                                            const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: AppTheme
                                              .terracotta,
                                        ),
                                        decoration:
                                            const InputDecoration(
                                          border:
                                              InputBorder
                                                  .none,
                                          enabledBorder:
                                              InputBorder
                                                  .none,
                                          focusedBorder:
                                              InputBorder
                                                  .none,
                                          contentPadding:
                                              EdgeInsets
                                                  .symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---------------------------------------------------------
                    // REVIEW & PUBLISH
                    // ---------------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isPublishing ||
                                _isAiProcessing
                            ? null
                            : _publishProduct,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.forestGreen,
                          foregroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              AppTheme.forestGreen
                                  .withValues(alpha: 0.55),
                          disabledForegroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(26),
                          ),
                          elevation: 1,
                        ),
                        icon: _isPublishing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.auto_awesome,
                                size: 18,
                              ),
                        label: _isPublishing
                            ? const Text(
                                'Publishing...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              )
                            : const Text(
                                'Review & Publish',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // FLOATING AI BUTTONS
            // -----------------------------------------------------------------

            const CraftFloatingButtons(),
          ],
        ),
      ),
    );
  }
}
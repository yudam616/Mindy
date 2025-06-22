import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import '../services/app_state.dart';
import '../services/toma_chat_service.dart';
import '../services/tts_service.dart';
import 'mode_selection_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _tomatoAnimationController;
  late Animation<double> _tomatoScaleAnimation;
  bool _showChat = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _currentMessage = '';
  List<ChatMessage> _messages = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TomaChatService _tomaChatService = TomaChatService();
  final TTSService _ttsService = TTSService();
  final ScrollController _scrollController = ScrollController();

  // 토마토 성장 관련 변수들
  int _conversationCount = 0;
  int _growthStage = 0; // 0: 씨앗, 1: 새싹, 2: 어린 토마토, 3: 어른 토마토
  bool _isBadStage = false;
  final int _growthThreshold = 1; // 1번의 대화마다 성장

  // 성장 완료 팝업 관련 변수
  bool _showGrowthCompletePopup = false;

  int _positiveCount = 0; // 긍정 대화 횟수

  @override
  void initState() {
    super.initState();
    _tomatoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _tomatoScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _tomatoAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _tomatoAnimationController.repeat(reverse: true);

    _initializeSpeech();
    _addInitialMessage();

    // 초기 메시지 추가 후 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _initializeSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        print('Speech recognition error: $error');
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  void _addInitialMessage() {
    final startMessages = [
      '안녕! 오늘 하루는 어땠나요?',
      '토마토와 대화해볼까요? 오늘 재미있는 일 있었어요?',
      '안녕하세요! 오늘 기분이 어때요?',
      '토마토가 기다리고 있었어요! 오늘 뭐 재미있는 일 있었나요?',
      '안녕! 오늘 하루 잘 보냈어요?',
    ];

    final random = DateTime.now().millisecondsSinceEpoch % startMessages.length;
    final startMessage = startMessages[random];

    _messages.add(
      ChatMessage(
        text: startMessage,
        isFromTomato: true,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _currentMessage = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
                _processMessage(_currentMessage);
              }
            });
          },
        );
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  String _getTomatoImage() {
    if (_isBadStage) {
      switch (_growthStage) {
        case 0:
          return 'assets/images/tomato_stages/seed_bad.png';
        case 1:
          return 'assets/images/tomato_stages/sprout_bad.png';
        case 2:
          return 'assets/images/tomato_stages/young_tomato_bad.png';
        case 3:
          return 'assets/images/tomato_stages/tomato_bad.png';
        default:
          return 'assets/images/tomato_stages/seed_bad.png';
      }
    }

    switch (_growthStage) {
      case 0:
        return 'assets/images/tomato_stages/seed.png';
      case 1:
        return 'assets/images/tomato_stages/sprout.png';
      case 2:
        return 'assets/images/tomato_stages/young_tomato.png';
      case 3:
        return 'assets/images/tomato_stages/grown_tomato.png';
      default:
        return 'assets/images/tomato_stages/seed.png';
    }
  }

  void _checkGrowth(String response) async {
    _conversationCount++;
    if (_conversationCount % _growthThreshold == 0 && _growthStage < 3) {
      setState(() {
        _growthStage++;
        // 어른 토마토가 되면 팝업 표시
        if (_growthStage == 3) {
          _showGrowthCompletePopup = true;
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _processMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isFromTomato: false,
          timestamp: DateTime.now(),
        ),
      );
      _isProcessing = true;
    });
    _scrollToBottom();

    try {
      // Convert ChatMessage list to Map list
      final messageList = _messages
          .map(
            (msg) => {
              'role': msg.isFromTomato ? 'assistant' : 'user',
              'content': msg.text,
            },
          )
          .toList();

      final result = await _tomaChatService.sendMessage(message, messageList);
      final reply = result['reply'];
      final emotion = result['emotion'];

      // 감정 분석 결과에 따라 _isBadStage 설정
      setState(() {
        _isBadStage =
            emotion == 'sad' ||
            emotion == 'so_sad' ||
            emotion == 'angry' ||
            emotion == 'chaos';
      });

      // 대화 횟수 증가
      _conversationCount++;

      // 성장 단계: 대화 횟수로만 결정
      if (_conversationCount >= 9) {
        setState(() {
          _growthStage = 3; // 큰 토마토
          if (!_showGrowthCompletePopup) {
            _showGrowthCompletePopup = true;
          }
        });
      } else if (_conversationCount >= 6) {
        setState(() {
          _growthStage = 2; // 어린 토마토
        });
      } else if (_conversationCount >= 3) {
        setState(() {
          _growthStage = 1; // 새싹
        });
      } else {
        setState(() {
          _growthStage = 0; // 씨앗
        });
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: reply,
            isFromTomato: true,
            timestamp: DateTime.now(),
          ),
        );
        _isProcessing = false;
      });
      _scrollToBottom();

      // TTS로 토마토의 응답을 음성으로 출력
      await _ttsService.speak(reply);
    } catch (e) {
      print('Error processing message: $e');
      setState(() {
        _messages.add(
          ChatMessage(
            text: '죄송해요, 지금은 대화하기 어려워요. 잠시 후에 다시 시도해주세요.',
            isFromTomato: true,
            timestamp: DateTime.now(),
          ),
        );
        _isProcessing = false;
        _isBadStage = true;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _tomatoAnimationController.dispose();
    _speech.stop();
    _scrollController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/ui_elements/home_background_blur_ver.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _showChat
                  ? Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildAppBar(),
                            const SizedBox(height: 20),
                            _buildTomatoWithGauge(),
                            const Spacer(),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildChatArea(wide: true),
                              const SizedBox(height: 8),
                              _buildInputArea(),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildAppBar(),
                        const SizedBox(height: 20),
                        _buildTomatoWithGauge(),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: _buildChatButton(),
                        ),
                      ],
                    ),
              _buildGrowthCompletePopup(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTomatoWithGauge() {
    return Column(
      children: [
        _buildWaterDrops(),
        const SizedBox(height: 8),
        Image.asset(
          _getTomatoImage(),
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildWaterDrops() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              for (int i = 0; i < _growthStage + 1; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Image.asset(
                    'assets/images/icons/blue_drop_icon.png',
                    width: 32,
                    height: 32,
                  ),
                ),
              for (int i = 0; i < 4 - (_growthStage + 1); i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Image.asset(
                    'assets/images/icons/white_drop_icon.png',
                    width: 32,
                    height: 32,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatArea({bool wide = false}) {
    return Center(
      child: Container(
        width: wide
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.6,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return _buildMessageBubble(message);
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModeSelectionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.home, color: Color(0xFF1B5E20), size: 28),
          ),
          const Expanded(
            child: Text(
              '오늘의 토마토',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildChatButton() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _showChat = true;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic, color: Colors.white, size: 30),
                SizedBox(width: 16),
                Text(
                  '토마토와 대화하기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isFromTomato
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isFromTomato) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/icons/tomato_profile_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isFromTomato
                    ? Colors.white
                    : const Color(0xFFFFF3C0),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isFromTomato
                      ? const Radius.circular(8)
                      : const Radius.circular(20),
                  bottomRight: message.isFromTomato
                      ? const Radius.circular(20)
                      : const Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  color: message.isFromTomato
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFF1B5E20),
                ),
              ),
            ),
          ),
          if (!message.isFromTomato) ...[
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF1B5E20),
                size: 28,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isListening || _isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _isListening
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isListening ? Icons.mic : Icons.hourglass_empty,
                    color: _isListening
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isListening ? '듣고 있어요...' : '처리 중...',
                    style: TextStyle(
                      color: _isListening
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _currentMessage),
                  onChanged: (value) {
                    setState(() {
                      _currentMessage = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _processMessage(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isListening || _isProcessing
                    ? null
                    : _startListening,
                icon: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: _isListening || _isProcessing
                      ? Colors.grey
                      : const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCompletePopup() {
    if (!_showGrowthCompletePopup) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFF7D6).withOpacity(0.95),
                    const Color(0xFFFFE082).withOpacity(0.95),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    '토마토가 완전히 자랐어요!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 28),
                  Image.asset(
                    _getTomatoImage(),
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '오늘의 토마토',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 28,
                  color: Color(0xFF8D6E63),
                ),
                onPressed: () {
                  setState(() {
                    _showGrowthCompletePopup = false;
                  });
                },
                splashRadius: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isFromTomato;
  final DateTime timestamp;
  ChatMessage({
    required this.text,
    required this.isFromTomato,
    required this.timestamp,
  });
}

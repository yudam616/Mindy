import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/mode_selection_screen.dart';
import '../services/toma_chat_service.dart';
import '../models/app_state.dart';

class TomaChatScreen extends StatefulWidget {
  const TomaChatScreen({super.key});

  @override
  State<TomaChatScreen> createState() => _TomaChatScreenState();
}

class _TomaChatScreenState extends State<TomaChatScreen> {
  final TomaChatService _tomaChatService = TomaChatService();
  String _currentEmotion = 'neutral';
  bool _isLoading = false;
  String? _errorMessage;

  String _getEmotionImage(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'joy':
      case 'excited':
      case 'delighted':
      case 'cheerful':
      case 'pleased':
        return 'assets/images/tomato_stages/tomato_happy.png';
      case 'sad':
      case 'unhappy':
      case 'depressed':
      case 'gloomy':
      case 'down':
      case 'blue':
        return 'assets/images/tomato_stages/tomato_sad.png';
      case 'angry':
      case 'mad':
      case 'furious':
      case 'annoyed':
      case 'irritated':
      case 'frustrated':
        return 'assets/images/tomato_stages/tomato_angry.png';
      case 'very_sad':
      case 'heartbroken':
      case 'miserable':
      case 'devastated':
      case 'hopeless':
        return 'assets/images/tomato_stages/tomato_so_sad.png';
      case 'excited':
      case 'thrilled':
      case 'overjoyed':
      case 'ecstatic':
      case 'elated':
        return 'assets/images/tomato_stages/tomato_exiting.png';
      case 'confused':
      case 'chaotic':
      case 'overwhelmed':
      case 'disoriented':
      case 'mixed':
        return 'assets/images/tomato_stages/tomato_chaos.png';
      case 'neutral':
      case 'calm':
      case 'peaceful':
      case 'relaxed':
      case 'content':
      case 'okay':
      default:
        return 'assets/images/tomato_stages/tomato_soso.png';
    }
  }

  Widget _buildEmotionImage(String emotion) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          _getEmotionImage(emotion),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading emotion image: $error');
            return Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.emoji_emotions,
                size: 60,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinalScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '오늘의 대화가 끝났어요!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 20),
            _buildEmotionImage(_currentEmotion),
            const SizedBox(height: 20),
            Text(
              '지금 기분이 ${_getEmotionText(_currentEmotion)}이에요',
              style: const TextStyle(fontSize: 18, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModeSelectionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '홈으로 돌아가기',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmotionText(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'joy':
      case 'excited':
      case 'delighted':
      case 'cheerful':
      case 'pleased':
        return '행복해요';
      case 'sad':
      case 'unhappy':
      case 'depressed':
      case 'gloomy':
      case 'down':
      case 'blue':
        return '슬퍼요';
      case 'angry':
      case 'mad':
      case 'furious':
      case 'annoyed':
      case 'irritated':
      case 'frustrated':
        return '화나요';
      case 'very_sad':
      case 'heartbroken':
      case 'miserable':
      case 'devastated':
      case 'hopeless':
        return '매우 슬퍼요';
      case 'excited':
      case 'thrilled':
      case 'overjoyed':
      case 'ecstatic':
      case 'elated':
        return '신나요';
      case 'confused':
      case 'chaotic':
      case 'overwhelmed':
      case 'disoriented':
      case 'mixed':
        return '혼란스러워요';
      case 'neutral':
      case 'calm':
      case 'peaceful':
      case 'relaxed':
      case 'content':
      case 'okay':
      default:
        return '보통이에요';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildFinalScreen());
  }
}

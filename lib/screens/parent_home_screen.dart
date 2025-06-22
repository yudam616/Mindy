import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'emotion_report_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'mode_selection_screen.dart';
import '../services/toma_chat_service.dart';
import 'growth_guide_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final TomaChatService _tomaChatService = TomaChatService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _todayConversations = [];
  List<Map<String, dynamic>> _todayEmotions = [];
  Map<String, dynamic> _emotionState = {
    'overall_mood': 'neutral',
    'energy_level': 'medium',
  };
  List<String> _keywords = [];
  List<Map<String, String>> _specialNotes = [];
  DateTime _lastLoadTime = DateTime.now().subtract(const Duration(hours: 24));

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool _isCacheValid() {
    final now = DateTime.now();
    return now.difference(_lastLoadTime).inMinutes < 5; // 5분 동안 캐시 유효
  }

  Future<void> _loadData() async {
    try {
      // 캐시가 유효하면 로딩 상태를 표시하지 않음
      if (_isCacheValid() && _todayConversations.isNotEmpty) {
        print('캐시된 데이터 사용');
        return;
      }

      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      print('데이터 로딩 시작');

      // 오늘의 대화 기록 가져오기
      final conversations = _tomaChatService.getTodayConversations();
      print('대화 기록 로드됨: ${conversations.length}개');

      // 오늘의 감정 분석 결과 가져오기
      final emotions = _tomaChatService.getTodayEmotions();
      print('감정 기록 로드됨: ${emotions.length}개');

      if (conversations.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = '오늘의 대화 기록이 없습니다.';
        });
        return;
      }

      // 감정 상태 분석 (캐시된 결과 사용)
      final emotionState = await _tomaChatService.analyzeEmotionState(emotions);
      print('감정 상태 분석 완료: $emotionState');

      // 키워드 추출 (캐시된 결과 사용)
      final keywords = await _tomaChatService.extractKeywords(conversations);
      print('키워드 추출 완료: ${keywords.length}개');

      // 특이사항 추출 (캐시된 결과 사용)
      final specialNotes = await _tomaChatService.extractSpecialNotes(
        conversations,
      );
      print('특이사항 추출 완료: ${specialNotes.length}개');

      setState(() {
        _todayConversations = conversations;
        _todayEmotions = emotions;
        _emotionState = emotionState;
        _keywords = keywords;
        _specialNotes = specialNotes;
        _isLoading = false;
        _lastLoadTime = DateTime.now();
      });
    } catch (e) {
      print('데이터 로딩 오류: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return '데이터를 불러오는 중 오류가 발생했습니다.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 앱바
              _buildAppBar(),

              // 메인 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 환영 메시지
                        _buildWelcomeMessage(),
                        const SizedBox(height: 20),

                        // 오늘의 요약
                        _buildTodaySummary(),
                        const SizedBox(height: 20),

                        // 메뉴 버튼들
                        _buildMenuGrid(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '부모 모드',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  color: Color(0xFF1B5E20),
                  size: 28,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<AppState>().lockParentMode();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModeSelectionScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xFF1B5E20),
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.family_restroom,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕하세요!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      '오늘 아이의 감정 상태를 확인해보세요',
                      style: TextStyle(fontSize: 12, color: Color(0xFF388E3C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMenuCard(
          '성장 가이드',
          Icons.trending_up,
          const Color(0xFF4CAF50),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GrowthGuideScreen(),
              ),
            );
          },
        ),
        _buildMenuCard(
          '캘린더',
          Icons.calendar_today,
          const Color(0xFF4CAF50),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: const Color(0xFF4CAF50)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySummary() {
    if (_isLoading && !_isCacheValid()) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '데이터를 불러오는 중입니다...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '오늘의 요약',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 16),
          // 전체 기분
          Row(
            children: [
              Icon(
                _emotionState['overall_mood'] == 'good'
                    ? Icons.sentiment_very_satisfied
                    : _emotionState['overall_mood'] == 'neutral'
                    ? Icons.sentiment_neutral
                    : Icons.sentiment_very_dissatisfied,
                color: _emotionState['overall_mood'] == 'good'
                    ? Colors.green
                    : _emotionState['overall_mood'] == 'neutral'
                    ? Colors.orange
                    : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                '전체 기분: ${_emotionState['overall_mood'] == 'good'
                    ? '좋음'
                    : _emotionState['overall_mood'] == 'neutral'
                    ? '보통'
                    : '나쁨'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 에너지 레벨
          Row(
            children: [
              Icon(
                _emotionState['energy_level'] == 'high'
                    ? Icons.battery_full
                    : _emotionState['energy_level'] == 'medium'
                    ? Icons.battery_6_bar
                    : Icons.battery_2_bar,
                color: _emotionState['energy_level'] == 'high'
                    ? Colors.green
                    : _emotionState['energy_level'] == 'medium'
                    ? Colors.orange
                    : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                '에너지 레벨: ${_emotionState['energy_level'] == 'high'
                    ? '높음'
                    : _emotionState['energy_level'] == 'medium'
                    ? '보통'
                    : '낮음'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (_keywords.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              '주요 키워드',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _keywords.map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    keyword,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (_specialNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              '특이사항',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            ..._specialNotes.map((note) {
              IconData icon;
              Color color;

              switch (note['type']) {
                case 'experience':
                  icon = Icons.emoji_emotions;
                  color = Colors.green;
                  break;
                case 'difficulty':
                  icon = Icons.sentiment_dissatisfied;
                  color = Colors.orange;
                  break;
                case 'parent_note':
                  icon = Icons.note;
                  color = Colors.blue;
                  break;
                default:
                  icon = Icons.info;
                  color = Colors.grey;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['content'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (note['explanation'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              note['explanation']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/toma_chat_service.dart';

class EmotionReportScreen extends StatefulWidget {
  const EmotionReportScreen({super.key});

  @override
  State<EmotionReportScreen> createState() => _EmotionReportScreenState();
}

class _EmotionReportScreenState extends State<EmotionReportScreen> {
  final TomaChatService _tomaChatService = TomaChatService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _todayConversations = [];
  List<Map<String, dynamic>> _todayEmotions = [];
  Map<String, dynamic> _emotionState = {};
  List<String> _keywords = [];
  List<Map<String, String>> _specialNotes = [];
  String _overallMood = 'neutral';
  String _energyLevel = 'medium';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
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

      // 감정 상태 분석
      final emotionState = await _tomaChatService.analyzeEmotionState(emotions);
      print('감정 상태 분석 완료: $emotionState');

      // 키워드 추출
      final keywords = await _tomaChatService.extractKeywords(conversations);
      print('키워드 추출 완료: ${keywords.length}개');

      // 특이사항 추출
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
        _overallMood = emotionState['overall_mood'] ?? 'neutral';
        _energyLevel = emotionState['energy_level'] ?? 'medium';
        _isLoading = false;
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
              _buildAppBar(context),
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4CAF50),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '데이터를 불러오는 중...',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_hasError)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFF44336),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF4CAF50),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReportCard(),
                          const SizedBox(height: 20),
                          _buildMoodStatus(_emotionState),
                          const SizedBox(height: 20),
                          _buildSpecialNotes(_specialNotes),
                          const SizedBox(height: 20),
                          _buildKeywords(_keywords),
                          const SizedBox(height: 20),
                          _buildConversationGuide(_todayConversations),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF1B5E20),
              size: 28,
            ),
          ),
          const Expanded(
            child: Text(
              '감정 레포트',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF4CAF50),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 감정 레포트',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      '2024년 6월 16일',
                      style: TextStyle(fontSize: 14, color: Color(0xFF388E3C)),
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

  Widget _buildMoodStatus(Map<String, dynamic> emotionState) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            '오늘의 기분',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMoodItem(
                  '전체 기분',
                  _getMoodText(emotionState['overall_mood']),
                  _getMoodColor(emotionState['overall_mood']),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMoodItem(
                  '에너지',
                  _getEnergyText(emotionState['energy_level']),
                  _getEnergyColor(emotionState['energy_level']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '주요 감정 변화',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _buildEmotionGraph(emotionState['emotion_changes']),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionGraph(List<dynamic> emotionChanges) {
    if (emotionChanges.isEmpty) {
      return const Center(
        child: Text(
          '아직 감정 변화 데이터가 없어요',
          style: TextStyle(color: Color(0xFF388E3C)),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: emotionChanges.length,
      itemBuilder: (context, index) {
        final emotion = emotionChanges[index]['emotion'];
        return Container(
          width: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: _getEmotionHeight(emotion),
                decoration: BoxDecoration(
                  color: _getEmotionColor(emotion),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getEmotionEmoji(emotion),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMoodText(String mood) {
    switch (mood) {
      case 'good':
        return '좋음';
      case 'bad':
        return '나쁨';
      default:
        return '보통';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'good':
        return const Color(0xFF4CAF50);
      case 'bad':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getEnergyText(String energy) {
    switch (energy) {
      case 'high':
        return '높음';
      case 'low':
        return '낮음';
      default:
        return '보통';
    }
  }

  Color _getEnergyColor(String energy) {
    switch (energy) {
      case 'high':
        return const Color(0xFF2196F3);
      case 'low':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  double _getEmotionHeight(String emotion) {
    switch (emotion) {
      case 'happy':
      case 'exciting':
        return 80;
      case 'soso':
        return 50;
      case 'sad':
      case 'so_sad':
      case 'angry':
      case 'chaos':
        return 30;
      default:
        return 40;
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'happy':
        return const Color(0xFF4CAF50);
      case 'exciting':
        return const Color(0xFFFF9800);
      case 'sad':
      case 'so_sad':
        return const Color(0xFF2196F3);
      case 'angry':
        return const Color(0xFFF44336);
      case 'chaos':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case 'happy':
        return '😊';
      case 'exciting':
        return '🤩';
      case 'sad':
        return '😢';
      case 'so_sad':
        return '😭';
      case 'angry':
        return '😠';
      case 'chaos':
        return '😵‍💫';
      default:
        return '😐';
    }
  }

  Widget _buildMoodItem(String label, String status, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1B5E20)),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialNotes(List<Map<String, String>> notes) {
    if (notes.isEmpty) {
      return const Center(
        child: Text(
          '특이사항이 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
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

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(
              note['content'] ?? '',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              note['explanation'] ?? '',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeywords(List<String> keywords) {
    if (keywords.isEmpty) {
      return const Center(
        child: Text(
          '키워드가 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keywords.map((keyword) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  Widget _buildConversationGuide(List<Map<String, dynamic>> conversations) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            '대화 가이드',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 16),
          if (conversations.isEmpty)
            const Center(
              child: Text(
                '아직 대화 기록이 없어요',
                style: TextStyle(color: Color(0xFF388E3C)),
              ),
            )
          else
            Column(
              children: [
                _buildGuideItem(
                  '특이사항 유도 질문',
                  _generateFollowUpQuestion(conversations),
                ),
                const SizedBox(height: 12),
                _buildGuideItem(
                  '대화 주제 추천',
                  _generateTopicSuggestion(conversations),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _generateFollowUpQuestion(List<Map<String, dynamic>> conversations) {
    if (conversations.isEmpty) return '';

    final lastConversation = conversations.last['content'] as String;
    if (lastConversation.contains('친구')) {
      return '친구와 어떤 놀이를 했니?';
    } else if (lastConversation.contains('학교')) {
      return '학교에서 가장 재미있었던 일은 뭐야?';
    } else if (lastConversation.contains('놀이')) {
      return '오늘 어떤 놀이를 했니?';
    } else {
      return '오늘 가장 재미있었던 일은 뭐야?';
    }
  }

  String _generateTopicSuggestion(List<Map<String, dynamic>> conversations) {
    if (conversations.isEmpty) return '';

    final lastConversation = conversations.last['content'] as String;
    if (lastConversation.contains('친구')) {
      return '친구와 함께하고 싶은 새로운 놀이가 있니?';
    } else if (lastConversation.contains('학교')) {
      return '내일 학교에서 기대되는 일이 있니?';
    } else if (lastConversation.contains('놀이')) {
      return '다음에 하고 싶은 새로운 놀이가 있니?';
    } else {
      return '내일 하고 싶은 일이 있니?';
    }
  }

  Widget _buildGuideItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, color: Color(0xFF388E3C)),
          ),
        ),
      ],
    );
  }
}

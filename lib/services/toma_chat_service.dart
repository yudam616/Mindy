import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TomaChatService {
  static final TomaChatService _instance = TomaChatService._internal();
  factory TomaChatService() => _instance;
  TomaChatService._internal();

  final String _apiKey = ApiConfig.openAiApiKey;
  final String _baseUrl = '${ApiConfig.openAiBaseUrl}/chat/completions';
  final String _sentimentUrl = '${ApiConfig.openAiBaseUrl}/chat/completions';

  final List<Map<String, dynamic>> _conversationHistory = [];
  final List<Map<String, dynamic>> _emotionHistory = [];

  Map<String, dynamic> _cachedEmotionState = {};
  List<String> _cachedKeywords = [];
  List<Map<String, String>> _cachedSpecialNotes = [];
  DateTime _lastAnalysisTime = DateTime.now().subtract(
    const Duration(hours: 24),
  );

  bool _isCacheValid() {
    final now = DateTime.now();
    return now.difference(_lastAnalysisTime).inHours < 1;
  }

  List<Map<String, dynamic>> getConversationHistory() {
    try {
      return _conversationHistory;
    } catch (e) {
      throw Exception('대화 기록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  List<Map<String, dynamic>> getEmotionHistory() {
    try {
      return _emotionHistory;
    } catch (e) {
      throw Exception('감정 분석 결과를 가져오는 중 오류가 발생했습니다.');
    }
  }

  List<Map<String, dynamic>> getTodayConversations() {
    try {
      final now = DateTime.now();
      final todayConversations = _conversationHistory
          .where((chat) {
            final chatTime = DateTime.parse(chat['timestamp']);
            return chatTime.year == now.year &&
                chatTime.month == now.month &&
                chatTime.day == now.day;
          })
          .map(
            (chat) => {
              'content': chat['content'],
              'timestamp': chat['timestamp'],
            },
          )
          .toList();

      print('오늘의 대화 기록: ${todayConversations.length}개');
      return todayConversations;
    } catch (e) {
      print('대화 기록 가져오기 오류: $e');
      throw Exception('오늘의 대화 기록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  List<Map<String, dynamic>> getTodayEmotions() {
    try {
      final now = DateTime.now();
      final todayEmotions = _emotionHistory
          .where((emotion) {
            final emotionTime = DateTime.parse(emotion['timestamp']);
            return emotionTime.year == now.year &&
                emotionTime.month == now.month &&
                emotionTime.day == now.day;
          })
          .map(
            (emotion) => {
              'emotion': emotion['emotion'],
              'timestamp': emotion['timestamp'],
            },
          )
          .toList();

      print('오늘의 감정 기록: ${todayEmotions.length}개');
      return todayEmotions;
    } catch (e) {
      print('감정 기록 가져오기 오류: $e');
      throw Exception('오늘의 감정 분석 결과를 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<Map<String, dynamic>> analyzeEmotionState(
    List<Map<String, dynamic>> emotions,
  ) async {
    try {
      if (emotions.isEmpty) {
        print('감정 상태 분석: 감정 기록 없음');
        return {'overall_mood': 'neutral', 'energy_level': 'medium'};
      }

      if (_isCacheValid() && _cachedEmotionState.isNotEmpty) {
        print('캐시된 감정 상태 반환');
        return _cachedEmotionState;
      }

      print('감정 상태 분석 시작: ${emotions.length}개의 감정');
      final allEmotions = emotions
          .map((e) => e['emotion'] as String)
          .join('\n');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''다음 감정 기록을 분석하여 전체적인 기분과 에너지 레벨을 판단해주세요.
감정 카테고리: happy, sad, so_sad, angry, exciting, soso, chaos
응답 형식:
{
  "overall_mood": "good/neutral/bad",
  "energy_level": "high/medium/low",
  "explanation": "분석 결과에 대한 설명"
}''',
            },
            {'role': 'user', 'content': allEmotions},
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('GPT 응답: $content');
        final analysis = jsonDecode(content);
        print('감정 상태 분석 결과: $analysis');

        _cachedEmotionState = analysis;
        _lastAnalysisTime = DateTime.now();

        return analysis;
      } else {
        print('감정 상태 분석 API 오류: ${response.statusCode}');
        throw Exception('감정 상태 분석 중 API 오류가 발생했습니다.');
      }
    } catch (e) {
      print('감정 상태 분석 오류: $e');
      throw Exception('감정 상태 분석 중 오류가 발생했습니다.');
    }
  }

  Future<List<String>> extractKeywords(
    List<Map<String, dynamic>> conversations,
  ) async {
    try {
      if (conversations.isEmpty) {
        print('키워드 추출: 대화 기록 없음');
        return [];
      }

      if (_isCacheValid() && _cachedKeywords.isNotEmpty) {
        print('캐시된 키워드 반환');
        return _cachedKeywords;
      }

      print('키워드 추출 시작: ${conversations.length}개의 대화');
      final allText = conversations
          .map((chat) => chat['content'] as String)
          .join('\n');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''다음 대화 내용을 분석하여 가장 중요한 3개의 키워드를 추출해주세요.
키워드는 단순히 자주 나온 단어가 아니라, 대화의 맥락과 의미를 가장 잘 나타내는 단어여야 합니다.
각 키워드에 대해 간단한 설명도 함께 제공해주세요.
응답 형식:
{
  "keywords": [
    {"word": "키워드1", "explanation": "설명1"},
    {"word": "키워드2", "explanation": "설명2"},
    {"word": "키워드3", "explanation": "설명3"}
  ]
}''',
            },
            {'role': 'user', 'content': allText},
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('GPT 응답: $content');
        final keywordsData = jsonDecode(content);
        final keywords = (keywordsData['keywords'] as List)
            .map((k) => k['word'] as String)
            .toList();
        print('추출된 키워드: $keywords');

        _cachedKeywords = keywords;

        return keywords;
      } else {
        print('키워드 추출 API 오류: ${response.statusCode}');
        throw Exception('키워드 추출 중 API 오류가 발생했습니다.');
      }
    } catch (e) {
      print('키워드 추출 오류: $e');
      throw Exception('키워드 추출 중 오류가 발생했습니다.');
    }
  }

  Future<List<Map<String, String>>> extractSpecialNotes(
    List<Map<String, dynamic>> conversations,
  ) async {
    try {
      if (conversations.isEmpty) {
        print('특이사항 추출: 대화 기록 없음');
        return [];
      }

      if (_isCacheValid() && _cachedSpecialNotes.isNotEmpty) {
        print('캐시된 특이사항 반환');
        return _cachedSpecialNotes;
      }

      print('특이사항 추출 시작: ${conversations.length}개의 대화');
      final allText = conversations
          .map((chat) => chat['content'] as String)
          .join('\n');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''다음 대화 내용을 분석하여 중요한 특이사항을 추출해주세요.
다음 카테고리로 분류해주세요:
1. 경험 (experience): 아이가 경험한 재미있거나 특별한 일
2. 어려움 (difficulty): 아이가 겪은 어려움이나 걱정거리
3. 부모님께 전달할 사항 (parent_note): 부모가 알아야 할 중요한 일정이나 이벤트

각 특이사항에 대해 간단한 설명도 함께 제공해주세요.
응답 형식:
{
  "notes": [
    {"type": "experience", "content": "내용1", "explanation": "설명1"},
    {"type": "difficulty", "content": "내용2", "explanation": "설명2"},
    {"type": "parent_note", "content": "내용3", "explanation": "설명3"}
  ]
}''',
            },
            {'role': 'user', 'content': allText},
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('GPT 응답: $content');
        final notesData = jsonDecode(content);
        final notes = (notesData['notes'] as List)
            .map(
              (note) => {
                'type': note['type'] as String,
                'content': note['content'] as String,
                'explanation': note['explanation'] as String,
              },
            )
            .toList();
        print('추출된 특이사항: ${notes.length}개');

        _cachedSpecialNotes = notes;

        return notes;
      } else {
        print('특이사항 추출 API 오류: ${response.statusCode}');
        throw Exception('특이사항 추출 중 API 오류가 발생했습니다.');
      }
    } catch (e) {
      print('특이사항 추출 오류: $e');
      throw Exception('특이사항 추출 중 오류가 발생했습니다.');
    }
  }

  Future<Map<String, dynamic>> sendMessage(
    String message,
    List<Map<String, dynamic>> conversationHistory,
  ) async {
    try {
      if (message.trim().isEmpty) {
        throw Exception('메시지를 입력해주세요.');
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are Toma, a friendly and caring tomato character. You should be cheerful, supportive, and show interest in the child\'s daily life. Keep your responses short, simple, and engaging. Use emojis occasionally to make the conversation more fun. Focus on topics like school, friends, hobbies, and daily activities.',
            },
            ...conversationHistory
                .map((msg) => {'role': msg['role'], 'content': msg['content']})
                .toList(),
            {'role': 'user', 'content': message},
          ],
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];

        final emotionResponse = await http.post(
          Uri.parse(_sentimentUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo',
            'messages': [
              {
                'role': 'system',
                'content':
                    'Analyze the emotional tone of the following conversation and classify it into one of these categories: happy, sad, so_sad, angry, exciting, soso, chaos. Return only the category name.',
              },
              {'role': 'user', 'content': message},
            ],
            'temperature': 0.3,
            'max_tokens': 10,
          }),
        );

        String emotion = 'soso';
        if (emotionResponse.statusCode == 200) {
          final emotionData = jsonDecode(emotionResponse.body);
          emotion = emotionData['choices'][0]['message']['content']
              .trim()
              .toLowerCase();
        }

        final timestamp = DateTime.now().toIso8601String();
        _conversationHistory.add({
          'role': 'user',
          'content': message,
          'timestamp': timestamp,
        });
        _conversationHistory.add({
          'role': 'assistant',
          'content': reply,
          'timestamp': timestamp,
        });

        _emotionHistory.add({'emotion': emotion, 'timestamp': timestamp});

        print('대화 기록 저장됨: ${_conversationHistory.length}개');
        print('감정 기록 저장됨: ${_emotionHistory.length}개');

        return {'reply': reply, 'emotion': emotion};
      } else {
        throw Exception('API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('메시지 전송 중 오류가 발생했습니다.');
    }
  }

  void clearConversationHistory() {
    try {
      _conversationHistory.clear();
      _emotionHistory.clear();
    } catch (e) {
      throw Exception('대화 기록 삭제 중 오류가 발생했습니다.');
    }
  }
}

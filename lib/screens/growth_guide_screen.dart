import 'package:flutter/material.dart';

class GrowthGuideScreen extends StatelessWidget {
  const GrowthGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '성장 가이드',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGrowthStageCard(
                  '씨앗 단계',
                  '새로운 시작',
                  'assets/images/tomato_stages/seed.png',
                  '아이가 감정을 표현하기 시작하는 단계입니다.',
                  [
                    '아이의 감정 표현을 인정하고 칭찬해주세요.',
                    '감정에 대한 이야기를 나누는 시간을 가져보세요.',
                    '아이가 편안하게 감정을 표현할 수 있도록 도와주세요.',
                  ],
                ),
                const SizedBox(height: 16),
                _buildGrowthStageCard(
                  '새싹 단계',
                  '조금씩 자라기',
                  'assets/images/tomato_stages/sprout.png',
                  '아이가 자신의 감정을 더 잘 이해하고 표현하는 단계입니다.',
                  [
                    '아이의 감정 변화에 주의 깊게 관찰해주세요.',
                    '감정의 원인에 대해 이야기해보세요.',
                    '긍정적인 감정 표현을 더 많이 하도록 격려해주세요.',
                  ],
                ),
                const SizedBox(height: 16),
                _buildGrowthStageCard(
                  '어린 토마토 단계',
                  '빨갛게 익어가기',
                  'assets/images/tomato_stages/young_tomato.png',
                  '아이가 감정을 조절하고 타인의 감정을 이해하기 시작하는 단계입니다.',
                  [
                    '감정 조절 방법을 함께 배워보세요.',
                    '타인의 감정을 이해하는 방법을 가르쳐주세요.',
                    '감정에 대한 대화를 더 깊이 나누어보세요.',
                  ],
                ),
                const SizedBox(height: 16),
                _buildGrowthStageCard(
                  '성장한 토마토 단계',
                  '완전히 익음',
                  'assets/images/tomato_stages/grown_tomato.png',
                  '아이가 감정을 잘 조절하고 타인의 감정을 이해하는 단계입니다.',
                  [
                    '아이의 감정 지능 발달을 칭찬해주세요.',
                    '더 복잡한 감정 상황에 대해 이야기해보세요.',
                    '감정을 긍정적으로 활용하는 방법을 가르쳐주세요.',
                  ],
                ),
                const SizedBox(height: 16),
                _buildTipsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthStageCard(
    String title,
    String subtitle,
    String imagePath,
    String description,
    List<String> tips,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF4CAF50)),
            const SizedBox(height: 12),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  '부모님을 위한 팁',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem('감정 표현을 칭찬해주세요', '아이가 감정을 표현할 때마다 긍정적으로 반응해주세요.'),
            _buildTipItem('감정에 이름을 붙여주세요', '아이가 느끼는 감정의 이름을 알려주고 이해를 도와주세요.'),
            _buildTipItem('감정을 인정해주세요', '아이의 감정을 부정하지 말고 인정해주세요.'),
            _buildTipItem(
              '감정 조절 방법을 가르쳐주세요',
              '깊은 호흡이나 산책과 같은 감정 조절 방법을 알려주세요.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF388E3C)),
          ),
        ],
      ),
    );
  }
}

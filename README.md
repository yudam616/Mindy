# Mindy - 토마토 성장을 통한 어린이 감정 분석 앱

<div align="center">
  <img src="assets/images/icons/main.png" alt="Mindy Logo" width="200"/>
</div>

## 📱 프로젝트 소개

Mindy는 아이들이 토마토 캐릭터와 대화하면서 감정을 표현하고, AI가 이를 분석하여 부모에게 자녀의 감정 상태를 리포트로 제공하는 모바일 애플리케이션입니다.

## 🌟 주요 기능

### 🍅 토마토와의 대화
- **음성 인식**: 아이가 음성으로 토마토와 대화
- **TTS 음성 출력**: 토마토의 응답을 음성으로 들려줌
- **감정 분석**: AI가 대화 내용을 분석하여 감정 상태 파악
- **토마토 성장**: 대화 횟수에 따라 토마토가 성장 (씨앗 → 새싹 → 어린 토마토 → 성장한 토마토)

### 📊 부모 모드
- **감정 리포트**: 일일 감정 분석 결과 제공
- **키워드 추출**: 대화에서 중요한 키워드 자동 추출
- **특이사항 알림**: 부모가 알아야 할 중요한 사항 알림
- **성장 가이드**: 토마토 성장 단계별 육아 조언

### ⚙️ 설정 기능
- **비밀번호 변경**: 부모 모드 접근 비밀번호 관리
- **알림 설정**: 앱 알림 및 소리 설정
- **이용약관**: 앱 이용약관 확인


## 📁 프로젝트 구조

```
lib/
├── config/
│   └── api_config.dart          # API 설정
├── models/
│   └── app_state.dart           # 앱 상태 모델
├── screens/
│   ├── mode_selection_screen.dart    # 모드 선택 화면
│   ├── child_home_screen.dart        # 아이 모드 홈
│   ├── parent_home_screen.dart       # 부모 모드 홈
│   ├── emotion_report_screen.dart    # 감정 리포트
│   ├── settings_screen.dart          # 설정
│   ├── terms_screen.dart             # 이용약관
│   └── ...
├── services/
│   ├── toma_chat_service.dart        # 토마토 채팅 서비스
│   ├── tts_service.dart              # TTS 서비스
│   └── app_state.dart                # 앱 상태 관리
└── widgets/                          # 재사용 가능한 위젯들
```

## 🚀 설치 및 실행

### Prerequisites
- Flutter SDK (3.8.1 이상)
- Dart SDK
- Android Studio / VS Code
- OpenAI API 키


## 🔧 환경 설정

### OpenAI API 키 설정

#### 방법 1: 명령줄에서 직접 설정
```bash
flutter run --dart-define=OPENAI_API_KEY=sk-your-actual-api-key-here
```

#### 방법 2: 환경변수로 설정
**Windows:**
```cmd
set OPENAI_API_KEY=sk-your-actual-api-key-here
flutter run
```

**macOS/Linux:**
```bash
export OPENAI_API_KEY=sk-your-actual-api-key-here
flutter run
```

#### 방법 3: IDE에서 설정
Android Studio나 VS Code에서 실행 구성에 환경변수를 추가:
```json
{
  "args": [
    "--dart-define=OPENAI_API_KEY=sk-your-actual-api-key-here"
  ]
}
```

### API 키 발급 방법
1. [OpenAI Platform](https://platform.openai.com/)에 가입
2. API Keys 섹션에서 새 키 생성
3. 생성된 키를 복사하여 위의 방법 중 하나로 설정

### 권한 설정
앱에서 다음 권한이 필요합니다:
- 음성 인식 권한
- 인터넷 접근 권한
- 저장소 접근 권한

## 📱 사용법

### 아이 모드
1. 앱 실행 후 "아이 모드" 선택
2. 토마토와 음성으로 대화
3. 대화 횟수에 따라 토마토가 성장
4. 감정에 따라 토마토 표정 변화

### 부모 모드
1. 비밀번호 입력 후 "부모 모드" 접근
2. 일일 감정 리포트 확인
3. 키워드 및 특이사항 확인
4. 성장 가이드 참고

---

**Mindy** - 아이들의 감정을 이해하는 토마토 친구 🍅
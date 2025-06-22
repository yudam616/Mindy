import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/mode_selection_screen.dart';
import 'services/app_state.dart';

void main() {
  runApp(const TomatoEmotionApp());
}

class TomatoEmotionApp extends StatelessWidget {
  const TomatoEmotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: '토마토 감정 분석',
        theme: ThemeData(
          primarySwatch: Colors.green,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Pretendard',
        ),
        home: const ModeSelectionScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

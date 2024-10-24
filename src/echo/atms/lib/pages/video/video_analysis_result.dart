import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoAnalysisResult extends StatelessWidget {
  final String yoloText;
  final String lstmText;
  final String summaryText;
  final String ragText;
  final String followUpAnswer;

  const VideoAnalysisResult({
    Key? key,
    required this.yoloText,
    required this.lstmText,
    required this.summaryText,
    required this.ragText,
    required this.followUpAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영상 분석 결과'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('YOLO 분석 결과', yoloText),
            _buildSection('LSTM 분석 결과', lstmText),
            _buildSection('요약', summaryText),
            _buildSection('RAG 분석', ragText),
            _buildSection('종합 분석', followUpAnswer),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(content),
        SizedBox(height: 16),
      ],
    );
  }

  Future<void> saveAnalysisResult(
      BuildContext context, Map<String, dynamic> result) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.userEmail;

    if (userEmail == null) {
      print('User not logged in');
      return;
    }

    final url = Uri.parse(
        'https://c238-123-142-55-115.ngrok-free.app/save_analysis_result');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': userEmail,
        'result': result,
      }),
    );

    if (response.statusCode == 200) {
      print('Analysis result saved successfully');
    } else {
      print('Failed to save analysis result');
    }
  }
}

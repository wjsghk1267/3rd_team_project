import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'login_widget.dart' show LoginWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for emailAddress widget.
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for password widget.
  TextEditingController? textController2;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? textController2Validator;

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  FocusNode? textFieldFocusNode2;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textController1?.dispose();
    textController2?.dispose();
    textFieldFocusNode1?.dispose();
    textFieldFocusNode2?.dispose();
  }

  Future<bool> login(String email, String password) async {
    // 여기에 실제 로그인 로직을 구현하세요.
    // 예를 들어, API 호출을 통해 서버에 로그인 요청을 보내고 결과를 받아올 수 있습니다.
    // 지금은 간단히 이메일과 비밀번호가 비어있지 않으면 로그인 성공으로 처리합니다.
    return email.isNotEmpty && password.isNotEmpty;
  }
}

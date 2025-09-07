import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import 'main_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  final _secure = const FlutterSecureStorage(); // 안전 저장소 인스턴스

  bool _obscureText = true;
  bool _isLoading = false;

  // 실제 API 주소로 교체
  static const LOGIN_API_URL = "실제 api 주소";
  static const KAKAO_LOGIN_API_URL = "실제 api 주소";

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _debug() { //임시 함수
    Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScaffold(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
    );
  }


  // 토큰 저장 헬퍼
  Future<void> _saveTokens({String? access, String? refresh}) async {
    if (access != null && access.isNotEmpty) {
      await _secure.write(key: 'access_token', value: access);
    }
    if (refresh != null && refresh.isNotEmpty) {
      await _secure.write(key: 'refresh_token', value: refresh); // ✅ 리프레시 저장
    }
  }



  Future<void> _login() async {
    if (_isLoading) return;

    final id = _idController.text.trim();
    final pw = _pwController.text.trim(); // ✅ 오타 수정

    if (id.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("아이디와 비밀번호를 입력해주세요.")),
      );
      return; // ✅ 즉시 종료
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(LOGIN_API_URL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": id, "password": pw}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken  = (data['accessToken'] ?? data['token'] ?? data['access_token'])?.toString();
        final refreshToken = (data['refreshToken'] ?? data['refresh_token'])?.toString();

        if (accessToken == null || accessToken.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("로그인 응답 형식이 올바르지 않습니다.")),
          );
          return;
        }

        // ✅ 여기서 안전 저장
        await _saveTokens(access: accessToken, refresh: refreshToken);

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScaffold(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        final msg = (response.body.isNotEmpty) ? response.body : "code ${response.statusCode}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 실패: $msg")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 에러: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  Future<void> _loginWithKakao() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final installed = await isKakaoTalkInstalled();

      // 1) 기본 로그인 (카카오톡 앱 우선, 없으면 계정 로그인)
      OAuthToken token = installed
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      // 2) 사용자 정보 조회
      var me = await UserApi.instance.me();

      // 3) 필요한 동의 스코프 확인 후 추가 동의 요청
      final needScopes = <String>[];
      if (me.kakaoAccount?.emailNeedsAgreement == true &&
          (me.kakaoAccount?.email == null || (me.kakaoAccount?.email?.isEmpty ?? true))) {
        needScopes.add('account_email');
      }
      if (me.kakaoAccount?.profileNeedsAgreement == true) {
        needScopes.add('profile_nickname');
      }

      if (needScopes.isNotEmpty) {
        token = await UserApi.instance.loginWithNewScopes(needScopes);
        me = await UserApi.instance.me(); // 동의 후 다시 조회
      }

      // 백엔드 소셜 로그인 엔드포인트로 카카오 토큰 전달
      final response = await http.post(
        Uri.parse(KAKAO_LOGIN_API_URL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "provider": "kakao",
          "accessToken": token.accessToken,
          // 콘솔에서 OIDC 설정을 켠 경우에만 값이 담김
          "idToken": token.idToken,
          // 참고용(서버는 토큰으로 검증 권장)
          // "profile": {
          //   "email": me.kakaoAccount?.email,
          //   "nickname": me.kakaoAccount?.profile?.nickname,
          // },
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken  = (data['accessToken'] ?? data['token'] ?? data['access_token'])?.toString();
        final refreshToken = (data['refreshToken'] ?? data['refresh_token'])?.toString();

        if (accessToken == null || accessToken.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("카카오 로그인 응답 형식이 올바르지 않습니다.")),
          );
          return;
        }

        // ✅ 리프레시 포함 저장
        await _saveTokens(access: accessToken, refresh: refreshToken);

        // appToken / refreshToken 저장
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScaffold(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        final msg = (response.body.isNotEmpty) ? response.body : "code ${response.statusCode}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("카카오 로그인 실패: $msg")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카카오 로그인 예외: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale.s30,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text(
                  '환영합니다!',
                  style: AppTextStyles.title1.copyWith(color: AppColors.primary.s500),
                ),
                const SizedBox(height: 40),

                // 아이디
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      hintText: '아이디',
                      hintStyle: AppTextStyles.body2_1.copyWith(color: AppColors.grayscale.s500),
                      filled: true,
                      fillColor: AppColors.grayscale.s30,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayscale.s500, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayscale.s500, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayscale.s500, width: 2),
                      ),
                    ),
                  ),
                ),

                // 비밀번호
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: _pwController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      hintStyle: AppTextStyles.body2_1.copyWith(color: AppColors.grayscale.s500),
                      filled: true,
                      fillColor: AppColors.grayscale.s30,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayscale.s500, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayscale.s500, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayscale.s500, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.grayscale.s500,
                        ),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 로그인 버튼
                GestureDetector(
                  onTap: _isLoading ? null : _login,
                  child: AbsorbPointer(
                    absorbing: _isLoading,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.s500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              '로그인',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.title7.copyWith(color: Colors.white, height: 1.0),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: _debug,
                  child: Container(
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.s500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              '디버그 모드',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.title7.copyWith(color: Colors.white, height: 1.0),
                            ),
                    ),
                ),

                const SizedBox(height: 24),

                // 소셜 로그인 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialCircleButton(
                      backgroundColor: const Color(0xFFFEE500),
                      onTap: _loginWithKakao,
                      child: Image.asset('lib/카카오톡.png', width: 40, height: 40),
                    ),
                    const SizedBox(width: 20),
                    _SocialCircleButton(
                      backgroundColor: AppColors.grayscale.s30,
                      border: Border.all(color: AppColors.grayscale.s500),
                      onTap: () {}, // TODO: 구글
                      child: Image.asset('lib/구글.png', width: 28, height: 28),
                    ),
                    const SizedBox(width: 20),
                    _SocialCircleButton(
                      backgroundColor: AppColors.grayscale.s30,
                      onTap: () {}, // TODO: 네이버
                      child: Image.asset('lib/네이버.png', width: 55, height: 55),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Border? border;
  final VoidCallback onTap;

  const _SocialCircleButton({
    required this.child,
    required this.backgroundColor,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

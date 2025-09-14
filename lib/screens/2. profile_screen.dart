import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:midas_project/models/favorite_model.dart';
import 'package:midas_project/services/favorite_service.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import 'auth_choice_screen.dart'; // ✅ 로그아웃 후 이동 화면

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 0=집/회사, 1=자주가는곳, 2=버스
  int selectedIndex = 0;

  final _favoriteService = FavoriteService();
  List<Favorite> _allFavorites = [];

  final _menus = const [
    ("home", "집/회사"),
    ("mappointwave", "자주가는곳"),
    ("bus", "버스"),
  ];

  // ---- 사용자 닉네임 로딩용 ----
  static const String _baseUrl = "http://3.36.52.161:8000";
  String? _userName;
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadUserName();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _favoriteService.getFavorites();
      if (mounted) {
        setState(() {
          _allFavorites = favorites;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('즐겨찾기 목록을 불러오는 데 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteFavorite(String id) async {
    try {
      await _favoriteService.removeFavorite(id);
      // 삭제 성공 후 목록을 다시 불러옴
      _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('즐겨찾기 삭제에 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadUserName() async {
    try {
      const secure = FlutterSecureStorage();
      final token = await secure.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        if (mounted) setState(() => _isLoadingName = false);
        return;
      }

      final res = await http.get(
        Uri.parse("$_baseUrl/users/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _userName = data['userName']?.toString();
          _isLoadingName = false;
        });
      } else {
        debugPrint("GET /users/me failed: ${res.statusCode} ${res.body}");
        setState(() => _isLoadingName = false);
      }
    } catch (e) {
      debugPrint("GET /users/me error: $e");
      if (mounted) setState(() => _isLoadingName = false);
    }
  }

  // ===== 로그아웃 처리 =====
  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('로그아웃 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('아니오'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('예'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldLogout) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    const secure = FlutterSecureStorage();
    // 저장된 토큰 제거
    await secure.delete(key: 'access_token');
    await secure.delete(key: 'token_type');

    if (!mounted) return;
    // 스택 비우고 로그인/회원가입 선택 화면으로
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(
              userName: _isLoadingName ? null : (_userName ?? '닉네임'),
              onTapSettings: _confirmLogout, // ✅ 설정 아이콘 → 로그아웃 확인
            ),
            Container(
              height: 60,
              padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.grayscale.s100, width: 1.0),
                  bottom: BorderSide(color: AppColors.grayscale.s100, width: 1.0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(_menus.length, (i) {
                  final item = _menus[i];
                  final isSelected = i == selectedIndex;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: i == _menus.length - 1 ? 0 : 36,
                    ),
                    child: _CategoryTab(
                      iconName: item.$1,
                      label: item.$2,
                      selected: isSelected,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: _buildContent(selectedIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int index) {
    List<Favorite> filteredItems = [];
    String title = "";

    switch (index) {
      case 0: // 집/회사
        title = "즐겨찾기";
        filteredItems = _allFavorites.where((fav) {
          return fav.type == FavoriteType.place &&
              (fav.placeCategory == 'home' || fav.placeCategory == 'work');
        }).toList();
        break;
      case 1: // 자주가는곳
        title = "자주가는곳";
        filteredItems = _allFavorites.where((fav) {
          return fav.type == FavoriteType.place &&
              (fav.placeCategory != 'home' && fav.placeCategory != 'work');
        }).toList();
        break;
      case 2: // 버스/정류장
      default:
        title = "버스/정류장";
        filteredItems = _allFavorites.where((fav) {
          return fav.type == FavoriteType.bus || fav.type == FavoriteType.busStop;
        }).toList();
        break;
    }
    return _FavoriteList(
      title: title,
      items: filteredItems,
      onDelete: _deleteFavorite,
    );
  }
}

/// ===== 상단 프로필 헤더 =====
class _ProfileHeader extends StatelessWidget {
  final String? userName;
  final VoidCallback onTapSettings; // ✅ 설정 아이콘 콜백
  const _ProfileHeader({
    this.userName,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(19, 20, 8, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.grayscale.s500,
            child: Icon(Icons.person, color: AppColors.grayscale.s30),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Text(
                userName ?? '불러오는 중...',
                style: AppTextStyles.title7
                    .copyWith(color: AppColors.grayscale.s900),
              ),
              IconButton(
                icon:
                    Icon(Icons.edit, size: 18, color: AppColors.grayscale.s500),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  // 닉네임 수정 다이얼로그 (서버 연동은 추후)
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      final controller = TextEditingController(text: userName);
                      return AlertDialog(
                        title: const Text("닉네임 수정"),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: "새 닉네임 입력",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("취소"),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: 서버에 닉네임 수정 API 연동
                              Navigator.pop(ctx);
                            },
                            child: const Text("확인"),
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Image.asset('lib/assets/images/bell.png', width: 24, height: 24),
            onPressed: () {
              // 알림 페이지 이동 (필요 시 구현)
            },
          ),
          IconButton(
            icon: Image.asset('lib/assets/images/settings.png', width: 24, height: 24),
            onPressed: onTapSettings, // ✅ 로그아웃 확인 다이얼로그
          ),
        ],
      ),
    );
  }
}

/// ===== 탭 버튼 =====
class _CategoryTab extends StatelessWidget {
  final String iconName;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.iconName,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        selected ? AppColors.grayscale.s900 : AppColors.grayscale.s500;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/${iconName}_${selected ? 'selected' : 'unselected'}.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption2_2.copyWith(
                color: textColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== 리스트 공통 위젯 =====
class _FavoriteList extends StatelessWidget {
  final String title;
  final List<Favorite> items;
  final Function(String) onDelete;

  const _FavoriteList({
    required this.title,
    required this.items,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grayscale.s30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 12),
            child: Text(
              title,
              style: AppTextStyles.title7
                  .copyWith(color: AppColors.grayscale.s900),
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.grayscale.s100),

          // 리스트
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                String smallText = item.name;
                String mainText = '';
                String itemIconName = 'mappointwave'; // 기본 아이콘

                if (item.type == FavoriteType.place) {
                  mainText = item.address ?? '주소 정보 없음';
                  itemIconName = (item.placeCategory == 'home' ||
                          item.placeCategory == 'work')
                      ? 'home'
                      : 'mappointwave';
                } else if (item.type == FavoriteType.bus) {
                  mainText = item.busNumber ?? '버스 번호 없음';
                  itemIconName = 'bus';
                } else if (item.type == FavoriteType.busStop) {
                  smallText = item.stationName ?? '정류장 이름 없음';
                  mainText = item.stationId ?? '정류장 번호 없음';
                  itemIconName = 'bus';
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12), // 피그마상에선 양 옆 간격 20이 맞는데 실제론 8로 조정한게 맞음 (왜지..?)
                      child: Row(
                        children: [
                          Image.asset(
                            'lib/assets/images/${itemIconName}_selected.png',
                            height: 24,
                            width: 24,
                            color: AppColors.grayscale.s900,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  smallText,
                                  style: AppTextStyles.caption2_1.copyWith(
                                    color: AppColors.grayscale.s500,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mainText,
                                  style: AppTextStyles.body1_1.copyWith(
                                    color: AppColors.grayscale.s900,
                                    height: 1.4,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: AppColors.grayscale.s500, size: 20),
                            onPressed: () => onDelete(item.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.grayscale.s100,
                    ),
                  ],
                );
              },
            ),
          ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.grayscale.s200),
                  backgroundColor: AppColors.grayscale.s100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // TODO: 주소 등록 화면 이동
                },
                child: Text(
                  "주소 등록하기",
                  style: AppTextStyles.title7
                      .copyWith(color: AppColors.grayscale.s900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

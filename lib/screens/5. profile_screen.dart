import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 0=집/회사, 1=자주가는곳, 2=버스
  int selectedIndex = 0;

  final _menus = const [
    ("home", "집/회사"),
    ("mappointwave", "자주가는곳"),
    ("bus", "버스"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _ProfileHeader(),
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
    final currentIconName = _menus[index].$1;
    switch (index) {
      case 0:
        return _FavoriteList(
          title: "즐겨찾기",
          items: const [
            ("집", "대구광역시 00군 00"),
            ("회사", "대구광역시 00군 00"),
            ("집", "대구광역시 00군 00"),
            ("회사", "대구광역시 00군 00"),
          ],
          iconName: currentIconName, // 선택한 메뉴 정보 전달해 아이콘 변경시킴
        );
      case 1:
        return _FavoriteList(
          title: "자주가는곳",
          items: const [
            ("카페", "대구광역시 00구 00"),
            ("헬스장", "대구광역시 00구 00"),
            ("편의점", "대구광역시 00구 00"),
          ],
          iconName: currentIconName,
        );
      case 2:
      default:
        return _FavoriteList(
          title: "버스 정류장",
          items: const [
            ("정류장", "00-000 중앙시장"),
            ("정류장", "00-001 시청앞"),
            ("정류장", "00-002 대학로"),
          ],
          iconName: currentIconName,
        );
    }
  }
}

/// ===== 상단 프로필 헤더 (아이콘 버튼 간격 수정) =====
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
                '닉네임',
                style: AppTextStyles.title7.copyWith(color: AppColors.grayscale.s900),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: AppColors.grayscale.s500),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  // 닉네임 수정 다이얼로그
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      final controller = TextEditingController();
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
                              // TODO: 저장 로직
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
              // 알림 페이지 이동
            },
          ),
          IconButton(
            icon: Image.asset('lib/assets/images/settings.png', width: 24, height: 24),
            onPressed: () {
              // 설정 페이지 이동
            },
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
    final textColor = selected ? AppColors.grayscale.s900 : AppColors.grayscale.s500;
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
                color : textColor,
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
  final List<(String, String)> items;
  final String iconName;

  const _FavoriteList({
    required this.title,
    required this.items,
    required this.iconName,
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
                style: AppTextStyles.title7.copyWith(color: AppColors.grayscale.s900)
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.grayscale.s100),

          // 리스트
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final (small, main) = items[index];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Image.asset(
                            'lib/assets/images/${iconName}_selected.png',
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
                                  small,
                                  style: AppTextStyles.caption2_1.copyWith(
                                    color: AppColors.grayscale.s500,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  main,
                                  style: AppTextStyles.body1_1.copyWith(
                                    color: AppColors.grayscale.s900,
                                    height: 1.4,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: AppColors.grayscale.s100),
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
                  // 등록 액션
                },
                child: Text(
                  "주소 등록하기",
                  style: AppTextStyles.title7.copyWith(color: AppColors.grayscale.s900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 0=집/회사, 1=자주가는곳, 2=버스
  int selectedIndex = 0;

  final _menus = const [
    (Icons.home_outlined, "집/회사"),
    (Icons.place_outlined, "자주가는곳"),
    (Icons.directions_bus_outlined, "버스"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 프로필 헤더
            const _ProfileHeader(),

            const SizedBox(height: 8),

            // 카테고리 탭 (버튼만 강조 변경, 아래 내용 갈아끼움)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_menus.length, (i) {
                  final item = _menus[i];
                  final isSelected = i == selectedIndex;
                  return _CategoryTab(
                    icon: item.$1,
                    label: item.$2,
                    selected: isSelected,
                    onTap: () => setState(() => selectedIndex = i),
                  );
                }),
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            // 선택된 카테고리에 따라 아래 내용 변경
            Expanded(
              child: _buildContent(selectedIndex),
            ),

            // 하단 여백(혹시 하단 네비바와 겹치면 제거하세요)
            // const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        // 집/회사
        return _FavoriteList(
          title: "즐겨찾기",
          items: const [
            ("집", "대구광역시 00군 00"),
            ("회사", "대구광역시 00군 00"),
            ("집", "대구광역시 00군 00"),
            ("회사", "대구광역시 00군 00"),
          ],
          leadingIcon: Icons.home_rounded,
        );
      case 1:
        // 자주가는곳
        return _FavoriteList(
          title: "자주가는곳",
          items: const [
            ("카페", "대구광역시 00구 00"),
            ("헬스장", "대구광역시 00구 00"),
            ("편의점", "대구광역시 00구 00"),
          ],
          leadingIcon: Icons.place_rounded,
        );
      case 2:
      default:
        // 버스
        return _FavoriteList(
          title: "버스 정류장",
          items: const [
            ("정류장", "00-000 중앙시장"),
            ("정류장", "00-001 시청앞"),
            ("정류장", "00-002 대학로"),
          ],
          leadingIcon: Icons.directions_bus_filled,
        );
    }
  }
}

/// 상단 프로필 헤더 (닉네임 + 편집, 오른쪽 종/설정)
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              const Text(
                '닉네임',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
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
                              // 저장 로직
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
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // 알림 페이지 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              //설정 페이지 이동
            },
          ),
        ],
      ),
    );
  }
}

/// 탭 버튼(선택 시 아이콘/텍스트 진해지고, 밑줄 표시)
class _CategoryTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : Colors.grey;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 6),
          // 밑줄 인디케이터
          Container(
            height: 2,
            width: 48,
            color: selected ? Colors.black : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

/// 리스트 공통 위젯 (섹션 타이틀 + 타일들)
class _FavoriteList extends StatelessWidget {
  final String title;
  final List<(String, String)> items; // (왼쪽 작은 라벨, 메인 주소/이름)
  final IconData leadingIcon;

  const _FavoriteList({
    required this.title,
    required this.items,
    required this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 섹션 타이틀
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const Divider(height: 1),

        // 리스트
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final (small, main) = items[index];
              return ListTile(
                leading: Icon(leadingIcon, color: Colors.black87),
                title: Text(
                  main,
                  style: const TextStyle(fontSize: 15),
                ),
                subtitle: Text(
                  small,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  // 항목 터치 시 동작
                },
              );
            },
          ),
        ),

        // 하단 버튼(예: 주소 등록하기)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E5E5)),
                backgroundColor: const Color(0xFFF7F7F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // 등록 액션
              },
              child: const Text(
                "주소 등록 하기",
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

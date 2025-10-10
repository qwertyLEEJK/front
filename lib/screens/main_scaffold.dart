import 'dart:async'; // 🔸 Completer / nextFrame 용
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_search_bar.dart';

import '1. home_screen.dart';
import '2. profile_screen.dart';

// 패널 콘텐츠
import 'panels/1. home_panel.dart' show HomePanel;
import 'panels/2. transport_panel.dart' show TransitPanel;
import 'panels/3. map_panel.dart' show NearbyPanel;
import 'panels/4. search_panel.dart' show DirectionsPanel;

enum PanelType { home, transit, nearby, directions }

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // ---- Config ----
  static const double _peekSize = 0.08;     // 빼꼼
  static const double _expandedSize = 0.33; // 기본 펼침
  static const double _maxSize = 0.92;

  final _dragController = DraggableScrollableController();
  final ValueNotifier<double> _panelHeightPx = ValueNotifier<double>(0);

  int _currentIndex = 0;               // 하단바 선택
  PanelType _panel = PanelType.home;   // 기본 홈 패널
  bool _panelVisible = true;           // 프로필에선 숨김
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _dragController.addListener(() {
      if (!_dragController.isAttached || !mounted) return;
      final h = MediaQuery.of(context).size.height;
      _panelHeightPx.value = _panelVisible ? (_dragController.size * h) : 0;
    });

    // ✅ 첫 프레임에서 피크 높이 반영 (버튼이 패널 위로 올라오게)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final h = MediaQuery.of(context).size.height;
      _panelHeightPx.value = _panelVisible ? (h * _peekSize) : 0;

      // 처음부터 펼친 상태로 시작하려면 아래 주석 해제
      // _expandToDefault(PanelType.home);
    });
  }

  // 🔸 한 프레임 대기(트리/레이아웃 반영 후)
  Future<void> _nextFrame() async {
    final c = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.complete());
    await c.future;
  }

  Future<void> _waitForAttach() async {
    while (!_dragController.isAttached) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  bool get _isAttached => _dragController.isAttached;
  bool get _isOpen => _isAttached && _dragController.size > _peekSize + 0.02;

  // 외부/홈에서 호출: 패널 피크로 접기(타입은 유지)
  Future<void> _collapseToPeek() async {
    if (!_panelVisible || !_dragController.isAttached) return;
    await _dragController.animateTo(
      _peekSize,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    setState(() {});
  }

  // 펼치기
  Future<void> _expandToDefault([PanelType? to]) async {
    if (to != null) setState(() => _panel = to);
    await _waitForAttach();
    await _dragController.animateTo(
      _expandedSize,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _toggleFor(PanelType type) async {
    if (_panel == type && _isOpen) {
      await _collapseToPeek();
    } else {
      await _expandToDefault(type);
    }
  }

  // 인덱스 → 패널 타입 매핑
  PanelType _panelForIndex(int i) {
    switch (i) {
      case 0: return PanelType.home;
      case 1: return PanelType.transit;
      case 2: return PanelType.nearby;
      case 3: return PanelType.directions;
      default: return PanelType.home;
    }
  }

  // 하단바 탭
  Future<void> _onTap(int i) async {
    // 프로필 탭: 패널 완전 숨김
    if (i == 4) {
      setState(() {
        _currentIndex = i;
        _panelVisible = false;
        _panelHeightPx.value = 0;
      });
      return;
    }

    final nextPanel = _panelForIndex(i);
    final wasHidden = !_panelVisible;                      // 🔸 직전 상태 기억
    final isSamePanel = (_panel == nextPanel) && _panelVisible;

    // 우선 보이게 + 패널 타입 확정 (컨트롤러 attach 준비)
    setState(() {
      _currentIndex = i;
      _panelVisible = true;
      _panel = nextPanel;
    });

    // 🔸 방금까지 숨김이었다면 Draggable이 attach되도록 한 프레임 대기
    if (wasHidden) {
      await _nextFrame();
    }

    // 같은 탭이면 토글, 아니면 항상 펼치기
    if (isSamePanel) {
      if (_isOpen) {
        await _collapseToPeek();
      } else {
        await _expandToDefault();
      }
    } else {
      await _expandToDefault();
    }
  }

  bool get _showSearchBar => _currentIndex != 4;

  @override
  Widget build(BuildContext context) {
    final bodyIndex = (_currentIndex == 4) ? 1 : 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        // 펼쳐져 있으면 먼저 피크로
        if (_panelVisible && _isOpen) {
          await _collapseToPeek();
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressed == null || now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          final m = ScaffoldMessenger.of(context);
          m.hideCurrentSnackBar();
          m.showSnackBar(
            const SnackBar(
              content: Text('한 번 더 누르면 앱이 종료됩니다.'),
              duration: Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
            ),
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.grayscale.s30,
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // 홈 / 내정보만 전환 (홈은 상태 유지)
              IndexedStack(
                index: bodyIndex,
                children: [
                  HomeScreen(
                    bottomInsetListenable: _panelHeightPx,
                    onRequestCollapsePanel: _collapseToPeek, // 마커 탭 시 피크로 접기
                  ),
                  const ProfileScreen(),
                ],
              ),

              if (_showSearchBar)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
                    child: CustomSearchBar(),
                  ),
                ),

              // 🔸 패널: 프로필에선 렌더링 안 함(숨김 시 트리에서 제거)
              if (_panelVisible)
                _PeekablePanel(
                  controller: _dragController,
                  peekSize: _peekSize,
                  maxSize: _maxSize,
                  title: _titleFor(_panel),
                  contentBuilder: (sc) => _panelBody(_panel, sc),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleFor(PanelType p) {
    switch (p) {
      case PanelType.home:       return '홈';
      case PanelType.transit:    return '대중교통';
      case PanelType.nearby:     return '내 주변';
      case PanelType.directions: return '길찾기';
    }
  }

  Widget _panelBody(PanelType p, ScrollController sc) {
    switch (p) {
      case PanelType.home:
        return HomePanel(controller: sc);
      case PanelType.transit:
        return TransitPanel(controller: sc);
      case PanelType.nearby:
        return NearbyPanel(controller: sc);
      case PanelType.directions:
        return DirectionsPanel(controller: sc);
    }
  }
}

class _PeekablePanel extends StatelessWidget {
  final DraggableScrollableController controller;
  final double peekSize;
  final double maxSize;
  final String title;
  final Widget Function(ScrollController) contentBuilder;

  const _PeekablePanel({
    required this.controller,
    required this.peekSize,
    required this.maxSize,
    required this.title,
    required this.contentBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DraggableScrollableSheet(
        controller: controller,
        initialChildSize: peekSize,
        minChildSize: peekSize, // 아래로 내리면 피크에 머무름(비활성X)
        maxChildSize: maxSize,
        snap: true,
        snapSizes: const [0.08, 0.33, 0.5, 0.8],
        builder: (context, scrollController) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grayscale.s30,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grayscale.s900.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Column(
                  children: [
                    // 헤더(그랩바 + 타이틀)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                      child: Column(
                        children: [
                          Container(
                            width: 44, height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.grayscale.s900,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: AppTextStyles.title6.copyWith(color: AppColors.grayscale.s900),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    Expanded(
                      child: PrimaryScrollController(
                        controller: scrollController,
                        child: contentBuilder(scrollController),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

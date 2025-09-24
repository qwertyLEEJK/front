import 'package:flutter/material.dart';
import 'package:midas_project/models/favorite_model.dart';
import 'package:midas_project/services/favorite_service.dart';
import 'package:midas_project/services/search_history_service.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final TextEditingController _textController = TextEditingController();
  List<String> _searchHistory = [];

  final FavoriteService _favoriteService = FavoriteService();
  List<Favorite> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadFavorites();
  }

  // --- 데이터 처리 로직 ---
  Future<void> _loadSearchHistory() async {
    final history = await _searchHistoryService.getSearchHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  Future<void> _handleSearch(String term) async {
    if (term.trim().isEmpty) return;
    await _searchHistoryService.addSearchTerm(term);
    _loadSearchHistory();
    // TODO: 실제 검색 결과 페이지로 이동하거나 검색 실행
    print('Searching for: $term');
  }

  Future<void> _removeSearchTerm(String term) async {
    await _searchHistoryService.removeSearchTerm(term);
    _loadSearchHistory();
  }

  Future<void> _clearSearchHistory() async {
    await _searchHistoryService.clearSearchHistory();
    _loadSearchHistory();
  }

  // 즐겨찾기 데이터 처리 로직 (예외 처리 추가)
  Future<void> _loadFavorites() async {
    try {
      final favs = await _favoriteService.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favs;
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
      _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('즐겨찾기 삭제에 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale.s30,
      body: SafeArea(
        child: Column(
          children: [
            // 검색창 UI
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 20, 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.grayscale.s30,
                  border: Border.all(
                    color: AppColors.grayscale.s100,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: '검색',
                          hintStyle: AppTextStyles.body2_1.copyWith(color: AppColors.grayscale.s500),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        onSubmitted: (value) => _handleSearch(value),
                      ),
                    ),
                    IconButton(
                      icon: Image.asset('assets/images/magnifer.png', width: 24, height: 24,),
                      onPressed: () => _handleSearch(_textController.text),
                    ),
                  ],
                ),
              ),
            ),
            // 스크롤 영역
            Expanded(
              child: ListView(
                children: [
                  _buildSectionHeader('즐겨찾기'),
                  _favorites.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: Text('즐겨찾기 항목이 없습니다.')),
                        )
                      : ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _favorites.length,
                          itemBuilder: (context, index) {
                            final item = _favorites[index];
                            return _buildFavoriteItem(item);
                          },
                          separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.grayscale.s100),
                        ),
                  _buildSectionHeader('최근검색', onClearAll: _clearSearchHistory),
                  _searchHistory.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: Text('최근 검색 기록이 없습니다.')),
                        )
                      : ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _searchHistory.length,
                          itemBuilder: (context, index) {
                            final term = _searchHistory[index];
                            return _buildHistoryItem(term);
                          },
                          separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.grayscale.s100),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI 빌드 헬퍼 위젯 ---

  Widget _buildSectionHeader(String title, {VoidCallback? onClearAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.caption1_2.copyWith(color: AppColors.grayscale.s500),
          ),
          if (onClearAll != null)
            GestureDetector(
              onTap: onClearAll,
              child: Text(
                '전체삭제',
                style: AppTextStyles.caption1_2.copyWith(color: AppColors.grayscale.s500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String term) {
    return InkWell(
      onTap: () {
        _textController.text = term;
        _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
        _handleSearch(term);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(term, style: AppTextStyles.body2_1),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeSearchTerm(term),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.close, color: AppColors.grayscale.s300, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 즐겨찾기 항목 위젯
  // TODO : 서버쪽과 항목 중 '학교'를 별도 추가 논의
  Widget _buildFavoriteItem(Favorite item) {
    String title = item.name;
    String subtitle = '';
    IconData iconData = Icons.star; // 기본값으로 사용
    Widget? iconWidget; // ? : 변수가 null일 수 있음 (예외 경우에 선택적으로 사용)

    if (item.type == FavoriteType.place) {
      subtitle = item.address ?? '주소 정보 없음';
      switch (item.placeCategory) {
        case 'home':
          iconWidget = Image.asset('assets/images/home_unselected.png', width: 24, height: 24);
          break;
        case 'work':
          iconData = Icons.work_outline;
          break;
        default:
          iconData = Icons.location_on_outlined;
      }
    } else if (item.type == FavoriteType.bus) {
      subtitle = '버스 번호: ${item.busNumber ?? '정보 없음'}';
      iconWidget = Image.asset('assets/images/bus_unselected.png', width: 24, height: 24);
    } else if (item.type == FavoriteType.busStop) {
      title = item.stationName ?? '정류장 이름 없음';
      subtitle = '정류장 번호: ${item.stationId ?? '정보 없음'}';
      iconData = Icons.pin_drop_outlined;
    }

    return InkWell(
      onTap: () {
        // TODO: 즐겨찾기 항목 클릭 시 동작 (예: 해당 위치로 지도 이동)
        print('Tapped on favorite: ${item.name}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            // iconWidget에 값이 있을 경우 iconWidget, 없을 경우 Icon(...) 위젯을 사용
            iconWidget ?? Icon(iconData, color: AppColors.grayscale.s500, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: AppTextStyles.body1_1),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        subtitle,
                        style: AppTextStyles.body2_1.copyWith(color: AppColors.grayscale.s600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _deleteFavorite(item.id),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.close, color: AppColors.grayscale.s300, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

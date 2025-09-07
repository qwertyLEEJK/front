import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale.s30,
      // 1. 기존 AppBar를 제거하고 body에서 UI를 구성합니다.
      body: SafeArea(
        child: Column(
          children: [
            // 2. 검색창 UI를 직접 구성합니다.
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
                      icon: Image.asset('lib/assets/images/magnifer.png', width: 24, height: 24,),
                      onPressed: () => _handleSearch(_textController.text),
                    ),
                  ],
                ),
              ),
            ),
            // 3. 스크롤 가능한 영역을 Expanded로 감싸 남은 공간을 모두 차지하게 합니다.
            Expanded(
              child: ListView(
                children: [
                  _buildSectionHeader('즐겨찾기'),
                  // TODO: 서버에서 즐겨찾기 항목 데이터 불러오는 로직 추가
                  _buildListItem('즐겨찾기 항목 1'),
                  _buildListItem('즐겨찾기 항목 2'),
                  _buildListItem('즐겨찾기 항목 3'),
                  _buildListItem('즐겨찾기 항목 4'),

                  // 4. 최근 검색 섹션 헤더 (전체삭제 버튼 포함)
                  _buildSectionHeader('최근검색', onClearAll: _clearSearchHistory),
                  // 5. 검색 기록이 없을 때와 있을 때를 구분하여 표시
                  _searchHistory.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: Text('최근 검색 기록이 없습니다.')),
                  )
                      : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(), // 중첩 스크롤 방지
                    shrinkWrap: true, // 컨텐츠 높이만큼만 차지
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

  // 섹션 헤더 (ex: 즐겨찾기, 최근검색)
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

  // 최근 검색 기록 아이템
  Widget _buildHistoryItem(String term) {
    return InkWell(
      onTap: () {
        _textController.text = term;
        // 커서를 텍스트 뒤로 이동
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
            const SizedBox(width: 8), // 텍스트와 아이콘 사이 간격
            GestureDetector(
              onTap: () => _removeSearchTerm(term),
              // 아이콘의 터치 영역을 넓히기 위해 패딩 추가
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

  // 즐겨찾기 등 일반 리스트 아이템 (삭제 버튼 없음)
  Widget _buildListItem(String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(title, style: AppTextStyles.body2_1),
          onTap: () {
            // TODO: 즐겨찾기 항목 클릭 시 동작
          },
        ),
        Divider(height: 1, color: AppColors.grayscale.s100),
      ],
    );
  }
}
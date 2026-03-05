import 'package:flutter/foundation.dart';
import '../models/tacos_place.dart';
import '../services/tacos_place_service.dart';

class TacosPlacesProvider extends ChangeNotifier {
  final TacosPlaceService tacosPlaceService;

  List<TacosPlace> _items = [];
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  TacosPlacesProvider({required this.tacosPlaceService});

  List<TacosPlace> get items => _items;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    _items = [];
    _error = null;
    await _loadPage(initial: true);
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();
    await _loadPage(initial: false);
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _loadPage({required bool initial}) async {
    if (initial) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final pageData = await tacosPlaceService.getTacosPlaces(page: _page, limit: _limit);
      if (initial) {
        _items = pageData.items;
      } else {
        _items.addAll(pageData.items);
      }
      _hasMore = pageData.hasMore;
      _page = _page + 1;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (initial) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void reset() {
    _items = [];
    _page = 1;
    _hasMore = true;
    _isLoading = false;
    _isLoadingMore = false;
    _error = null;
    notifyListeners();
  }
}

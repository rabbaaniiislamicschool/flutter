import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InfiniteScrollResult<T> {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final Future<void> Function() loadMore;
  final Future<void> Function() refresh;
  final ScrollController scrollController;

  InfiniteScrollResult({
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.error,
    required this.loadMore,
    required this.refresh,
    required this.scrollController,
  });
}

InfiniteScrollResult<T> useInfiniteScroll<T>({
  required Future<List<T>> Function(int page, int limit) fetcher,
  int limit = 20,
  double scrollThreshold = 200,
}) {
  final items = useState<List<T>>([]);
  final page = useState(0);
  final isLoading = useState(false);
  final hasMore = useState(true);
  final error = useState<String?>(null);

  final scrollController = useScrollController();

  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    error.value = null;

    try {
      final newItems = await fetcher(page.value, limit);

      if (newItems.length < limit) {
        hasMore.value = false;
      }

      items.value = [...items.value, ...newItems];
      page.value++;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    items.value = [];
    page.value = 0;
    hasMore.value = true;
    await loadMore();
  }

  useEffect(() {
    void onScroll() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - scrollThreshold) {
        loadMore();
      }
    }

    scrollController.addListener(onScroll);
    return () => scrollController.removeListener(onScroll);
  }, [scrollController]);

  // Initial load
  useEffect(() {
    loadMore();
    return null;
  }, []);

  return InfiniteScrollResult(
    items: items.value,
    isLoading: isLoading.value,
    hasMore: hasMore.value,
    error: error.value,
    loadMore: loadMore,
    refresh: refresh,
    scrollController: scrollController,
  );
}

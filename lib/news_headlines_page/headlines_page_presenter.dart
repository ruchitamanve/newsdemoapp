import 'package:topheadlinesdemo/news_headlines_page/headlines_page_model.dart';
import 'package:topheadlinesdemo/utils/apiconfig.dart';

class TopHeadlinesView {
  void fetchTopHeadlinesData(TopHeadLineModel model) {}
  void onError(error) {}
}

class TopHeadlinesPresenter {
  TopHeadlinesView _view;
  TopHeadlinesPresenter(this._view);
  void loadHeadlineData(isrefresh) {
    Apiconfig()
        .topHeadlinesApi(isrefresh)
        .then((value) => _view.fetchTopHeadlinesData(value))
        .catchError((onError) => _view.onError(onError));
  }
  void loadeSearchData(searchText) {
    Apiconfig()
        .searchTopHeadlinesApi(searchText)
        .then((value) => _view.fetchTopHeadlinesData(value))
        .catchError((onError) => _view.onError(onError));
  }
}

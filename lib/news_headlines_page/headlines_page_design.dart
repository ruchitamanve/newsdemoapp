import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:topheadlinesdemo/database/headlines_db_helper.dart';
import 'package:topheadlinesdemo/database/headlines_db_model.dart';
import 'package:topheadlinesdemo/news_headlines_page/headlines_page_model.dart';
import 'package:topheadlinesdemo/news_headlines_page/headlines_page_presenter.dart';
import 'package:topheadlinesdemo/utils/webview.dart';

class NewsHeadlinesPage extends StatefulWidget {
  const NewsHeadlinesPage({Key key}) : super(key: key);

  @override
  _NewsHeadlinesPageState createState() => _NewsHeadlinesPageState();
}

class _NewsHeadlinesPageState extends State<NewsHeadlinesPage>
    implements TopHeadlinesView {
  final TextEditingController _searchController = new TextEditingController();
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List _nameOfNewsType = [];
  List<Article> _article;
  List<Article> _storeAllArticle;
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  bool _isSearchClick = false;
  bool _searchResp = false;
  var _msg;
  @override
  void initState() {
    _apicall();
    super.initState();
  }

  Future<List<HeadLineListDbModel>> getDbNewsData() {
    var data = HeadlineListDBHelper().getDbData();
    return data;
  }

  _apicall() {
    TopHeadlinesPresenter(this).loadHeadlineData(false);
  }

  _searchapicall() {
    TopHeadlinesPresenter(this).loadeSearchData(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
          child: Scaffold(
        appBar: _isSearchClick == false
            ? AppBar(
                backgroundColor: Colors.red[700],
                title: Text("News App"),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearchClick = true;
                        });
                      })
                ],
              )
            : PreferredSize(
                child: _searchBar(), preferredSize: Size.fromHeight(80)),
        body: _body(),
      )),
    );
  }

  Widget _searchBar() {
    return new Container(
        height: 60,
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.grey[200], width: 2))),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 25,
                        height: 25,
                        child: Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey[500],
                              size: 25,
                            )),
                      ),
                      Expanded(
                        child: Container(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: " Search News",
                                        hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                        contentPadding: EdgeInsets.only(
                                            left: 10, bottom: 10, top: 10)),
                                    onChanged: (searchtext) {
                                      setState(() {
                                        if (_searchController.text.length >=
                                            3) {
                                          _searchapicall();
                                          _searchResp = true;
                                        } else {
                                          _searchResp = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ]),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                  child: _searchController.text.length >= 1
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchResp = false;
                              _article = _storeAllArticle;
                            });
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.grey[500],
                            size: 22,
                          ),
                        )
                      : Container()),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchController.clear();
                    _searchResp = false;
                    _isSearchClick = false;
                    _article = _storeAllArticle;
                  });
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _body() {
    return _isLoading == true
        ? Container(
            height: MediaQuery.of(context).size.height -
                (60 + MediaQuery.of(context).padding.top),
            child: Center(
                child: SpinKitCircle(
              color: Colors.red[700],
              size: 50,
            )))
        : Container(
            child: Column(
              children: <Widget>[_newsNameTypeTab(), _newsList()],
            ),
          );
  }

  Future<Null> _refresh() async {
    if (_searchController.text.length >= 3) {
      _searchapicall();
    } else {
      HeadlineListDBHelper().truncateTable();
      TopHeadlinesPresenter(this).loadHeadlineData(true);
    }
    
  }

  Widget _newsList() {
    return Expanded(
      child: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: Colors.red[700],
          onRefresh: _refresh,
          child: _article != null && _article.length > 0
              ? Container(
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                    child: ListView.builder(
                      itemCount: _article.length,
                      itemBuilder: (context, index) {
                        return Container(
                          child: GestureDetector(
                              onTap: _article[index].url != null
                                  ? () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => WebView(
                                                  url: _article[index].url)));
                                    }
                                  : () {},
                              child: Container(
                                padding: EdgeInsets.only(bottom: 6, top: 6),
                                child: new Card(
                                  elevation: 2,
                                  margin: EdgeInsets.all(1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: _listOfnewsUi(index),
                                ),
                              )),
                        );
                      },
                    ),
                  ),
                )
              : Center(
                  child: Text(
                  _msg ?? "No Data Found!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ))),
    );
  }

  Widget _listOfnewsUi(i) {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          _article[i].urlToImage != null
              ? Container(
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: _article[i].urlToImage != null
                          ? _article[i].urlToImage
                          : "",
                      placeholder: (context, url) => Container(
                        child: Center(
                          child: Text(
                            "Loading",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[300], fontSize: 15),
                          ),
                        ),
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              : Container(height: 0),
          Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _article[i].title != null
                    ? Container(
                        margin: EdgeInsets.only(top: 3),
                        child: Text(
                          _article[i].title ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: Colors.black),
                        ))
                    : Container(
                        height: 0,
                      ),
                _article[i].description != null
                    ? Container(
                        margin: EdgeInsets.only(top: 3),
                        child: Text(
                          _article[i].description ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.grey[600]),
                        ))
                    : Container(
                        height: 0,
                      ),
                Container(
                  margin: EdgeInsets.only(top: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _article[i].author ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.grey[800]),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                          child: Text(
                        dateFormate(_article[i].publishedAt ?? ""),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.grey[800]),
                      ))
                    ],
                  ),
                )
              ],
            ),
          )
        ]));
  }

  Widget _newsNameTypeTab() {
    return _searchResp == false && _article != null
        ? Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            height: 55,
            child: new ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                    _nameOfNewsType.length,
                    (index) => InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                            if (_selectedTabIndex == 0) {
                              _article = _storeAllArticle;
                            } else {
                              _article = [];

                              for (var j = 0;
                                  j < _storeAllArticle.length;
                                  j++) {
                                if (_storeAllArticle[j]
                                        .source
                                        .name
                                        .toLowerCase() ==
                                    _nameOfNewsType[index]
                                        .toString()
                                        .toLowerCase()) {
                                  _article.add(_storeAllArticle[j]);
                                }
                              }
                            }
                          });
                        },
                        child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == index
                                  ? Colors.red[700]
                                  : Colors.grey[300],
                              border: _selectedTabIndex == index
                                  ? null
                                  : Border.all(color: Colors.grey[300]),
                              borderRadius: BorderRadius.circular(
                                25.0,
                              ),
                            ),
                            child: Text(
                              _nameOfNewsType[index],
                              style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedTabIndex == index
                                      ? Colors.white
                                      : Colors.black),
                            ))))),
          )
        : Container(
            height: 0,
          );
  }

  dateFormate(format) {
    final DateTime now = DateTime.parse(format);
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    final String formatted = formatter.format(now);

    return formatted;
  }

  @override
  void fetchTopHeadlinesData(TopHeadLineModel model) {
    if (model.status.toLowerCase() == "ok") {
      getDbNewsData().then((value) async {
        if (value.length < 1) {
          return HeadlineListDBHelper()
              .save(HeadLineListDbModel(null, json.encode(model.toJson())));
        }
      });
      setState(() {
        _selectedTabIndex = 0;
        _isLoading = false;
        _article = model.articles;

        if (_searchResp == false) {
          _nameOfNewsType = ["All"];
          _storeAllArticle = model.articles;
          for (var i = 0; i < _article.length; i++) {
            bool exists = _nameOfNewsType.any((name) =>
                name.toString().toLowerCase() ==
                _article[i].source.name.toLowerCase());
            if (!exists) _nameOfNewsType.add(_article[i].source.name);
          }
        }
      });
    } else {
      setState(() {
        _msg = model.message;
        _isLoading = false;
      });
    }
  }

  @override
  void onError(error) {
    _isLoading = false;
  }
}

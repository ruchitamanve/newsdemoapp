import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebView extends StatefulWidget {
  final url;
  const WebView({Key key, this.url}) : super(key: key);
  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  bool _isLoading = true;

  @override
  void initState() {
    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (state.type.toString() == "WebViewState.finishLoad") {
        setState(() {
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
                elevation: 0.0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                backgroundColor: Colors.red[700],
                centerTitle: true,
                title: Text("News Details")),
            body: Container(
              child: Column(
                children: <Widget>[
                  _isLoading == true
                      ? Container(
                          height: MediaQuery.of(context).size.height -
                              (60 + MediaQuery.of(context).padding.top),
                          child: Center(
                              child: SpinKitCircle(
                            color: Colors.red[700],
                            size: 50,
                          )))
                      : SizedBox(
                          height: 0,
                        ),
                  Container(
                    color: Colors.grey,
                    height: _isLoading == true
                        ? 0
                        : MediaQuery.of(context).size.height -
                            (60 + MediaQuery.of(context).padding.top),
                    child: WebviewScaffold(
                      url: this.widget.url,
                      withZoom: true,
                      withLocalStorage: true,
                      hidden: true,
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

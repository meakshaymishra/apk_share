import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'get_apps.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'shareapp.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.green, // navigation bar color
    systemNavigationBarIconBrightness: Brightness.light,
    //statusBarColor: Colors.pink, // status bar color
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APK Share',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'APK Share'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class Debouncer{
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action){
    if (null != _timer){
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final _debouncer = Debouncer(milliseconds:500);
  final _searchController = new TextEditingController();
  List<Application> appsList = List();
  List<Application> filteredappsList = List();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_apps.getApps(false).then((appsFromDevice){
      setState(() {
        appsList = appsFromDevice;
        filteredappsList = appsList;

        print(appsList);
      });
    });
  }

  Future<bool> _onBackPressed(){
    print('Here : $_searchController');
    if(_searchController.text==null || _searchController.text==''){
      return showDialog(
          context:context,
          builder: (context) => AlertDialog(
            title: Text('Do you really want to exit?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Yes'),
                onPressed:()=>Navigator.pop(context, true),
              ),
              FlatButton(
                child: Text('No'),
                onPressed:()=>Navigator.pop(context, false),
              )

            ],
          )
      );
    }
    else{
      _searchController.clear();
      setState(() {
        filteredappsList = appsList;
      });

    }

  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15.0),
                hintText: 'Search an app',
              ),
              onChanged: (string){
                _debouncer.run((){
                  setState(() {
                    filteredappsList = appsList
                        .where((u) => (u.appName
                        .toLowerCase().contains(string.toLowerCase())))
                        .toList();
                  });
                });


              },

              

            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: filteredappsList.length,
                itemBuilder: (BuildContext context, int index){
                  Application app = filteredappsList[index];

                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            leading: app is ApplicationWithIcon
                                ? CircleAvatar(
                              backgroundImage: MemoryImage(app.icon),
                              backgroundColor: Colors.white,
                            )
                                : null,
                            onTap: () {
                              shareapp.shareFile(app.appName, app.apkFilePath);
                            },
                            //title: Text("${app.appName} (${app.packageName})"),
                            title: Text("${app.appName}"),
                            //subtitle: Text('Version: ${app.versionName}\nSystem app: ${app.systemApp}\nAPK file path: ${app.apkFilePath}\nData dir : ${app.dataDir}\nInstalled: ${DateTime.fromMillisecondsSinceEpoch(app.installTimeMilis).toString()}\nUpdated: ${DateTime.fromMillisecondsSinceEpoch(app.updateTimeMilis).toString()}'),
                            subtitle: Text('Version: ${app.versionName}\nSystem app: ${app.systemApp}'),
                          ),

                          SizedBox(
                            height: 5.0,
                          ),
                        ],
                      ),
                    ),
                  );

                },
              )
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.share),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          splashColor: Colors.black,
          elevation: 10,
          highlightElevation: 50,
          tooltip: 'Share with friends',
          onPressed: (){
            //print("Clicked");
            Share.share('Download APK Share to send installed apps <someLink>', subject: 'APK Share!');
          },
        ),

      ),
    );
  }
}

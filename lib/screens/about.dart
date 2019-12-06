// framework
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// packages
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
          <Widget>[
            // normal mode
            SliverAppBar(
                flexibleSpace: FlexibleSpaceBar(),
                title: Container(child: Text('About')),
                forceElevated: innerBoxIsScrolled,
                bottom: PreferredSize(
                    preferredSize: Size.fromHeight(25),
                    child: TabBar(
                      tabs: <Tab>[
                        new Tab(
                          text: "Donate",
                        ),
                      ],
                      controller: _tabController,
                    ))),
          ],
      body: TabBarView(controller: _tabController, children: [Donate()]),
    ));
  }
}

class Donate extends StatelessWidget {
  final String paypal = "https://www.paypal.me/eagle6789";
  final String bitcoin = "1AP6bypSaFt7ptFydmjuWWWS8a9MCWRt3m";
  final String paypalEmail = "me49544@gmail.com";

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => ListView(
            children: <Widget>[
              ListTile(
                title: Text(
                  "Paypal me",
                ),
                subtitle: Column(children: [
                  Text("$paypal"),
                  IconButton(
                    onPressed: () {
                      _launchURL();
                    },
                    icon: Icon(Icons.open_in_browser),
                  )
                ]),
              ),
              Divider(),
              ListTile(
                title: Text(
                  "Paypal account",
                ),
                subtitle: Column(children: [
                  Text("$paypalEmail"),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(new ClipboardData(text: paypalEmail));

                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Copied email address: $paypalEmail")));
                    },
                    icon: Icon(Icons.content_copy),
                  )
                ]),
              ),
              Divider(),
              ListTile(
                  title: Text(
                    "Bitcoin",
                  ),
                  subtitle: Column(
                    children: [
                      Text("$bitcoin"),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(new ClipboardData(text: bitcoin));

                          Scaffold.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Copied bitcoin address: $bitcoin")));
                        },
                        icon: Icon(Icons.content_copy),
                      )
                    ],
                  ))
            ],
          ),
    );
  }

  _launchURL() async {
    const url = 'https://www.paypal.me/eagle6789';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

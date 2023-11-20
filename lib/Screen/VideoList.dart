import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Screen/VideoPlayer.dart';
import 'package:eshop/Screen/YoutubePlayer_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  List liveVideoList = [];
  bool loader = false;
  String? url;
  String? type;

  getLiveVideoApiFunc() {
    setState(() {
      loader = true;
    });
    getLiveVideoApi().then((value) {
      var info = jsonDecode(value);
      if (info['status'] == true) {
        liveVideoList.clear();
        liveVideoList.addAll(info['live_video']);
        setState(() {
          loader = false;
        });
      } else {
        setState(() {
          loader = false;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLiveVideoApiFunc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        foregroundColor: colors.primary,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade50,
        title: Text('कार्यक्रम'),
      ),
      body: loader == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
            itemCount: liveVideoList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            url = liveVideoList[index]['link'];
                            type = liveVideoList[index]['type'];
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>type=='facebook'? VideoPlayer(url: url, type: type):YoutubePlayerScreen(videoId: url),));
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => YoutubePlayerScreen(),));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: imgUrl + liveVideoList[index]['thumb_img'],
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              liveVideoList[index]['title'],
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.clip),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Divider(color: Colors.grey.shade700,thickness: 1,),
                    // SizedBox(height: 5,)
                  ],
                ),
              );
            },
          ),
    );
  }

  Future getLiveVideoApi() async {
    var headers = {
      'Cookie': 'ci_session=a18c42ccb2697a760fa319e7852435bf032b53e7; ekart_security_cookie=1e4fdabb70e9e4a45545423dd5fef575'
    };
    var response = await http.get(getLiveVideo, headers: headers);
    return response.body.toString();
  }
}

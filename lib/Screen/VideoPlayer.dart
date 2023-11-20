import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayer extends StatefulWidget {
  String? url;
  String? type;
  VideoPlayer({super.key,required this.url,required this.type});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {


  // String html = '<div class="fb-video" data-href="https://www.facebook.com/FacebookAU/videos/10152167660372415/" data-width="500" data-show-text="true"><blockquote cite="https://www.facebook.com/FacebookAU/videos/10152167660372415/" class="fb-xfbml-parse-ignore"><a href="https://www.facebook.com/FacebookAU/videos/10152167660372415/">Happy New You</a><p>Here’s to a healthier, dancier, artier, funner New You in 2014.</p>Posted by <a href="https://www.facebook.com/FacebookAU/">Facebook</a> on Wednesday, January 8, 2014</blockquote></div>';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: colors.primary,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade50,
        title: Text('कार्यक्रम'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: HtmlWidget(
        '''${widget.url}'''
        ),
      ),
    );
  }

  Future getLiveVideoApi() async {
    var headers = {
      'Cookie': 'ci_session=24c20300fe0b794dfd06edcdec7a26e8786341a7; ekart_security_cookie=1e4fdabb70e9e4a45545423dd5fef575'
    };
    var response = await http.get(getLiveVideo,headers: headers);
    return response.body.toString();
  }

}

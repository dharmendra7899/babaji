import 'package:audioplayers/audioplayers.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PdfViewer extends StatefulWidget {
  String? pdfUrl;
  String? title;
  String? audio;
  PdfViewer({super.key,required this.pdfUrl,required this.title,required this.audio});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;


  Future setAudio() async {
    // Repeat song when completed
    audioPlayer.setReleaseMode(ReleaseMode.loop);

    /// Load audio from URL
    String url = widget.audio!;
    print(url);
    audioPlayer.setSourceUrl(url);
  }

  @override
  void initState() {
    super.initState();

    setAudio();

    /// Listen to states: playing, paused, stopped
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.playing;
      });
    });

    /// Listen to audio duration
    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    /// Listen to audio position
    audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios_new,color: colors.primary,size: 20,)),
        shadowColor: Colors.transparent,
        title: Text(widget.title!,style: TextStyle(color: colors.primary),),
        actions: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            child: IconButton(
              alignment: Alignment.center,
                onPressed: () async {
                  if(isPlaying){
                    await audioPlayer.pause();
                  } else{
                    await audioPlayer.resume();
                  }
                },
                icon: Icon( isPlaying ? Icons.pause : Icons.play_arrow, size: 20)
            ),
          ),
          SizedBox(width: 12,)
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: PDF(
          enableSwipe: true,
          fitEachPage: true,
          pageFling: true,
          swipeHorizontal: true,
          fitPolicy: FitPolicy.BOTH,
          autoSpacing: true,
          pageSnap: true
        ).cachedFromUrl(
          widget.pdfUrl!,
          placeholder: (double progress) => Center(child: Text('$progress %')),
          errorWidget: (dynamic error) => Center(child: Text(error.toString())),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/PdfViewer.dart';
import 'package:eshop/Screen/Subscription.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Emasik extends StatefulWidget {
  const Emasik({super.key});

  @override
  State<Emasik> createState() => _EmasikState();
}

class _EmasikState extends State<Emasik> {

  bool loading = false;
  String? pdfUrl;
  String? title;
  String? audio;
  String? id;
  List eBookList =[];
  getEbookListApiFunc(){
    setState(() {
      loading = true;
    });
    eBookListApi().then((value) {
      var info = jsonDecode(value);
      if(info['status']==true){
        eBookList.clear();
        eBookList.addAll(info['ebooks']);
        setState(() {
          loading = false;
        });
      }
      else{
        setState(() {
          loading = false;
        });
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEbookListApiFunc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios_new,color: colors.primary,size: 20,)),
        shadowColor: Colors.transparent,
        title: const Text('निष्काम कर्मयोगी मासिक',style: TextStyle(color: colors.primary),),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8,),
                    Text('Filter By',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15,color: Colors.black),)
                  ],
                ),
                SizedBox(width: 35,),
                Row(
                  children: [
                    Icon(CupertinoIcons.arrow_up_arrow_down,size: 16),
                    SizedBox(width: 8,),
                    Text('Sort By',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15,color: Colors.black),)
                  ],
                ),
                SizedBox(width: 35,),
                Icon(CupertinoIcons.square_grid_2x2),
              ],
            ),
          ),
          Expanded(
            child: loading == true?const Center(child: CircularProgressIndicator()):ListView.builder(
              shrinkWrap: true,
              itemCount: eBookList.length,
              itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(10),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                        imageUrl: eBookList[index]['thumb_img'],
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fitWidth,
                      height: MediaQuery.of(context).size.height/1.7,
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    ),
                    Text(eBookList[index]['title'],style: const TextStyle(color: colors.primary,fontSize: 20,fontWeight: FontWeight.w600,overflow: TextOverflow.clip),),
                    SizedBox(width: 20,),
                    Text(eBookList[index]['month'],style: const TextStyle(color: colors.primary,fontSize: 16,fontWeight: FontWeight.w600,overflow: TextOverflow.clip),),
                    InkWell(
                      onTap: () {
                        setState(() {
                          pdfUrl= eBookList[index]['pdf'];
                          title= eBookList[index]['title'];
                          audio= eBookList[index]['audio'];
                          id= eBookList[index]['id'];
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        eBookList[index]['subscribed']==true?
                        Plans(bookId: id,):PdfViewer(pdfUrl: pdfUrl,title: title,audio: audio),));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width/2,
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(3),
                            gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.orange,
                                  colors.primary
                                ])
                        ),
                        child: const Text('वाचा किंवा ऐका',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
                      ),
                    )
                  ],
                ),
              );
            },),
          )
        ],
      ),
    );
  }

  Future eBookListApi () async{
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    var headers = {
      'Cookie': 'ci_session=c8e6e4a8d4bba337435a62336a48fab3e61b9a0f; ekart_security_cookie=b56e15f22114ddc1f78715c63a30dcd3'
    };
    var url = Uri.parse('https://nishkamkarmyogimasik.com/app/v1/api/get_ebook_list?user_id=${user.userId}');
    var response = await http.get(url,headers: headers);
    print(url);
    return response.body.toString();
  }

}

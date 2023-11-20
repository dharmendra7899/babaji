import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Suvichar extends StatefulWidget {
  const Suvichar({super.key});

  @override
  State<Suvichar> createState() => _SuvicharState();
}

class _SuvicharState extends State<Suvichar> {

  List suvicharList =[];
  bool loading = false;

  getTempleListApiFunc(){
    setState(() {
      loading = true;
    });
    getTempleListApi().then((value) {
      var info = jsonDecode(value);
      if(info['status']==true){
        suvicharList.clear();
        suvicharList.addAll(info['suvichar']);
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
    getTempleListApiFunc();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        foregroundColor: colors.primary,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade50,
        title: Text('सुविचार'),
      ),
      body: loading == true?Center(child: CircularProgressIndicator()):ListView.builder(
        scrollDirection: Axis.vertical,
        physics: AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: suvicharList.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(top: 10,left: 10,right: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)

                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: imgUrl+suvicharList[index]['image'],
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                      ),
                      SizedBox(height: 10,),
                      Text(suvicharList[index]['title'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,overflow: TextOverflow.clip,color: Colors.black),),
                    ],
                  ),
                ),
                // Divider(color: Colors.grey.shade700,thickness: 1,),
                // SizedBox(height: 5,)
              ],
            ),
          );
        },),
    );
  }

  Future getTempleListApi() async{
    var headers = {
      'Cookie': 'ci_session=51950314ddd814adc2ebf8dc0812961c01d9b8bc; ekart_security_cookie=1e4fdabb70e9e4a45545423dd5fef575'
    };
    var response = await http.get(getSuvicharApi,headers: headers);
    return response.body.toString();
  }

}

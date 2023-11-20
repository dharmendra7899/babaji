import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Temples extends StatefulWidget {
  const Temples({super.key});

  @override
  State<Temples> createState() => _TemplesState();
}

class _TemplesState extends State<Temples> {

  List templeList =[];
  bool loading = false;

  getTempleListApiFunc(){
    setState(() {
      loading = true;
    });
    getTempleListApi().then((value) {
      var info = jsonDecode(value);
      if(info['status']==true){
        templeList.clear();
        templeList.addAll(info['temples']);
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
        title: Text('जय बाबाजी आश्रममाहिती'),
      ),
      body: loading == true?Center(child: CircularProgressIndicator()):ListView.builder(
        shrinkWrap: true,
        itemCount: templeList.length,
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
                        imageUrl: imgUrl+templeList[index]['temple_pic'],
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                    ),
                    SizedBox(height: 10,),
                    Text(templeList[index]['temple_name'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,overflow: TextOverflow.clip,color: Colors.black),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(CupertinoIcons.home,color: Colors.black,),
                        Expanded(child: Text(' : '+templeList[index]['address'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600,overflow: TextOverflow.clip,color: Colors.black),)),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CachedNetworkImage(
                                height: MediaQuery.of(context).size.height/7,
                                imageUrl: imgUrl+templeList[index]['owner_pic'],
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                              ),
                              Text(templeList[index]['owner_name'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.phone,color: Colors.black,),
                                  Text(' : '+templeList[index]['owner_mob'],style: TextStyle(fontSize: 14,color: Colors.black),),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Text(templeList[index]['description'],style: TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.clip,color: Colors.black),)),
                      ],
                    )
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
      'Cookie': 'ci_session=720c461a1c4818d876ae84cecff974398efe2619; ekart_security_cookie=1e4fdabb70e9e4a45545423dd5fef575'
    };
    var response = await http.get(getTemplesApi,headers: headers);
    return response.body.toString();
  }

}

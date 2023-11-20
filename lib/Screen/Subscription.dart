import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Provider/SettingProvider.dart';
import 'package:eshop/Screen/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Plans extends StatefulWidget {
  String? bookId;
  Plans({super.key,required this.bookId,required});

  @override
  State<Plans> createState() => _PlansState();
}

class _PlansState extends State<Plans> {
  bool loader = false;
  bool loader2 = false;
List subscription =[];
  StateSetter? checkoutState;

  String? msg;
  var planId;
  double? amount;
  var title ;
  var durations ;
  int selectedsub = 0;
  String razorpayOrderId = '';
  String? rozorpayMsg;
  Razorpay? _razorpay;
  getSubscriptionListApiFunc() async {
    setState(() {
      loader = true;
    });
    getSubscriptionListApi().then((value) {
      var info = jsonDecode(value);
      if(info['status']==true){
        subscription.clear();
        subscription.addAll(info['plans']);
        setState(() {
          loader = false;
        });
        print(subscription);
      }else{
        setState(() {
          loader = false;
        });
      }
    });
  }



  void launchRazorpay() {
    var doublevalue = (double.parse(subscription[selectedsub]['price']) -
        double.parse(subscription[selectedsub]['discount']));
    var totalval = doublevalue.toInt() * 100;
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(context, listen: false);

    var options = {
      'key': 'rzp_live_ufHrpnfJbALR10',
      'amount': totalval,
      'currency': 'INR',
      'name': settingsProvider.userName,
      'prefill': {
        'contact': settingsProvider.mobile,
        'email': settingsProvider.email
      }
    };
    print('options $options');
    try {
      _razorpay!.open(options);
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  void initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (kDebugMode) {
      //print('Payment Sucessfull');
      // toScreen(context, LandingPage(value: 2));
      // Authcredential().storeindex('$selectedsub');
    }
    successsubscription(
      "${response.paymentId}",
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      //print('Payment error');
      Fluttertoast.showToast(msg: 'Payment error');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      //print('External wallet');
      Fluttertoast.showToast(msg: 'Payment Failed');
    }
  }

  Future successsubscription(var transactionId) async {
    var doublevalue = (double.parse(subscription[selectedsub]['price']) -
        double.parse(subscription[selectedsub]['discount']));
    var totalval = doublevalue.toInt() * 100;
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(context, listen: false);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://nishkamkarmyogimasik.com/app/v1/api/subscribed_plan'));
      request.fields.addAll({
        'user_id': settingsProvider.userId,
        'plan_id': planId,
        'ebook_id': widget.bookId!,
        'transaction_id': transactionId,
        'amount': totalval.toString(),
        'remark': title,
        'duration': durations
      });
      print('request for success ${request.fields}');


      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      }
      else {
        print(response.reasonPhrase);
      }

    } catch (e) {
      // Fluttertoast.showToast(msg: message);
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubscriptionListApiFunc();
    initializeRazorpay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: colors.primary,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade50,
        title: Text('Plans'),
      ),
      body: Center(
        child: loader == true ?CircularProgressIndicator():CarouselSlider.builder(
          itemCount: subscription.length,
          options: CarouselOptions(
            aspectRatio: MediaQuery.of(context).size.height/1300,
            autoPlay: false,
            enlargeCenterPage: true,
          ),
          itemBuilder: (context, index, realIndex) {
            amount = double.parse(subscription[index]['price']) - double.parse(subscription[index]['discount']).toInt();
            final duration = Duration(
                days: int.parse(subscription[index]['duration']));
            final totalMonths = duration.inDays ~/
                30; // Using integer division to get whole months
            var month = totalMonths;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: colorcombination[index]['1'], width: 3),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black,
                      )
                    ],
                    borderRadius: BorderRadius.circular(3),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: colorcombination[index]['1'],
                          // borderRadius: BorderRadius.only(
                          //     topLeft: Radius.circular(15),
                          //     topRight: Radius.circular(15)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              subscription[index]['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "news706",
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.yellow,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    double.parse(subscription[index]
                                    ['discount'])
                                        .toInt() ==
                                        0
                                        ? SizedBox.shrink()
                                        : Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Not For",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "\u{20B9} ${double.parse(subscription[index]['price']).toInt()}",
                                          textAlign:
                                          TextAlign.center,
                                          style: TextStyle(
                                              decoration:
                                              TextDecoration
                                                  .lineThrough,
                                              color: Colors.black,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    int.parse(subscription[index]
                                    ['duration']) <
                                        30
                                        ? Text(
                                      "\u{20B9} ${(double.parse(subscription[index]['price']) - double.parse(subscription[index]['discount'])).toInt()}/${subscription[index]['duration']} Days",
                                      style: const TextStyle(
                                          fontFamily:
                                          "Poppins-SemiBold",
                                          fontSize: 22),
                                    )
                                        : Text(
                                      "\u{20B9} ${(double.parse(subscription[index]['price']) - double.parse(subscription[index]['discount'])).toInt()}/$month month",
                                      style: const TextStyle(
                                          fontFamily:
                                          "Poppins-SemiBold",
                                          fontSize: 22,
                                          color: Colors.black
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Plan Features",
                      textAlign: TextAlign.start,
                      textScaleFactor: 1.4,style: TextStyle(
                      color: Colors.black
                    ),
                    ),
                    SizedBox(height: 2),
                    ListView.builder(
                      itemCount: subscription[index]['key_features']['feature'].length,
                      shrinkWrap: true,
                      itemBuilder: (context, index2) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            SizedBox(width:5),
                            Text(subscription[index]['key_features']['feature'][index2],style: TextStyle(color: Colors.black),),
                          ],
                        ),
                      );
                    },),
                    Spacer(),
                    Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: colorcombination[index]['1'],
                            // borderRadius: BorderRadius.only(
                            //     bottomLeft: Radius.circular(15),
                            //     bottomRight: Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child:  Container(
                            child: MaterialButton(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        3),
                                ),
                                onPressed: () async {
                                  SettingProvider settingsProvider =
                                  Provider.of<SettingProvider>(context, listen: false);
                                  setState(() {
                                    title = subscription[index]['title'];
                                    planId = subscription[index]['id'];
                                    durations = subscription[index]['duration'];
                                    selectedsub = index;
                                  });
                                  // generateOrderID(planId);
                                  settingsProvider.userName ==''?Navigator.push(context, MaterialPageRoute(builder: (context) => Login(isPop: false),)): launchRazorpay();

                                },
                                child: Text(
                                  'Subscribe Plan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color:
                                    colorcombination[index]
                                    ['1'],
                                  ),
                                )),
                          ),
                        ))
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future getSubscriptionListApi () async{
    var headers = {
      'Cookie': 'ci_session=c0586c1aa66a158e04025c8e932f46648dd4d246; ekart_security_cookie=f45fc5f9bee07b38b7bb005d6f7da506'
    };
    var url = getPlansApi;
    var response = await http.get(url,headers: headers);
    return response.body.toString();
}

  List colorcombination = [
    {"1": colors.primary, "2": Colors.yellow},
    {"1": Color(0xff9f26ff), "2": Colors.yellow},
    {"1": Color(0xff45cd3b), "2": Colors.yellow},
    {"1": Color(0xff000c98), "2": Colors.yellow},
    {"1": Color(0xffe800e9), "2": Colors.yellow},
    {"1": Color(0xff703c00), "2": Colors.yellow},
    {"1": colors.primary, "2": Colors.yellow},
    {"1": Color(0xff9f26ff), "2": Colors.yellow},
    {"1": Color(0xff45cd3b), "2": Colors.yellow},
    {"1": Color(0xff000c98), "2": Colors.yellow},
    {"1": Color(0xffe800e9), "2": Colors.yellow},
    {"1": Color(0xff703c00), "2": Colors.yellow},
  ];
}

import 'dart:async';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jlpt_testdate_countdown/custom/config.dart';
import 'package:jlpt_testdate_countdown/src/blocs/bloc.dart';
import 'package:jlpt_testdate_countdown/src/models/date.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CarouselController buttonCarouselController = CarouselController();
  String time = "08/08/2020";
  int imageIndex = 0;
  List<AssetImage> imageAssetsLink = <AssetImage>[];

  @override
  void initState() {
    super.initState();
    loadCountTime(context);
    imageAssetsLink = [
      AssetImage(
        "assets/meo1.jpg",
      ),
      AssetImage(
        "assets/meo2.jpg",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageAssetsLink[imageIndex],
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
            width: MediaQuery.of(context).size.width - 20,
            height: MediaQuery.of(context).size.height - 20,
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
                onPressed: () {},
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ))),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              SizedBox(height: 30),
              Row(
                children: <Widget>[
                  SizedBox(width: 20),
                  Column(
                    children: <Widget>[
                      Text(
                        "Đếm ngược ngày thi",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Kì thi THPT Quốc gia 2020",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox()),
                  IconButton(
                      icon: Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () {
                        setState(() {
                          if (imageIndex < imageAssetsLink.length - 1) {
                            imageIndex++;
                          } else if (imageIndex == imageAssetsLink.length - 1) {
                            imageIndex = 0;
                          }
                        });
                      }),
                  SizedBox(width: 20),
                ],
              ),
              SizedBox(height: 20),
              Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "CÒN",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      child: BlocBuilder<DateBloc, DateState>(
                        builder: (context, state) {
                          if (state is DateInitial) {
                            return CircularProgressIndicator();
                          } else if (state is DateLoading) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is DateLoaded) {
                            return buildCarouselSlider(context, state.date);
                          }
                        },
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.timer, color: Colors.white, size: 25),
                          SizedBox(width: 5),
                          Text(
                            "Ngày thi: $time",
                            style: TextStyle(color: Colors.white),
                          ),
                        ]),
                    SizedBox(
                      height: 20,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        // TODO: Implement function
                      },
                    ),
                    Text(
                      "Không làm mà đòi ăn, thì chỉ có ăn đầu buồi, ăn cứt",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  CarouselSlider buildCarouselSlider(BuildContext context, Date date) {
    return CarouselSlider(
      items: [
        buildColumnWithData(context, date, "Ngày"),
        buildColumnWithData(context, date, "Giờ"),
        buildColumnWithData(context, date, "Phút"),
        buildColumnWithData(context, date, "Giây"),
        buildColumnWithData(context, date, "Tháng"),
        buildColumnWithData(context, date, "Tuần"),
      ],
      carouselController: buttonCarouselController,
      options: CarouselOptions(
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 2.0,
        initialPage: 2,
      ),
    );
  }

  void loadCountTime(BuildContext context) {
    final dateBloc = BlocProvider.of<DateBloc>(context);
    Timer.periodic(Duration(seconds: 1), (timer) {
      dateBloc.add(GetDate(Config.testDate));
    });
  }

  Column buildColumnWithData(BuildContext context, Date date, String type) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "${counting(date, type)}",
          style: TextStyle(color: Colors.white, fontSize: 50),
        ),
        Text(
          type,
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ],
    );
  }

  int counting(Date date, String type) {
    switch (type) {
      case "Ngày":
        {
          return date.timeLeft.inDays;
        }
      case "Giờ":
        {
          return date.timeLeft.inHours;
        }
      case "Phút":
        {
          return date.timeLeft.inMinutes;
        }
      case "Giây":
        {
          return date.timeLeft.inSeconds;
        }
      case "Tháng":
        {
          return (date.timeLeft.inDays / 30).toInt();
        }
      case "Tuần":
        {
          return (date.timeLeft.inDays / 7).toInt();
        }
    }
  }
}

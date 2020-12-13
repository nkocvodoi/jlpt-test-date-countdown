import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:jlpt_testdate_countdown/src/app/home/learning-material/add-learning-material/add-learning-material.view.dart';
import 'package:jlpt_testdate_countdown/src/app/home/learning-material/component/item.component.dart';
import 'package:jlpt_testdate_countdown/src/app/home/learning-material/learning-material.cubit.dart';
import 'package:jlpt_testdate_countdown/src/app/home/learning-material/learning-material.module.dart';
import 'package:jlpt_testdate_countdown/src/app/home/learning-material/type.dart';
import 'package:jlpt_testdate_countdown/src/env/application.dart';
import 'package:jlpt_testdate_countdown/src/resources/data.dart';
import 'package:jlpt_testdate_countdown/src/utils/sizeconfig.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LearningMaterial extends StatefulWidget {
  @override
  _LearningMaterialState createState() => _LearningMaterialState();
}

class _LearningMaterialState extends State<LearningMaterial> {
  LearningMaterialCubit _cubit = Modular.get<LearningMaterialCubit>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void onRefresh() {
    Future.delayed(Duration(milliseconds: 1000), () {
      _refreshController.refreshCompleted();
    });
  }

  void onLoading() {
    Future.delayed(Duration(milliseconds: 1000), () {
      _cubit.pull();
      _refreshController.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                image: DataConfig.imageAssetsLink[Application.sharePreference.getInt("imageIndex") ?? 0],
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.0))),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
              Text("Tài liệu ôn thi", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold))
            ]),
          ),
          Container(
            height: SizeConfig.screenHeight,
            padding: EdgeInsets.only(
              left: SizeConfig.safeBlockHorizontal * 3,
              top: SizeConfig.safeBlockVertical * 12,
              right: SizeConfig.safeBlockHorizontal * 3,
            ),
            child: listCategoryItem(),
          )
        ],
      ),
      floatingActionButton: OpenContainer(
        openColor: AppColor.brown1,
        transitionType: ContainerTransitionType.fade,
        openBuilder: (BuildContext context, VoidCallback _) => AddLearningMaterial(),
        closedElevation: 6.0,
        closedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
        closedColor: AppColor.brown2,
        onClosed: (obj) => _cubit.loadLearningData(1),
        closedBuilder: (BuildContext context, VoidCallback openContainer) => SizedBox(
          height: 56,
          width: 56,
          child: Center(child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary)),
        ),
      ),
    );
  }

  Widget buildSlidableCategory(String title, List<String> data, String type) => Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text("$title", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                  data.length,
                  (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal),
                        width: SizeConfig.safeBlockHorizontal * 25,
                        height: SizeConfig.safeBlockVertical * 6,
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(10), color: _cubit.colorList[index]),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onPressed: () => Modular.link.pushNamed(LearningMaterialModule.detailLearning,
                              arguments: Params(title: title, subject: _cubit.subjectNoCapitals[index])),
                          child: Center(
                            child: Text("${data.elementAt(index)}",
                                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )),
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical),
          Row(
            children: [
              SizedBox(width: SizeConfig.safeBlockHorizontal),
              FlatButton(
                onPressed: () => Modular.link
                    .pushNamed(LearningMaterialModule.detailLearning, arguments: Params(title: title, type: type)),
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward_sharp, color: Colors.white, size: 35),
                    SizedBox(width: SizeConfig.safeBlockHorizontal * 4),
                    Text("Xem tất cả", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))
                  ],
                ),
              )
            ],
          )
        ],
      );

  Widget listCategoryItem() {
    return Scrollbar(
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        header: WaterDropMaterialHeader(),
        footer: ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
          completeDuration: Duration(milliseconds: 500),
          canLoadingIcon: const Icon(Icons.autorenew, color: Colors.white),
          textStyle: TextStyle(color: Colors.white),
          loadingIcon: SizedBox(
            width: 25.0,
            height: 25.0,
            child: defaultTargetPlatform == TargetPlatform.iOS
                ? Theme(
                    data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark)),
                    child: CupertinoActivityIndicator(),
                  )
                : const CircularProgressIndicator(
                    strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ),
        ),
        onRefresh: onRefresh,
        onLoading: onLoading,
        controller: _refreshController,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: SizeConfig.safeBlockVertical * 3),
              buildSlidableCategory("Tài liệu luyện thi theo môn học", _cubit.subjects, "tai lieu"),
              SizedBox(height: SizeConfig.safeBlockVertical * 3),
              buildSlidableCategory("Đề thi thử theo môn học", _cubit.subjects, "de thi"),
              SizedBox(height: SizeConfig.safeBlockVertical * 3),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Tài liệu mới cập nhật",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: SizeConfig.safeBlockVertical),
              BlocBuilder<LearningMaterialCubit, LearningMaterialState>(
                cubit: _cubit,
                buildWhen: (prev, now) => now is LearningMaterialDataLoaded,
                builder: (context, state) => state is LearningMaterialDataLoaded
                    ? Column(
                        children: List.generate(
                            state.data.length,
                            (index) => buildCategoryItem(
                                  state.data.elementAt(index),
                                  context,
                                  onEventEmitted: () => _cubit.loadLearningData(5),
                                )),
                      )
                    : CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:jlpt_testdate_countdown/src/app/home/cubit/home.cubit.dart';
import 'package:jlpt_testdate_countdown/src/app/home/note/note-page.cubit.dart';
import 'package:jlpt_testdate_countdown/src/resources/data.dart';
import 'package:jlpt_testdate_countdown/src/utils/sizeconfig.dart';

class NotePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NotePageState();
  }
}

class _NotePageState extends State<NotePage> with SingleTickerProviderStateMixin {
  HomeCubit _homeCubit = HomeCubit();
  NoteCubit _noteCubit = NoteCubit();
  AnimationController _controller;
  Animation<double> offsetAnimation;

  bool deleteMode = true;
  final TextEditingController textController = TextEditingController();
  GlobalKey<FormBuilderState> _formBuilderKey = GlobalKey<FormBuilderState>();
  final _colors = [0xffd4d9e1, 0xffd3ccc7, 0xff000000, 0xffd0484e, 0xffFFFFFF];

  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    offsetAnimation = Tween(begin: 0.0, end: 5.0).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller)
      ..addStatusListener((status) {
        // while(deleteMode){
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
        // }
      });
    return Scaffold(
        body: Stack(
      children: <Widget>[
        BlocBuilder<HomeCubit, HomeState>(
            cubit: _homeCubit,
            buildWhen: (prev, now) => now is BackgroundImageChanged,
            builder: (context, state) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                      image: DataConfig.imageAssetsLink[_homeCubit.imageIndex],
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
        Container(
            margin:
                EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 6, 100, SizeConfig.blockSizeHorizontal * 6, 20),
            child: BlocBuilder<NoteCubit, NoteState>(
                cubit: _noteCubit,
                builder: (context, state) {
                  return GridView.builder(
                      itemCount: _noteCubit.headerList.length,
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      itemBuilder: (BuildContext context, int index) => _note(
                          index: index,
                          header: _noteCubit.headerList[index],
                          body: _noteCubit.bodyList[index],
                          time: _noteCubit.timeList[index],
                          color: _noteCubit.colorList[index]));
                })),
        Positioned(
            left: 10,
            top: 45,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                  iconSize: 25,
                  onPressed: () => Navigator.pop(context),
                ),
                Text("Ghi chú của tôi",
                    style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600)),
                BlocBuilder<NoteCubit, NoteState>(
                    cubit: _noteCubit,
                    builder: (context, state) => IconButton(
                        icon:
                            Icon(state is EditMode ? Icons.delete : Icons.delete_forever, color: Colors.red, size: 30),
                        onPressed: () {
                          state is EditMode ? _noteCubit.changeToDeleteMode() : _noteCubit.changeToEditMode();
                          _controller.forward(from: 0.0);
                        })),
                BlocBuilder<NoteCubit, NoteState>(
                    cubit: _noteCubit,
                    builder: (context, state) => state is! EditMode
                        ? GestureDetector(
                            onTap: () {
                                _noteCubit.deleteSelectedList();
                              _noteCubit.changeToEditMode();
                            },
                            child: Text("Xoá",
                                style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600)))
                        : SizedBox())
              ],
            )),
        Positioned(
          child: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Colors.yellow[800],
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    child: AlertDialog(
                      actionsPadding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      title: Center(
                          child: Text("Tạo ghi chú mới",
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: SizeConfig.safeBlockVertical * 2.5))),
                      content: FormBuilder(
                          key: _formBuilderKey,
                          child: Column(children: [
                            FormBuilderTextField(
                                attribute: "header",
                                style: TextStyle(color: Colors.black, fontSize: 16),
                                validators: [FormBuilderValidators.required()],
                                decoration: InputDecoration(labelText: "Tiêu đề ghi chú")),
                            FormBuilderTextField(
                                attribute: "body",
                                style: TextStyle(color: Colors.black, fontSize: 16),
                                validators: [FormBuilderValidators.required()],
                                decoration: InputDecoration(
                                  labelText: "Nội dung ghi chú",
                                  hintStyle: TextStyle(color: Colors.black, fontSize: 16),
                                )),
                            SizedBox(height: SizeConfig.blockSizeVertical * 3),
                            BlocBuilder<NoteCubit, NoteState>(
                                cubit: _noteCubit,
                                builder: (context, state) => Container(
                                        child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Màu ghi chú :', style: TextStyle(color: Colors.black, fontSize: 13)),
                                        SizedBox(height: SizeConfig.blockSizeVertical * 2),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: _colors
                                              .map((color) => InkWell(
                                                    onTap: () => _noteCubit.setColorIndex(_colors.indexOf(color)),
                                                    child: AnimatedContainer(
                                                      duration: Duration(milliseconds: 300),
                                                      width: (_colors.indexOf(color) == _noteCubit.colorIndex)
                                                          ? SizeConfig.safeBlockHorizontal * 10
                                                          : SizeConfig.safeBlockHorizontal * 8,
                                                      height: (_colors.indexOf(color) == _noteCubit.colorIndex)
                                                          ? SizeConfig.safeBlockHorizontal * 10
                                                          : SizeConfig.safeBlockHorizontal * 8,
                                                      decoration: BoxDecoration(
                                                          color: Color(color),
                                                          border: (_colors.indexOf(color) == 4)
                                                              ? Border.all(color: Colors.black38)
                                                              : null,
                                                          borderRadius: BorderRadius.circular(5)),
                                                    ),
                                                  ))
                                              .toList(),
                                        )
                                      ],
                                    ))),
                          ])),
                      actions: <Widget>[
                        SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                        RaisedButton(
                            child: Container(
                              alignment: Alignment.center,
                              width: SizeConfig.safeBlockHorizontal * 22,
                              height: SizeConfig.safeBlockVertical * 5,
                              child: Text(
                                'Lưu lại',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            color: Color(0xFFE3161D),
                            onPressed: () {
                              if (_formBuilderKey.currentState.saveAndValidate()) {
                                _noteCubit.addNote(
                                    Map<String, String>.from(_formBuilderKey.currentState.value),
                                    "${DateFormat.yMd().format(DateTime.now()).toString()} ${DateFormat.Hm().format(DateTime.now()).toString()}",
                                    _colors[_noteCubit.colorIndex].toString());
                                Navigator.of(context).pop();
                              }
                            }),
                        SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                        RaisedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Container(
                            alignment: Alignment.center,
                            width: SizeConfig.safeBlockHorizontal * 22,
                            height: SizeConfig.safeBlockVertical * 5,
                            child: Text(
                              'Đóng',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          color: Color(0xFF464646),
                        ),
                        SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                      ],
                    ),
                    width: SizeConfig.safeBlockHorizontal * 80,
                  );
                }),
          ),
          bottom: 25,
          right: 25,
        )
      ],
    ));
  }

  Widget _note({int index, String header, String time, String body, String color}) {
    return BlocBuilder<NoteCubit, NoteState>(
        cubit: _noteCubit,
        builder: (context, state) => AnimatedBuilder(
            animation: offsetAnimation,
            builder: (buildContext, child) {
              return GestureDetector(
                onTap: () => state is! EditMode ? setState(() => _noteCubit.changeSelectedIndex(index)) : null,
                child: Container(
                  width: SizeConfig.blockSizeHorizontal * 40,
                  padding: EdgeInsets.only(
                      left: offsetAnimation.value != 0 ? offsetAnimation.value + 5.0 : 0,
                      right: offsetAnimation.value != 0 ? 5 - offsetAnimation.value : 0),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                              width: SizeConfig.blockSizeHorizontal * 40,
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: Text(
                                time,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                              decoration: BoxDecoration(color: Color(int.parse(color)))),
                          Container(
                              height: 100,
                              width: SizeConfig.blockSizeHorizontal * 40,
                              decoration: BoxDecoration(color: Color(int.parse(color))),
                              child: Stack(children: [
                                Container(
                                    height: 100,
                                    width: SizeConfig.blockSizeHorizontal * 40,
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5))),
                                Column(children: [
                                  Center(
                                      child: Text(header,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black))),
                                  Text(body,
                                      maxLines: 3,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black)),
                                ])
                              ]))
                        ],
                      ),
                      state is! EditMode
                          ? Positioned(
                              child: Checkbox(
                                  value: _noteCubit.selectedIndex.contains(index),
                                  onChanged: (value) => setState(() => _noteCubit.changeSelectedIndex(index))),
                              right: 0,
                              top: 0,
                            )
                          : SizedBox()
                    ],
                  ),
                ),
              );
            }));
  }
}

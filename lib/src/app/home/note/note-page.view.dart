import 'dart:ui';
import 'package:jlpt_testdate_countdown/src/env/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:jlpt_testdate_countdown/src/app/home/cubit/home.cubit.dart';
import 'package:jlpt_testdate_countdown/src/app/home/note/note-page.cubit.dart';
import 'package:jlpt_testdate_countdown/src/models/event/event.dart';
import 'package:jlpt_testdate_countdown/src/resources/data.dart';
import 'package:jlpt_testdate_countdown/src/utils/sizeconfig.dart';
import 'package:table_calendar/table_calendar.dart';


class NotePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotePageState();
  }
}

class _NotePageState extends State<NotePage> with SingleTickerProviderStateMixin {
  HomeCubit _homeCubit = HomeCubit();
  NoteCubit _noteCubit = NoteCubit();

  bool deleteMode = true;
  final TextEditingController textController = TextEditingController();
  GlobalKey<FormBuilderState> _formBuilderKey = GlobalKey<FormBuilderState>();
  final _colors = [0xFFad9d9d, 0xffF1E219, 0xff00A506, 0xffd0484e, 0xFF3282b8];

  AnimationController _animationController;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  final Map<DateTime, List> _holidays = {
    DateTime(2021, 1, 1): ['New Year\'s Day'],
    DateTime(2020, 1, 6): ['Epiphany'],
    DateTime(2020, 2, 14): ['Valentine\'s Day'],
    DateTime(2020, 4, 21): ['Easter Sunday'],
    DateTime(2020, 4, 22): ['Easter Monday'],
  };

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    _noteCubit.setSelectedEvent(day);
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
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
        Container(
            margin:
                EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 6, 100, SizeConfig.blockSizeHorizontal * 6, 20),
            child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
              SizedBox(height: SizeConfig.safeBlockVertical * 5),
              _buildTableCalendarWithBuilders(),
              SizedBox(height: SizeConfig.safeBlockVertical * 5),
              Expanded(child: _buildEventList()),
            ])),
        Positioned(
            left: 10,
            top: 45,
            child: SizedBox(
                width: SizeConfig.screenWidth,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                      iconSize: 25,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text("Ghi chú của tôi",
                        style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600)),
                    Expanded(child: SizedBox()),
                    BlocBuilder<NoteCubit, NoteState>(
                        cubit: _noteCubit,
                        builder: (context, state) => state is DeleteMode || state is ChangeSelectedIndex
                            ? Row(children: [
                                Checkbox(
                                    value: _noteCubit.selectedIndex.length == _noteCubit.headerList.length,
                                    activeColor: Colors.red,
                                    checkColor: Colors.white,
                                    onChanged: (value) => _noteCubit.addAll()),
                                Text('Tất cả',
                                    style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600))
                              ])
                            : SizedBox()),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 7,
                    )
                  ],
                ))),
        BlocBuilder<NoteCubit, NoteState>(
            cubit: _noteCubit,
            builder: (context, state) => state is DeleteMode || state is ChangeSelectedIndex
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: SizeConfig.screenWidth,
                      height: SizeConfig.blockSizeVertical * 8,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        )),
                        color: Colors.red.withOpacity(0.8),
                        onPressed: () {
                          _noteCubit.deleteSelectedList();
                          _noteCubit.changeToEditMode();
                        },
                        child: Row(
                          children: [
                            Expanded(child: SizedBox()),
                            Icon(Icons.delete, color: Colors.white, size: 25),
                            SizedBox(width: 10),
                            Text("Xoá",
                                style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600)),
                            Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ))
                : Positioned(
                    child: FloatingActionButton(
                        child: Icon(Icons.add),
                        backgroundColor: AppColor.brown2,
                        onPressed: () => _showDialog(context)),
                    bottom: 25,
                    right: 25,
                  ))
      ],
    ));
  }

  Widget _buildTableCalendarWithBuilders() {
    return BlocBuilder<NoteCubit, NoteState>(
        cubit: _noteCubit,
        builder: (context, state) => TableCalendar(
              locale: 'vi_VN',
              calendarController: _calendarController,
              events: _noteCubit.events,
              holidays: _holidays,
              initialCalendarFormat: CalendarFormat.week,
              formatAnimation: FormatAnimation.slide,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              availableGestures: AvailableGestures.all,
              availableCalendarFormats: const {
                CalendarFormat.month: '',
                CalendarFormat.week: '',
              },
              initialSelectedDay: DateTime.now(),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                outsideStyle: TextStyle().copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                weekdayStyle: TextStyle().copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                eventDayStyle: TextStyle().copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                weekendStyle: TextStyle().copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                holidayStyle: TextStyle().copyWith(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 18),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle().copyWith(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
                weekendStyle: TextStyle().copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
              ),
              headerStyle: HeaderStyle(
                centerHeaderTitle: true,
                leftChevronVisible: false,
                rightChevronVisible: false,
                formatButtonVisible: false,
                titleTextStyle: TextStyle().copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
              ),
              builders: CalendarBuilders(
                selectedDayBuilder: (context, date, _) {
                  return FadeTransition(
                    opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                      color: Colors.deepOrange[300],
                      width: 100,
                      height: 100,
                      child: Text(
                        '${date.day}',
                        style: TextStyle().copyWith(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
                todayDayBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                    color: Colors.amber[400],
                    width: 100,
                    height: 100,
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(fontSize: 16.0, color: Colors.white),
                    ),
                  );
                },
                markersBuilder: (context, date, events, holidays) {
                  final children = <Widget>[];

                  if (events.isNotEmpty) {
                    children.add(
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: _buildEventsMarker(date, events),
                      ),
                    );
                  }

                  if (holidays.isNotEmpty) {
                    children.add(
                      Positioned(
                        right: -2,
                        top: -2,
                        child: _buildHolidaysMarker(),
                      ),
                    );
                  }

                  return children;
                },
              ),
              onDaySelected: (date, events, holidays) {
                _onDaySelected(date, events, holidays);
                _animationController.forward(from: 0.0);
              },
              onVisibleDaysChanged: _onVisibleDaysChanged,
              onCalendarCreated: _onCalendarCreated,
            ));
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildEventList() {
    return BlocBuilder<NoteCubit, NoteState>(
        cubit: _noteCubit,
        buildWhen: (prev, now) => now is NoteLoaded,
        builder: (context, state) => state is NoteLoaded
            ? state.events != null
                ? Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...List.generate(
                              state.events.length, (index) => _note(index: index, event: state.events[index]))
                        ],
                      ),
                    ),
                  )
                : SizedBox()
            : SizedBox());
  }

  void _showDialog(BuildContext context, {Event event}) {
    showDialog(
        context: context,
        builder: (context) {
          event != null ? _noteCubit.setColorIndex(_colors.indexOf(event.color)) : null;
          return AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            title: Center(
                child: Text(event != null ? "Ghi chú của tôi" : "Tạo ghi chú mới",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: SizeConfig.safeBlockVertical * 2.5))),
            content: SingleChildScrollView(
              child: FormBuilder(
                  key: _formBuilderKey,
                  child: Column(children: [
                    FormBuilderTextField(
                        attribute: "header",
                        initialValue: event?.header ?? "",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        validators: [FormBuilderValidators.required(errorText: "Trường này không được để trống!")],
                        decoration: InputDecoration(labelText: "Tiêu đề ghi chú")),
                    FormBuilderTextField(
                        attribute: "body",
                        initialValue: event?.body ?? "",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        validators: [FormBuilderValidators.required(errorText: "Trường này không được để trống!")],
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
                                Text('Chọn màu', style: TextStyle(color: Colors.black, fontSize: 13)),
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
                                                  borderRadius: BorderRadius.circular(5)),
                                            ),
                                          ))
                                      .toList(),
                                )
                              ],
                            ))),
                  ])),
            ),
            actions: <Widget>[
              SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
              RaisedButton(
                  child: Container(
                    alignment: Alignment.center,
                    width: SizeConfig.safeBlockHorizontal * 22,
                    height: SizeConfig.safeBlockVertical * 5,
                    child: Text(
                      event != null ? 'Sửa' : 'Lưu',
                      style: TextStyle(color: Colors.black87, fontSize: 16,fontWeight: FontWeight.w500),
                    ),
                  ),
                  color: Colors.white,
                  onPressed: () {
                    if (_formBuilderKey.currentState.saveAndValidate()) {
                      event != null
                          ? _noteCubit.updateNote(Map<String, String>.from(_formBuilderKey.currentState.value),
                              _noteCubit.selectedDay.toString(), _colors[_noteCubit.colorIndex].toString(), event.index)
                          : _noteCubit.addNote(Map<String, String>.from(_formBuilderKey.currentState.value),
                              _noteCubit.selectedDay.toString(), _colors[_noteCubit.colorIndex].toString());
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
                    'Thoát',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                color: AppColor.brown,
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
            ],
          );
        });
  }

  Widget _note({int index, Event event}) {
    return BlocBuilder<NoteCubit, NoteState>(
        cubit: _noteCubit,
        buildWhen: (prev, now) => now is EditMode || now is DeleteMode || now is ChangeSelectedIndex,
        builder: (context, state) => GestureDetector(
            onTap: () {
              state is DeleteMode || state is ChangeSelectedIndex
                  ?  setState(() => _noteCubit.changeSelectedIndex(index))
                  : _showDialog(context, event: event);
            },
            onLongPress: () {
              _noteCubit.changeToDeleteMode();
              _noteCubit.changeSelectedIndex(index);
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0), color: Color(event.color).withOpacity(0.6)),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Stack(children: [
                  ListTile(
                    leading: Image.asset('assets/note_icon.png', height: 25, color: Colors.white),
                    title: Text(event.header, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  state is DeleteMode || state is ChangeSelectedIndex
                      ? Align(
                          child: Checkbox(
                              value: _noteCubit.selectedIndex.contains(index),
                              onChanged: (value) {
                                setState(() {
                                  _noteCubit.changeSelectedIndex(index);
                                });
                              }),
                          alignment: Alignment.centerRight,
                        )
                      : SizedBox()
                ]))));
  }
}

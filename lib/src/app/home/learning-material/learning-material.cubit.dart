import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jlpt_testdate_countdown/src/models/learning_data/learning_data.dart';
import 'package:jlpt_testdate_countdown/src/repositories/learning-material.repository.dart';
import 'package:jlpt_testdate_countdown/src/utils/exception.dart';
import 'package:jlpt_testdate_countdown/src/resources/data.dart';

part 'learning-material.state.dart';

class LearningMaterialCubit extends Cubit<LearningMaterialState> {
  final LearningMaterialRepository _repository;
  List<Data> learningData = <Data>[];
  int _take = 5;

  LearningMaterialCubit(this._repository) : super(LearningMaterialInitial()) {
    loadLearningData(_take);
  }

  List<Color> colorList = [
    Color(0xffff7844),
    Color(0xff61b15a),
    Color(0xffb088f9),
    Color(0xffd68060),
    Color(0xff9f5f80),
    Color(0xffff7844),
    Color(0xff61b15a),
    Color(0xffb088f9),
    Color(0xffd68060),
    Color(0xff9f5f80),
    Color(0xffff7844),
  ];
  List<String> subjects = ["Toán", "Lý", "Hóa", "Sinh", "Văn", "Anh", "Sử", "Địa", "GDCD"];
  List<String> subjectNoCapitals = ["toan", "ly", "hoa", "sinh", "van", "anh", "su", "dia", "gdcd"];

  Future<void> loadLearningData(int take) async {
    Map<String, dynamic> params = {"take": take};
    try {
      emit(LearningMaterialLoading());
      learningData = await _repository.fetchLearningBaseOnParams(params);
      emit(LearningMaterialDataLoaded(learningData));
    } on NetworkException {
      emit(LearningMaterialError("Couldn't fetch data. Is the device online?"));
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      emit(LearningMaterialDeleting());
      if (await _repository.deleteMaterial(id)) {
        emit(LearningMaterialDeleted());
      } else {
        emit(LearningMaterialError("Change failed"));
      }
    } on NetworkException {
      emit(LearningMaterialError("Error Changing data"));
    }
  }

  void pull() {
    _take += 5;
    loadLearningData(_take);
  }

  void reset() {
    _take = 5;
  }
}

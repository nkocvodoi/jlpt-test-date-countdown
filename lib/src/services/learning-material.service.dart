
import 'package:jlpt_testdate_countdown/src/env/application.dart';

class LearningMaterialService {
  static Future<dynamic> getAllLearningMaterial() {
    return Application.api.get("/documents");
  }
}

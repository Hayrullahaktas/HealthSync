// lib/core/utils/storage_utils.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../constants/storage_constants.dart';

class StorageUtils {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<void> writeFile(String filename, String content) async {
    final file = await _localFile(filename);
    await file.writeAsString(content);
  }

  Future<String> readFile(String filename) async {
    try {
      final file = await _localFile(filename);
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  Future<void> saveProfileImage(File imageFile) async {
    final file = await _localFile(StorageConstants.userProfileImage);
    await imageFile.copy(file.path);
  }

  Future<void> saveExerciseLog(String log) async {
    final file = await _localFile(StorageConstants.exerciseLogs);
    await file.writeAsString(log, mode: FileMode.append);
  }

  Future<void> saveNutritionLog(String log) async {
    final file = await _localFile(StorageConstants.nutritionLogs);
    await file.writeAsString(log, mode: FileMode.append);
  }
}
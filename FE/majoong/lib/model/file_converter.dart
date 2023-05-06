import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

class FileConverter implements JsonConverter<File, String> {
  const FileConverter();

  @override
  File fromJson(String json) {
    throw UnimplementedError();
  }

  @override
  String toJson(File object) {
    if (object == null) {
      return '';
    }
    return object.path;
  }
}
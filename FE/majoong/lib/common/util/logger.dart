import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0)
);

var loggerWith3Method = Logger(
  printer: PrettyPrinter(methodCount: 3)
);

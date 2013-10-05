/*
 * author: N, calathus
 * date: 9/23/2013
 */
library static_mirror_generator;

import "package:portable_mirror/static_mirror_generator.dart";

import '../lib/src/models.dart';


main() {
  String fileName = "sample_mirror_impl_v1";
  print("start generation${fileName}.java");
  StaticMirrorGenerator.generate(fileName, [Expense, Expense]);
  print("finished.");
}

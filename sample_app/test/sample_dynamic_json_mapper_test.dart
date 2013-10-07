library sample_json_mapper_test;

import '../lib/src/models.dart';
import '../lib/src/test_models.dart';

import "package:portable_mirror/mirror_dynamic_lib.dart";

import '../lib/src/sample_json_mapper.dart';

part 'sample_common_json_mapper_test.dart';

main() {
  initClassMirrorFactory();
  
  test_simple_model();
  
  test_json_mapper();
}

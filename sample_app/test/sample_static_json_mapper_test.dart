library sample_json_mapper_test;

import '../lib/src/models.dart';
import '../lib/src/test_models.dart';

import '../lib/src/sample_mirror_impl.dart' as SAMPLE;
import '../lib/src/test_mirror_impl.dart' as TEST;

import '../lib/src/sample_json_mapper.dart';

part 'sample_common_json_mapper_test.dart';

main() {
  TEST.initClassMirrorFactory();
  test_simple_model();
  
  SAMPLE.initClassMirrorFactory();
  test_json_mapper();
}

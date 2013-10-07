/*
 * author: N, calathus
 * date: 9/23/2013
 */
library sample_generic_gui;

import 'dart:html';

import "package:gui_component/gui_component_lib.dart";
import "package:couchdb/client/couchdb_client.dart";

import "../lib/src/models.dart";
import "../lib/src/sample_mirror_impl.dart";
import "../lib/src/sample_json_mapper.dart";

part 'sample_common_generic_gui.dart';

main() {
  
  // register reflection factory
  initClassMirrorFactory();
  
  Element uiContainer = document.query("#sample_generic_gui");
  CRUDView app = new CRUDView(null, uiContainer);
}

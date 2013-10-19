/*
 * author: N, calathus
 * date: 9/23/2013
 */
library sample_generic_gui;

import 'dart:html';

import "package:gui_component/gui_annotation.dart";
import "package:gui_component/gui_component_lib.dart";
import "package:couchdb/client/couchdb_client.dart";
import "package:portable_mirror/mirror_dynamic_lib.dart";

import "../lib/src/models.dart";
import "../lib/src/sample_json_mapper.dart";

part 'sample_common_generic_gui.dart';

main() {
  // register reflection factory
  initClassMirrorFactory();
  
  Element uiContainer = document.query("#sample_generic_gui");
  CRUDView app = new CRUDView();
  uiContainer.nodes.add(app.element); // this 'element' tiggers DOM node creation!

}

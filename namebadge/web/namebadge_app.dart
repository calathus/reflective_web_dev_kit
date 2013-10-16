/*
 * author: N, calathus
 * date: 9/23/2013
 */
library namebadge_app;

import 'dart:html';

import "package:portable_mirror/mirror_dynamic_lib.dart";
import "name_badge_element.dart";

main() {

  // register reflection factory
  initClassMirrorFactory();
  
  Element uiContainer = document.query("#namebadge");
  NameBadge app = new NameBadge(null);
  uiContainer.nodes.add(app.element); // this 'element' tiggers DOM node creation!

}

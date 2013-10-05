/*
 * author: N, calathus
 * date: 9/23/2013
 */
library gui_component_lib;

import 'dart:html';
import 'package:portable_mirror/mirror_api_lib.dart';

part 'src/gui_input_comp.dart';
part 'src/gui_generic_form.dart';
part 'src/gui_generic_table.dart';


/*
 * Component should be created from top down, while DOM node should be created from bottom up
 */
typedef Element Listener(Event evt, Component comp);
typedef void ComponentAction(Event event, Component c);

abstract class Component {
  static int _gid = 0;
  
  final int id = _gid++;
  final List<String> classes; // better not to be modified!!
  Element _element;
  final List<ComponentAction> _listeners = []; 
  
  final Component parent;
  final List<Component> children = [];
  
  
  Component(Component this.parent, List<String> this.classes) {
    if (parent != null) parent.children.add(this);
  }
  
  List<ComponentAction> get listeners => _listeners;
  
  // DOM
  // lazy evaluation
  Element get element => (_element == null)?_element = _createElement():_element;
  
  Element _createElement() =>
    createElement()
      ..id = "cid-${id}"
      ..classes.addAll(classes);

  Element createElement();
  Element update();
  
  Element addSubComponents(List<Component> comps, Element elm, Element f(Component c)) => 
      addListeners(comps.fold(elm, (Element elm0, Component c)=>elm0..nodes.add(f(c))));
  
  Element addListeners(Element elm) => listeners.fold(elm, (elm, action)=>elm..onClick.listen((e)=>action(e, this)));
  
  Element newElem(String tagName) => new Element.tag(tagName);
  Element initElem() => element..nodes.clear();
  
  Element getElement(Component c)=>c.element;
  Element updateComponent(Component c)=>c.update();
  
  //
  // utils
  //
  Component topComponent() =>  (parent == null)?this:parent.topComponent();
  
  Component findById(int id0) {
    if (id0 == id) {
      return this;
    }
    for (Component c in children) {
      Component c0 = c.findById(id0);
      if (c0 != null) {
        return c0;
      }
    }
    return null;
  }
  
  dynamic fold(var initialValue, dynamic combine(var previousValue, Component child)) =>
    children.fold(combine(initialValue, this), (pr, child) => child.fold(pr, combine));
}

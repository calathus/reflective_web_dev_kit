/*
 * author: N, calathus
 * date: 9/23/2013
 */
library gui_component_lib;

import 'dart:html';
import 'package:portable_mirror/mirror_api_lib.dart';
import 'package:portable_mirror/mirror_static_lib.dart';
import 'gui_annotation.dart';

part 'src/gui_input_comp.dart';
part 'src/gui_generic_form.dart';
part 'src/gui_generic_table.dart';


/*
 * Component should be created from top down, while DOM node should be created from bottom up
 */
typedef Element Listener(Event evt, Component comp);
typedef void ComponentAction(Event event, Component c);

//abstract class Component extends Monitor {
abstract class Component {
  static int _gid = 0;
  
  // temp
  bool get introspection => true;
  
  final int id = _gid++;
  final List<String> classes = []; // better not to be modified!!
  Element _element;
  final List<ComponentAction> _listeners = []; 
  
  Component _parent;
  final List<Component> children = [];
  
  // dirty trick to avoid current drt bug/restriction(no support od reflected(Type). (we need to call constructor to getType)
  static bool _supress_init = false;
  static Type reflectedType(Object create()) {
    _supress_init = true;
    Object obj = create();
    _supress_init = false;
    return obj.runtimeType;
  }
  
  Component() {
    if (_supress_init) return;
    initSubComp();
  }
  
  factory Component.create() {
    _supress_init = true;
  }
  
  Component get parent => _parent;
  void set parent(Component v) { 
    _parent = v;
    if (_parent != null) _parent.children.add(this);
  }
  
  List<ComponentAction> get listeners => _listeners;
  
  void initSubComp() {
    if (!introspection) {
      return;
    }
    IInstanceMirror imirror = ClassMirrorFactory.reflect(this);
    
    imirror.cmirror.fieldTypes.forEach((Symbol symbol, IFieldType ft){
      if (!ft.name.startsWith('_')) {
        //return;
      }
      //UI_Input ui_input = getAnnotation(ft.metadata, (Object obj)=>obj is UI_Input);
      UI_Comp ui_comp = getAnnotation(ft.metadata, (Object obj){
        //print(">>>>> ${ft.name}, ${obj}, ${obj.runtimeType}, ${obj is UI_Comp}");
        return obj is UI_Comp;
      });
      //print(">> 1 ${ft.name} ui_input ${ui_comp}");
      if (ui_comp == null) return;
      //print(">> 2 ${ft.name} ui_input ${ui_comp}");
      
      //
      // when field is annotated
      //
      IField field = imirror.getField(symbol);
      Object obj = field.value;
      if (!(obj is Component)) {
        throw new Exception('field type is not Component! type: ${obj.runtimeType}, name: ${symbol}');
      }
      Component c = obj;
      c.parent = this;
        
      // super class of all UI_Inputs
      //print("ui_input ${ui_comp.runtimeType}, c: ${c.runtimeType}");
      if (ui_comp is UI_Input && c is InputComp) {
        UI_Input ui_input = ui_comp;
        InputComp inputComp = c;
        //print(">> 3 ${ft.name} initSubComp ");
        if (ui_input.label != null) inputComp.label = ui_input.label;
        if (ui_input.name != null) inputComp.name = ui_input.name;
        if (ui_input.classes != null) inputComp.classes.addAll(ui_input.classes);
        
        if (ui_input is UI_TextInput && c is TextInputComp) {
          UI_TextInput ui_textInput = ui_input;
          TextInputComp textInputComp = c;
          if (ui_textInput.type != null) textInputComp.type = ui_textInput.type;
        } else if (ui_input is UI_TextArea && c is TextAreaComp) {
          
          
        } else if (ui_input is UI_Checkbox && c is CheckboxComp) {
          UI_Checkbox ui_checkbox = ui_input;
          CheckboxComp checkboxComp = c;
          if (ui_checkbox.checked != null) checkboxComp.checked = ui_checkbox.checked;
          
        } else if (ui_input is UI_Radio && c is RadioComp) {
          UI_Radio ui_radio = ui_input;
          RadioComp radioComp = c;
          if (ui_radio.checked != null) radioComp.checked = ui_radio.checked;
        } else if (ui_input is UI_Select && c is SelectComp) {
          UI_Select ui_select = ui_input;
          SelectComp selectComp = c;
          if (ui_select.selectedIndex != null) selectComp.selectedIndex = ui_select.selectedIndex;
        } else {
          throw new Exception("annotation and annotated type doed not match, name: ${symbol} anno: ${ui_input.runtimeType}, type: ${c.runtimeType}");
        }
      }
      if (ui_comp is UI_Button && c is ButtonComp) {
        UI_Button ui_button = ui_comp;
        ButtonComp buttonComp = c;
        if (ui_button.name != null) buttonComp.name = ui_button.name;
        if (ui_button.classes != null) buttonComp.classes.addAll(ui_button.classes);
        if (ui_button.label != null) buttonComp.label = ui_button.label;
      } else if (ui_comp is UI_Table && c is Table) {
        // TODO
      } else if (ui_comp is UI_Form && c is Form) {
        // TODO
      } 
    });
  }

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

Object getAnnotation(List list, bool cond(Object obj)) {
  for (Object obj in list) {
    if (obj is IInstanceMirror) {
      IInstanceMirror imirr = obj;
      if (cond(imirr.reflectee)) {
        return imirr.reflectee;
      }
    }
  }
  return null;
}

Type _DateTime = DateTime;
Type _GUI_Table = GUI_Table;
Type _GUI_Form = GUI_Form;
Type _UI_TextInput = UI_TextInput;
Type _UI_TextArea = UI_TextArea;
Type _UI_Radio = UI_Radio;
Type _UI_Checkbox = UI_Checkbox;
Type _UI_Select = UI_Select;
Type _UI_Button = UI_Button;
Type _UI_Table = UI_Table;
Type _UI_Form = UI_Form;

Map<Type, DefaultConstroctorFun> staticSystemClassMirrorFactory = {}
..[_DateTime]= (()=>new StaticClassMirror(_DateTime, ()=>new DateTime(0), {}))
..[_GUI_Table]= (()=>new StaticClassMirror(_GUI_Table, ()=>const GUI_Table(), {}))
..[_GUI_Form]= (()=>new StaticClassMirror(_GUI_Form, ()=>const GUI_Form(), {}))
..[_UI_TextInput]= (()=>new StaticClassMirror(_UI_TextInput, ()=>const UI_TextInput(), {}))
..[_UI_TextArea]= (()=>new StaticClassMirror(_UI_TextArea, ()=>const UI_TextArea(), {}))
..[_UI_Radio]= (()=>new StaticClassMirror(_UI_Radio, ()=>const UI_Radio(), {}))
..[_UI_Checkbox]= (()=>new StaticClassMirror(_UI_Checkbox, ()=>const UI_Checkbox(), {}))
..[_UI_Select]= (()=>new StaticClassMirror(_UI_Select, ()=>const UI_Select(), {}))
..[_UI_Button]= (()=>new StaticClassMirror(_UI_Button, ()=>const UI_Button(), {}))
..[_UI_Table]= (()=>new StaticClassMirror(_UI_Table, ()=>const UI_Table(), {}))
..[_UI_Form]= (()=>new StaticClassMirror(_UI_Form, ()=>const UI_Form(), {}))
;

CMirrorFun getCMirrorFun(Map<Type, DefaultConstroctorFun> staticClassMirrorFactory) {
  return (Type type) {
    DefaultConstroctorFun ctor = staticClassMirrorFactory[type];
    if (ctor == null) {
      ctor = staticSystemClassMirrorFactory[type];
    }
    if (ctor == null) {
      throw new Exception(">> no DefaultConstroctorFun is defined for: ${type}");
    }
    return ctor();
  };
}

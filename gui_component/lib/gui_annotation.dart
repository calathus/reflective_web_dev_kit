library gui_annotation;

//
//
//

class GUI_Table {
  final String label;
  final bool invisible;
  const GUI_Table({this.label, this.invisible: false});
}

class GUI_Form {
  final String label;
  final bool readOnly;
  final bool disabled;
  final bool checked;
  const GUI_Form({this.label, this.readOnly: false, this.disabled: false, this.checked: false});
}

//
// Annotations for field proper of Component class
//
// this is used to suppress reflective initialization for component object.
// shoud not be used for defined componenet classes..
//
/*
class UI_System {
  final bool introspection;
  const UI_System({this.introspection: true});
}
*/

abstract class UI_Comp {
  final String name;
  final List<String> classes;
  const UI_Comp({this.name, this.classes});
}

//
// input
//
abstract class UI_Input extends UI_Comp {
  final String label;
  const UI_Input({String name, List<String> classes, this.label}): super(name: name, classes: classes);
}

class UI_TextInput extends UI_Input {
  final Type type;
  const UI_TextInput({this.type, String name, List<String> classes, String label})
  : super(name: name, classes: classes, label: label);
}

class UI_TextArea extends UI_Input {
  const UI_TextArea({String name, List<String> classes, String label})
  : super(name: name, classes: classes, label: label);
}

class UI_Radio extends UI_Input {
  final bool checked;
  const UI_Radio({String name, List<String> classes, String label, this.checked: false})
  : super(name: name, classes: classes, label: label);
}

class UI_Checkbox extends UI_Input {
  final bool checked;
  const UI_Checkbox({String name, List<String> classes, String label, this.checked: false})
  : super(name: name, classes: classes, label: label);
}

class UI_Select extends UI_Input {
  final int selectedIndex;
  const UI_Select({String name, List<String> classes, String label, this.selectedIndex: 0})
  : super(name: name, classes: classes, label: label);
}

//
//
//
class UI_Button extends UI_Comp {
  final String label;
  const UI_Button({String name, List<String> classes, this.label})
  : super(name: name, classes: classes);
}

class UI_Table extends UI_Comp {
  const UI_Table({String name, List<String> classes})
  : super(name: name, classes: classes);
}

class UI_Form extends UI_Comp {
  const UI_Form({String name, List<String> classes})
  : super(name: name, classes: classes);
}


main() {
  GUI_Table tb = new GUI_Table(invisible: true);
  print("invisible: ${tb.invisible}");
}
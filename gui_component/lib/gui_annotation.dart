library gui_annotation;

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

main() {
  GUI_Table tb = new GUI_Table(invisible: true);
  print("invisible: ${tb.invisible}");
}
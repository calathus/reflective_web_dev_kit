/*
 * author: N, calathus
 * date: 9/23/2013
 */
part of gui_component_lib;


typedef void MouseEventHandler(event);

class ButtonComp extends Component {
  static const String TABLE = "g_button_c";
  // temp
  bool get introspection => false;

  String name;
  bool disabled;
//  bool invisible;
  String label;
  MouseEventHandler _onClick;

  /*  
  ButtonComp({Component parent, this.label, MouseEventHandler onClick, List<String> classes: const [TABLE]}): super(parent: parent, classes:classes){
    _onClick = onClick;
  }
  */
  void onClick(MouseEventHandler v) { _onClick = v;}
  
  ButtonElement get node => (element as ButtonElement);
  
  Element get element => (super.element as ButtonElement);

  // DOM
  Element createElement() => addSubComponents0(new ButtonElement());
  
  Element update() => addSubComponents0(initElem());
      
  Element addSubComponents0(Element elm) => addListeners(
      (elm as ButtonElement)
        ..nodes.add(newElem("label")..text = label)
        // [TODO]
//        ..attributes['name'] = name
        ..text = label
        ..disabled = disabled
        ..onClick.listen(_onClick));
}

//
//
//
abstract class InputComp extends Component {
  String label;
//  Type type;
  String name;
  GUI_Form _form_anno;
  Symbol monitored;
  IField field;
  // temp
  bool get introspection => false;
  /*
  InputComp({Component parent, this.label, this.name, this.disabled, this.invisible, List<String> classes}): super(parent: parent, classes:classes);
  */
  Object get value;
  void set value(Object v);
  
  Element get inputElem;
  
  void set options(GUI_Form form_anno) {
    _form_anno = form_anno;
  }
  /*
  void bindProperty(Object monitordObject, Symbol symbol, void action()) {
    IInstanceMirror imirr = ClassMirrorFactory.reflect(monitordObject); // this won't work for generic parent class!! [TODO]
    this.field = imirr.getField(monitored);
    if (this.field == null) {
      throw new Exception('field not found, parent: ${parent.runtimeType}, symbol: ${monitored}');
    }
    listeners.add((_, comp){ 
      action();
    });
  }
  */
  void onClick(void action(Event e, Component c)) {
    listeners.add(action);
  }
  
  Element createElement() => addSubComponents0(newElem("div"));
  
  Element update() => addSubComponents0(initElem());
  
  // should support update inputElem?? 
  Element addSubComponents0(Element elm) => addListeners(
      elm
        ..nodes.add(newElem("label")..text = label)
        ..nodes.add(
            ((name != null)?(inputElem..attributes['name'] = name):inputElem)));
}

class TextInputComp extends InputComp {
  static const String TEXT_INPUT = "g_text_input";
  Type type;
  
  InputElement _inputElem;
  /*
  TextInputComp({Type this.type, Component parent, String label, String name, List<String> classes: const [TEXT_INPUT]}): super(parent: parent, label: label, name: name, classes: classes);
  */
  TextInputComp() {
    this.classes.add(TEXT_INPUT);
  }
  Object get value => stringToObject(_inputElem.value, type);
  
  void set value(Object v) {
    _inputElem.value = objectToString(v, type); 
  }
  
  InputElement get inputElem {
    if (_inputElem == null) {
      _inputElem = newElem("input");
      if (type == DateTime) {
        _inputElem..type = "date";
      } 
    }
    if (_form_anno != null) {
      _inputElem
        ..readOnly = _form_anno.readOnly
        ..disabled = _form_anno.disabled;
    }
    return _inputElem;
  }
}

class TextAreaComp extends InputComp {
  static const String TEXTAREA_INPUT = "g_textarea_input";
  
  TextAreaElement _inputElem;

  TextAreaComp() {
    this.classes.add(TEXTAREA_INPUT);
  }
  Object get value => _inputElem.value;
  
  void set value(Object v) {
    _inputElem.value = v; 
  }
  
  TextAreaElement get inputElem {
    if (_inputElem == null) {
      _inputElem = newElem("textarea");
    }
    if (_form_anno != null) {
      _inputElem
        ..readOnly = _form_anno.readOnly
        ..disabled = _form_anno.disabled;
    }
    return _inputElem;
  }
}

class CheckboxComp extends InputComp {
  static const String CHECKBOX_INPUT = "g_checkbox_input";
  
  InputElement _inputElem;
  bool checked;

  CheckboxComp() {
    this.classes.add(CHECKBOX_INPUT);
  }
  Object get value => _inputElem.checked;
  
  void set value(bool v) {
    _inputElem.checked = v; 
  }
  
  InputElement get inputElem {
    if (_inputElem == null) {
      _inputElem = newElem("input");
      _inputElem..type = "checkbox";
    }
    if (_form_anno != null) {
      _inputElem
        ..readOnly = _form_anno.readOnly
        ..disabled = _form_anno.disabled;
    }
    return _inputElem;
  }
}

class RadioComp extends InputComp {
  static const String RADIO_INPUT = "g_radio_input";
  
  //String init_v;
  bool checked;
  InputElement _inputElem;
  /*
  RadioComp({Component parent, String label, this.init_v, this.checked, String name, List<String> classes: const [RADIO_INPUT]}): super(parent: parent, label: label, name: name, classes: classes);
  */
  RadioComp() {
    this.classes.add(RADIO_INPUT);
  }
  Object get value => _inputElem.value;
  
  void set value(String v) {
    _inputElem.value = v; 
  }
  
  InputElement get inputElem {
    if (_inputElem == null) {
      _inputElem = (newElem("input") as InputElement)
        ..type = "radio"
        //..value = init_v
        ..checked = checked
      ;
    }
    if (_form_anno != null) {
      _inputElem
        ..checked = _form_anno.checked
        ..readOnly = _form_anno.readOnly
        ..disabled = _form_anno.disabled;
    }
    return _inputElem;
  }
}

abstract class SelectComp<T> extends InputComp {
  static const String SELECT_INPUT = "g_select_input";
  
  List<T> _expenseTypeList;
  int selectedIndex;
  
  SelectElement _selectElem;
  /*
  SelectComp({Component parent, String label, Type type, String name, List<String> classes: const [SELECT_INPUT]}): super(parent: parent, label: label, name: name, classes: classes) {
    _expenseTypeList = entityTypes.values.toList();
  }
  */
  SelectComp() {
    this.classes.add(SELECT_INPUT);
    _expenseTypeList = entityTypes.values.toList();
  }
  Map<String, T> get entityTypes;
  
  Object get value {
    SelectElement selectElem = inputElem;
    if (selectElem.selectedIndex > 0) {
      var option = selectElem.options[selectElem.selectedIndex];
      var typeCode = option.value;
      return entityTypes[typeCode];
    }
    return null;
  }
  
  void set value(T v) {
    int idx = 0;
    if (v != null) {
      idx = _expenseTypeList.indexOf(v); // if not found then -1 
      idx++;
    }
    OptionElement oe = _selectElem.nodes[idx];
    oe.selected = true;
  }

  Element get inputElem {
    if (_selectElem == null) {
      _selectElem = new SelectElement()
        ..nodes.addAll(_getOptions());
    }
    return _selectElem;//how to make readonly???
  }
  
  String getCode(T t);
  String getName(T t);
  
  List<Element> _getOptions() =>
    _expenseTypeList.fold([new OptionElement()..value = ''..selected = true], (oes, T et)=>
        oes..add(
            new OptionElement()
              ..value = '${getCode(et)}'
              ..text = '${getName(et)}'
              //..selected = (et == selectedExpenseType)
                  )
    );
}


//
// Utils
//
typedef InputComp InputCompFactory(Component comp, String name, Type t);

class InputFactoryCache {
  static final Map<String, InputCompFactory> predefinedInputCompMap = {
//    'textarea': (Component comp, String name, Type t)=>new TextAreaComp(parent: comp, name: name)
       'textarea': (Component comp, String name, Type t)=>new TextAreaComp()..parent = comp..name = name
  };
  static final Map<Type, InputCompFactory> defaultSpecialInputCompMap = {
//    bool: (Component comp, String name, Type t)=>new CheckboxComp(parent: comp, name: name)
    bool: (Component comp, String name, Type t)=>new CheckboxComp()..parent = comp..name = name
  };
  
  Map<String, String> adhocCompMap = {};
  Map<Type, InputCompFactory> specialInputCompMap = {};
/*  
  InputFactoryCache(this.adhocCompMap, this.specialInputCompMap);
  */
  InputFactoryCache();
  
  InputComp getInputComp(Component c, String name, Type t) {
    InputCompFactory inputfact = null;
    String key = adhocCompMap[name];
    
    if (key != null) {
      inputfact = predefinedInputCompMap[key];
      if (inputfact != null) {
        return inputfact(c, name, t);
      }
    }
    inputfact = specialInputCompMap[t];
    if (inputfact != null) {
      return inputfact(c, name, t);
    }
    inputfact = defaultSpecialInputCompMap[t];
    if (inputfact != null) {
      return inputfact(c, name, t);
    }
//    return new TextInputComp(parent: c, name: name, type: t);
    return new TextInputComp()..parent = c..name = name..type = t;
  }
}

//
//
//
Object stringToObject(String sv, Type type) {
  if (type == String) {
    return sv;
  } else if (type == num) {
    if (sv.contains('.')) {
      return double.parse(sv);
    } else {
      return int.parse(sv);
    }
  } else if (type == int) {
    return int.parse(sv);
  } else if (type == double ) {
    return double.parse(sv);
  } else if (type == bool) {
    //print(">>>>stringToObject: ${sv}");
    return sv == 'true';
  } else if (type == DateTime) {
    //print(">> s: ${sv}");
    DateTime dt = DateTime.parse(sv);
    //print(">> s: ${sv}, dt: ${dt}");
    return dt;
  } else if (sv == "") {
    return null;
  } else {
    return null; // temp
  }
}

String objectToString(Object v, Type type) {
  if (v == null) {
    return "";
  } else if (type == String) {
    return v;
  } else if (type == num) {
    return v.toString();
  } else if (type == int) {
    return v.toString();
  } else if (type == double ) {
    return v.toString();
  } else if (type == bool) {
    //print(">>>>objectToString: ${v}");
    return v.toString();
  } else if (type == DateTime) {
    return _getDate(v);
  } else {
    return v.toString();
  }
}

String _getDate(DateTime date) => (date != null)?"${_blankIfNull(date.year)}-${_getMonth(_blankIfNull(date.month))}-${_getDay(_blankIfNull(date.day))}":"";
Object _blankIfNull(Object o) =>(o == null)?"":o;
String _getDay(day) => (day.toString().length == 1)?"0$day":day.toString();
String _getMonth(month) => (month.toString().length == 1)?"0$month":month.toString();

String getSymbolName(Symbol symbol) => symbol.toString().substring('Symbol("'.length, symbol.toString().length-2);



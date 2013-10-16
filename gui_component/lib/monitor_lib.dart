/*
 * author: N, calathus
 * date: 10/12/2013
 */
library receptor_lib;

import 'package:portable_mirror/mirror_api_lib.dart';
import "package:portable_mirror/mirror_dynamic_lib.dart";

typedef Object GetListener(Object target, Object old_value);
typedef void SetListener(Object target, Object old_value, Object new_value);

class FieldState {
  final Monitor parent;
  
  final List<GetListener> getListeners = [];
  final List<SetListener> setListeners = [];
  /*
  bool initialized = false;
  bool modified = false;
  Object value;
  */
  final IField field;
  
  FieldState(this.parent, this.field);
  
  // this supports lazy evaluation..
  Object get() {
    //print('FieldState get 1');
    Object old_value = field.value;
    //print('FieldState.get: parent ${parent} symbol: ${symbol} old_value ${old_value}');
    old_value = StaticReceptorListener.get(parent, field.symbol, old_value);
    //print('FieldState get 2');
    for (GetListener getlistner in getListeners) {
      Object new_value = getlistner(parent, old_value);
      if (new_value != null) { //??? too restrictive?? for lazy evaluation, this is OK
        old_value = new_value;
      }
    }
    if (old_value != field.value) {
      field.value = old_value;
    }
    return field.value;
  }
  
  void set(Object value) {
    Object old_value = field.value;
    field.value = value;
    print('>>>1 FieldState.set: v: ${value}');
    StaticReceptorListener.set(parent, field.symbol, old_value, value);
    print('>>>2 FieldState.set: old_v: ${old_value} v: ${value} ${setListeners.length}');
    for (SetListener setlistner in setListeners) {
      setlistner(parent, old_value, value);
      print('>>>3 FieldState.set: old_v: ${old_value} v: ${value}');
    }
  }
}

class ClassListener {
  final Type type;
  final Map<Symbol, List<GetListener>> getStaticListeners = {};
  final Map<Symbol, List<SetListener>> setStaticListeners = {};
  
  ClassListener(this.type);
}

class StaticReceptorListener {
  // common to all object for given type
  static final Map<Type, ClassListener> _classListeners = {};
  
  //
  static void addGetStaticListener(Type type, Symbol symbol, GetListener getStaticListener) {
    _getGetStaticListeners(_getClassListener(type), symbol).add(getStaticListener);
  }
  static void removeGetStaticListener(Type type, Symbol symbol, GetListener getStaticListener) {
    _getGetStaticListeners(_getClassListener(type), symbol).remove(getStaticListener);
  }
  static void removeAllFieldGetStaticListener(Type type, Symbol symbol) {
    _getGetStaticListeners(_getClassListener(type), symbol).clear();
  }
  static void removeAllGetStaticListener(Type type) {
    ClassListener classListener = _getClassListener(type);
    classListener.getStaticListeners.forEach((symbol, _){
      _getGetStaticListeners(classListener, symbol).clear();
    });
  }
  
  static void addSetStaticListener(Type type, Symbol symbol, SetListener setStaticListener) {
    _getSetStaticListeners(_getClassListener(type), symbol).add(setStaticListener);
  }
  static void removeSetStaticListener(Type type, Symbol symbol, SetListener setStaticListener) {
    _getSetStaticListeners(_getClassListener(type), symbol).remove(setStaticListener);
  }
  static void removeAllFieldSetStaticListener(Type type, Symbol symbol) {
    _getSetStaticListeners(_getClassListener(type), symbol).clear();
  }
  static void removeAllSetStaticListener(Type type) {
    ClassListener classListener = _getClassListener(type);
    classListener.setStaticListeners.forEach((symbol, _){
      _getSetStaticListeners(classListener, symbol).clear();
    });
  }
  
  //
  static List<GetListener> _getGetStaticListeners(ClassListener classListener, Symbol symbol) {
    List<GetListener> getStaticListeners = classListener.getStaticListeners[symbol];
    if (getStaticListeners == null) {
      classListener.getStaticListeners[symbol] = getStaticListeners = [];
    }
    return getStaticListeners;
  }
  
  static List<SetListener> _getSetStaticListeners(ClassListener classListener, Symbol symbol) {
    List<SetListener> setStaticListeners = classListener.setStaticListeners[symbol];
    if (setStaticListeners == null) {
      classListener.setStaticListeners[symbol] = setStaticListeners = [];
    }
    return setStaticListeners;
  }
  
  static ClassListener _getClassListener(Type type) {
    ClassListener classListener = _classListeners[type];
    if (classListener == null) {
      _classListeners[type] = classListener = new ClassListener(type);
    }
    return classListener;
  }
  
  //
  //
  //
  static Object get(Object parent, Symbol symbol, Object old_value) {
    ClassListener classListener = _getClassListenerFromObject(parent);
    //print('>> get classListener: ${classListener}');
    if (classListener != null) {
      List<GetListener> getlisteners = classListener.getStaticListeners[symbol];
      if (getlisteners != null) {
        for (GetListener getlistner in getlisteners) {
          Object new_value = getlistner(parent, old_value);
          if (new_value != null) {
            old_value = new_value;
          }
        }
      }
    }
    return old_value;
  }
  
  static void set(Object parent, Symbol symbol, Object old_value, Object value) {
    ClassListener classListener = _getClassListenerFromObject(parent);
    if (classListener != null) {
      List<SetListener> setlisteners = classListener.setStaticListeners[symbol];
      if (setlisteners != null) {
        for (SetListener setlistener in setlisteners) {
          setlistener(parent, old_value, value);
        }
      }
    }
  }
  
  static ClassListener _getClassListenerFromObject(Object parent) {
    return _classListeners[parent.runtimeType]; // exact class.. no subclass elation are considered!
  }

}

class Monitor {
  Type _type;
  final Map<Symbol, FieldState> _fields = {};
  
  // in order to use for Mixin, a constructor must not be defined.
  /*
  Receptor() {
    _type = this.runtimeType;
    init();
  }
  */
  
  Type get type=>_type;
  
  void _init() {
    if (_type != null) {
      return;
    }
    _type = this.runtimeType;
    
    IInstanceMirror imirror = ClassMirrorFactory.reflect(this);
    
    Map<Symbol, Symbol> monitoredFields = getMonitoredFields(imirror);
    
    // a getter associated with Monitored private filed with "_"+gettername will be handled.
    imirror.cmirror.fieldTypes.forEach((Symbol symbol, IFieldType ft) {
      Symbol monitoredField = monitoredFields[symbol];
      print('>>_init ${symbol} ${monitoredField}');
      if (monitoredField != null) {
        _fields[symbol] = new FieldState(this, imirror.getField(monitoredField));
      }
    });
  }
  
  Map<Symbol, Symbol> getMonitoredFields(IInstanceMirror imirror) {
    Map<Symbol, Symbol> monitoredFields = {};
    imirror.cmirror.fieldTypes.forEach((Symbol symbol, IFieldType ft){
      if (!ft.name.startsWith('_')) {
        return;
      }
      //print('getMonitoredFields ${symbol} ${ft.name}');
      Monitored mo = getAnnotation(ft.metadata, (Object obj)=>obj is Monitored);
      if (mo != null) {
          monitoredFields[new Symbol(ft.name.substring(1))] = symbol;
          print('!getMonitoredFields ${ft.name.substring(1)} ${symbol}');
      }
    });
    return monitoredFields;
  }

  Object get(Symbol symbol) {
    _init();
    FieldState fstate = _fields[symbol];
    if (fstate == null) {
      throw new Exception("getter, no field ${symbol} fror ${type}");
    }
    return fstate.get();
  }
  
  void set(Symbol symbol, Object value) {
    print('>>>1 set: symbol: ${symbol}, v: ${value}');
    _init();
    print('>>>2 set: symbol: ${symbol}, v: ${value}');
    FieldState fstate = _fields[symbol];
    if (fstate == null) {
      throw new Exception("setter, no field ${symbol} fror ${type}");
    }
    print('>>>3 set: symbol: ${symbol}, v: ${value}');
    fstate.set(value);
  }
  
  //
  //
  //
  void addGetListener(Symbol symbol, GetListener getListener) => _getFieldState(symbol).getListeners.add(getListener);
  void removeGetListener(Symbol symbol, GetListener getListener) { _getFieldState(symbol).getListeners.remove(getListener); }

  void addSetListener(Symbol symbol, SetListener setListener) => _getFieldState(symbol).setListeners.add(setListener);
  void removeSetListener(Symbol symbol, SetListener setListener) { _getFieldState(symbol).setListeners.remove(setListener); }
  
  FieldState _getFieldState(Symbol symbol) {
    _init();
    FieldState fstate = _fields[symbol];
    if (fstate == null) {
      throw new Exception("addGetListener, no field ${symbol} fror ${type}");
    }
    return fstate;
  }
}

class AccessListener {
  final bool isStatic;
  final GetListener getListener;
  final SetListener setListener;
  const AccessListener({this.getListener: null, this.setListener: null, this.isStatic: false});
}

class Monitored {
  final String getterName;
  const Monitored({this.getterName});
}

//
// test
//
class A extends Monitor {
  A(int i0, int j0) {
    i = i0;
    j = j0;
    addGetListener(const Symbol("j"), (A target, int old_value){
      print('~~3 type ${target} old_value ${old_value}');
    });
  }
  
  int get i => get(const Symbol("i"));
  void set i(int v) => set(const Symbol("i"), v);
  
  //@AccessListener(getListener: (A target, int old_value){ print('~~2 type ${target} old_value ${old_value}');})
  int get j => get(const Symbol("j"));
  void set j(int v) => set(const Symbol("j"), v);
  
}

class B extends Object with Monitor {
  B(int i0, int j0) {
    i = i0;
    j = j0;
    addGetListener(const Symbol("j"), (B target, int old_value){
      print('~~3 type ${target} old_value ${old_value}');
    });
  }
  
  int get i => get(const Symbol("i"));
  void set i(int v) => set(const Symbol("i"), v);
  
  //@AccessListener(getListener: (A target, int old_value){ print('~~2 type ${target} old_value ${old_value}');})
  int get j => get(const Symbol("j"));
  void set j(int v) => set(const Symbol("j"), v);
  
 
}

void test1() {
  StaticReceptorListener.addGetStaticListener(A, const Symbol("i"), (A target, int old_value){ print('~~1 type ${target} old_value ${old_value}'); });
  A a = new A(10, 13);
  
  a.addGetListener(const Symbol("i"), (A target, int old_value){ print('~~2 type ${target} old_value ${old_value}');});
  a.i = 20;
  print('>> a.i: ${a.i}');
  print('>> a.j: ${a.j}');
  
}

void test2() {
  StaticReceptorListener.addGetStaticListener(B, const Symbol("i"), (B target, int old_value){ print('*~~1 type ${target} old_value ${old_value}'); });
  B b = new B(10, 13);
  
  b.addGetListener(const Symbol("i"), (B target, int old_value){ print('*~~2 type ${target} old_value ${old_value}');});
  b.i = 20;
  print('>> b.i: ${b.i}');
  print('>> b.j: ${b.j}');
  
}

main() {

  // register reflection factory
  initClassMirrorFactory();
  
  test1();
  
  test2();
  
}



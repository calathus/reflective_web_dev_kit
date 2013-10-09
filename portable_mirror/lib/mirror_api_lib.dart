/*
 * author: N, calathus
 * date: 9/23/2013
 */
library mirror_api;

typedef IClassMirror CMirrorFun(Type type);
typedef Type GetTypeFun(Object obj);

class ClassMirrorFactory {
  //static GetTypeFun _getType;
  static CMirrorFun _cmf;
  
  static Type getType(Object e) => (e == null)?null:e.runtimeType;
  static IClassMirror reflectClass(Type type) => _cmf(type);
  
  static IInstanceMirror reflect(Object e) => reflectClassFromObject(e).reflect(e);
  static IClassMirror reflectClassFromObject(Object e) => (e == null)?null:reflectClass(e.runtimeType);

  static void register(CMirrorFun cmf) { 
    //_getType = getType;
    _cmf = cmf;
  }
}

//
abstract class IClassMirror {  
  IInstanceMirror newInstance();
  IInstanceMirror reflect(Object obj);
  Type get type;
  Map<Symbol, IFieldType> get fieldTypes;
  List<IClassMirror> get typeArguments;
}

abstract class IFieldType {
  Symbol get symbol;
  String get name; // convert symol to string
  Type get type;
  List<IInstanceMirror> get metadata;
  IClassMirror get cmirror; // of type
}

//
abstract class IInstanceMirror {
  IClassMirror get cmirror;
  Object get reflectee;
  
  IField getField(Symbol name);
}

abstract class IField {
  Symbol get symbol;
  String get name; // convert symol to string
  
  Object get value;
  void set value(Object obj);
  
  Type get type;
}


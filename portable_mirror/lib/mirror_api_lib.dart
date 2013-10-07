/*
 * author: N, calathus
 * date: 9/23/2013
 */
library mirror_api;

typedef IClassMirror CMirrorFun(Type type);
typedef Type GetTypeFun(Object obj);

class ClassMirrorFactory {
  static GetTypeFun _getType;
  static CMirrorFun _cmf;
  
  static Type getType(Object e) => _getType(e);
  static IClassMirror reflectClass(Type type) => _cmf(type);
  
  static IInstanceMirror reflect(Object e) => reflectClass(getType(e)).reflect(e);

  static void register(GetTypeFun getType, CMirrorFun cmf) { 
    _getType = getType;
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


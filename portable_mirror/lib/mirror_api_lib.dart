/*
 * author: N, calathus
 * date: 9/23/2013
 */
library mirror_api;

typedef IClassMirror CMirrorFun(Type type);
typedef IInstanceMirror IInstanceMirrorFactory(Object obj);

// there is a bug in dart mirrors lib.
// also the use of reflectClass should be avoided for geneic type.
// Anyway, such appropriate designe need more consideration, so this will be kept as it is.
// but later, need to be revisited.
//

class ClassMirrorFactory {
  static CMirrorFun _cmf;
  
  static Type getType(Object e) => (e == null)?null:e.runtimeType;
  static IClassMirror reflectClass(Type type) => _cmf(type); // this should not be used.. [TODO]

  static IInstanceMirror reflect(Object e) => reflectClassFromObject(e).reflect(e);
  static IClassMirror reflectClassFromObject(Object e) => (e == null)?null:reflectClass(e.runtimeType); // this should be changed.. IInstance
//  static IClassMirror reflectClassFromObject(Object e) => (e == null)?null:reflect(e).cmirror;

  static void register(CMirrorFun cmf) { 
    _cmf = cmf;
  }
  /*
  static IInstanceMirrorFactory _imirrorFactory;
  static IInstanceMirror reflect(Object e) => _imirrorFactory(e);
  static IClassMirror reflectClassFromObject(Object e) => reflect(e).cmirror; 
  static void register(IInstanceMirrorFactory imirrorFactory, CMirrorFun cmf) { 
    //_getType = getType;
    _cmf = cmf;
    _imirrorFactory = imirrorFactory;
  }
  */
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
  bool get priv;
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

Object getAnnotation(List metadata, bool cond(Object obj)) {
  for (Object obj in metadata) {
    if (obj is IInstanceMirror) {
      IInstanceMirror imirr = obj;
      if (cond(imirr.reflectee)) {
        return imirr.reflectee;
      }
    }
  }
  return null;
}


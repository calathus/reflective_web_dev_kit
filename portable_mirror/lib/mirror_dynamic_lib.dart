/*
 * author: N, calathus
 * date: 9/23/2013
 */
library dynamic_mirror;

import 'dart:mirrors';
import 'package:portable_mirror/mirror_api_lib.dart';

/*
 * This must be invoked before calling any of these simple mirror APIs.
 */
void initClassMirrorFactory() {
  ClassMirrorFactory.register(
      (Object e)=>reflect(e).type.reflectedType,
      (Type type)=>new DynamicClassMirror.reflectClass(type));
}

//
// IClassMirror implementations
//
class DynamicClassMirror implements IClassMirror {
  static Map<Type, DynamicClassMirror>  cmirrs = {};
  
  final Type _type;
  final ClassMirror _cmirror;
  MethodMirror _ctor;
  Map<Symbol, IFieldType> _fieldTypes;
  
  factory DynamicClassMirror.create(Type type) => new DynamicClassMirror(type, reflectClass(type));
  
  DynamicClassMirror(this._type, this._cmirror);
  
  factory DynamicClassMirror.reflectClass(Type type) {
    DynamicClassMirror cmirr = cmirrs[type];
    if (cmirr == null) {
      cmirr = new DynamicClassMirror.create(type);
      cmirrs[type] = cmirr;
      print('>>>> ${type}');
    }
    return cmirr;
  }
  
//  Type get type => _cmirror.reflectedType;
  Type get type {
    //print('DynamicClassMirror get type>>>> ${_cmirror.runtimeType}');
    //return _cmirror.reflectedType;
    return _type;
  }
  
  MethodMirror get ctor {
    if (_ctor == null) {
      _cmirror.constructors.forEach((k, v){
        if (v.parameters.length == 0 && (_ctor == null || getSymbolName(k) == "${type}.Default")) {
          _ctor = v;
        }
      });
    }
    if (_ctor == null) {
      throw new Exception("no default constructor defined for ${type}");
    }
    return _ctor;
  }
  
  IInstanceMirror newInstance() =>
      reflect(_cmirror.newInstance(ctor.constructorName, []).reflectee);

  IInstanceMirror reflect(Object obj) => new DynamicInstanceMirror(this, obj);

  Map<Symbol, IFieldType> get fieldTypes {
    if (_fieldTypes == null) {
      _fieldTypes = {};
      _cmirror.getters.forEach((Symbol symbol, MethodMirror md){
        if (_cmirror.setters.containsKey(new Symbol('${getSymbolName(symbol)}='))) {
          _fieldTypes[symbol] = new DynamicFieldType(symbol, md);
        } else {
          //print('>>>> ${_type} no setter ${symbol}');
        }
      });
    }
    return _fieldTypes;
  }
  
  List<IClassMirror> get typeArguments => _cmirror.typeArguments.fold([], (list, ClassMirror cmirr)=>list..add(new DynamicClassMirror(cmirr.reflectedType, cmirr)));
}

class DynamicFieldType implements IFieldType {
  Symbol _symbol;
  String _name;
  MethodMirror _md;
  
  DynamicFieldType(this._symbol, this._md) {
    _name = getSymbolName(_symbol);
  }
  
  Symbol get symbol => _symbol;
  String get name => _name;
  Type get type => (_md.returnType as ClassMirror).reflectedType;
  IClassMirror get cmirror {
    ClassMirror cmirror = _md.returnType as ClassMirror;
    return new DynamicClassMirror(cmirror.reflectedType, cmirror); // field ClassMirror has reflectedType!!
  }
}

//
// IInstanceMirror implementations
//
class DynamicInstanceMirror implements IInstanceMirror {
  Map<Symbol, DynamicField>  dfs = {};
  
  final IClassMirror _cmirror;
  InstanceMirror _imirror;
  
  DynamicInstanceMirror(this._cmirror, Object obj) {
    _imirror = reflect(obj);
  }
  
  IClassMirror get cmirror => _cmirror;
  
  Object get reflectee => _imirror.reflectee;
  IField getField(Symbol name) => new DynamicField.create(name, this);
}

class DynamicField implements IField {
  DynamicInstanceMirror _parent;
  Symbol _symbol;
  String _name;
  
  DynamicField(Symbol this._symbol, this._parent) {
    _name = getSymbolName(_symbol);
  }
  
  factory DynamicField.create(Symbol symbol, DynamicInstanceMirror _parent) {
    DynamicField df = _parent.dfs[symbol];
    if (df == null) {
      _parent.dfs[symbol] = df = new DynamicField(symbol, _parent);
    }
    return df;
  }
  
  Symbol get symbol => _symbol;
  String get name => _name;
  
  Object get value => _parent._imirror.getField(_symbol).reflectee;
  void set value(Object obj) { _parent._imirror.setField(_symbol, obj); }
  
  Type get type => _parent._cmirror.fieldTypes[_symbol].type;
 }

//
// utils
//
String getSymbolName(Symbol symbol) => symbol.toString().substring('Symbol("'.length, symbol.toString().length-2);

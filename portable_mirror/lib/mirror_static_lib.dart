/*
 * author: N, calathus
 * date: 9/23/2013
 */
library static_mirror;

import 'package:portable_mirror/mirror_api_lib.dart';

//
// IClassMirror implementations
//
typedef Object Getter(Object entity);
typedef void Setter(Object entity, Object value);

class FieldInfo implements IFieldType {
  final Symbol _symbol;
  String _name;
  final Type _type;
  final List<Object> _metadata_objs;
  List<IInstanceMirror> _metadata;
  IClassMirror _cmirror;
  
  final Getter getter;
  final Setter setter;
  
  FieldInfo(this._symbol, this._type, this.getter, this.setter, [List<Object> this._metadata_objs = const[]]) {
    _name = getSymbolName(_symbol);
    print(">> FieldInfo, _symbol: ${_symbol} _type: ${_type}");
    //_cmirror = ClassMirrorFactory.reflectClass(_type);
    //_metadata = metadata.fold([], (list, obj)=>list..add(new StaticInstanceMirror(ClassMirrorFactory.reflectClassFromObject(obj), obj)));
  }
  
  Symbol get symbol => _symbol;
  String get name => _name;
  Type get type => _type;
  bool get priv => _name.startsWith("_");
  
  List<IInstanceMirror> get metadata {
    if (_metadata == null) {
      _metadata = _metadata_objs.fold([], (list, obj)=>list..add(new StaticInstanceMirror(ClassMirrorFactory.reflectClassFromObject(obj), obj)));
    }
    return _metadata;
  }
  IClassMirror get cmirror {
    if (_cmirror == null) {
      _cmirror = ClassMirrorFactory.reflectClass(_type);
    }
    return _cmirror;
  }
}

typedef Object DefaultConstructor();

class StaticClassMirror implements IClassMirror {
  final Type _type;
  final DefaultConstructor ctor;
  final Map<Symbol, FieldInfo> fieldInfos;
  final List<IClassMirror> _typeArguments;
  final List<IInstanceMirror> _metadata;
  
  StaticClassMirror(this._type, this.ctor, this.fieldInfos, [this._typeArguments = const[], this._metadata = const[]]);
  
  Type get type => _type;
  
  IInstanceMirror newInstance() => reflect(ctor());

  IInstanceMirror reflect(Object obj) => new StaticInstanceMirror(this, obj);

  Map<Symbol, IFieldType> get fieldTypes => fieldInfos;
  
  List<IClassMirror> get typeArguments =>_typeArguments;
  
  List<IInstanceMirror> get metadata => _metadata;

}

//
// IInstanceMirror implementations
//
class StaticInstanceMirror implements IInstanceMirror {
  Map<Symbol, StaticField>  dfs = {};
  
  final IClassMirror _cmirror;
  
  final Object _obj;
  
  StaticInstanceMirror(this._cmirror, Object this._obj);
  
  IClassMirror get cmirror => _cmirror;
  
  Object get reflectee => _obj;
  IField getField(Symbol name) => new StaticField.create(name, this);
}

class StaticField implements IField {
  StaticInstanceMirror _parent;
  Symbol _symbol;
  String _name;
  
  StaticField(Symbol this._symbol, this._parent) {
    _name = getSymbolName(_symbol);
  }
  
  factory StaticField.create(Symbol symbol, StaticInstanceMirror _parent) {
    StaticField df = _parent.dfs[symbol];
    if (df == null) {
      _parent.dfs[symbol] = df = new StaticField(symbol, _parent);
    }
    return df;
  }
  
  Symbol get symbol => _symbol;
  String get name => _name;
  
  Object get value => _cmirror.fieldInfos[symbol].getter(_parent.reflectee);
  
  void set value(Object obj) { _cmirror.fieldInfos[symbol].setter(_parent.reflectee, obj); }
  
  Type get type => _cmirror.fieldInfos[symbol].type;
  IClassMirror get cmirror => _cmirror.fieldInfos[symbol].cmirror;
  
  StaticClassMirror get _cmirror => (_parent._cmirror as StaticClassMirror);
 }

typedef dynamic DefaultConstroctorFun();

//
// utils
//
String getSymbolName(Symbol symbol) => symbol.toString().substring('Symbol("'.length, symbol.toString().length-2);

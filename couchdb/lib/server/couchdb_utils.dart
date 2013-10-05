library couchdb_utils;

import "package:portable_mirror/mirror_api_lib.dart";

abstract class ICouchDoc {
  String get id;
  void set id(String id);
  
  String get rev;
  void set rev(String rev);
}

class CouchDoc<T> implements ICouchDoc {
  IField _fld_id;
  IField _fld_rev;
  CouchDoc(Type modelType, T t) {
    IClassMirror cmirror = ClassMirrorFactory.reflectClass(modelType);
    IInstanceMirror imirr = cmirror.reflect(t); //duck typing..
    this._fld_id = imirr.getField(const Symbol('id'));
    this._fld_rev = imirr.getField(const Symbol('rev'));
  }
  
  String get id => _fld_id.value;
  void set id(String id) { _fld_id.value = id; }
  
  String get rev => _fld_rev.value;
  void set rev(String rev) { _fld_rev.value = rev; }
}

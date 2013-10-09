library dart_generics_test;

import 'dart:mirrors';

import '../lib/src/test_models.dart'; 

test_generics() {
  {
    /*
    ClassMirror immir0 = reflectClass(List<B>); // <== this cannot be compiled!
    Type t0 = immir0.reflectedType;
    print(">> ${t0}");
     */
    
    // following code is to get a Type of List<B>, a work around to avoid above problem.  
    InstanceMirror immir = reflect(new List<B>());
    Type t = immir.type.reflectedType;
    print(">>1.1 ${t}");
    
    /*
    ClassMirror cmirr = reflectClass(t);
    Type t2 = cmirr.reflectedType; // here t1 == t0, but it throws exception
    print(">>1.2 ${t2}");
    */
  /*
   * Unhandled exception:
Unsupported operation: Declarations of generics have no reflected type
#0      _LocalClassMirrorImpl.reflectedType (dart:mirrors-patch/mirrors_impl.dart:304:7)
#1      test_generics (file:///opt/dart-workspace/reflective_web_dev_kit/sample_app/bin/sample_json_mapper_test.dart:76:21)
#2      main (file:///opt/dart-workspace/reflective_web_dev_kit/sample_app/bin/sample_json_mapper_test.dart:81:16)
   * 
   */
  }

  {
    Type t1 = new B("nn").runtimeType;
    print(">>2.1 ${t1}");
  
    ClassMirror cmirr1 = reflectClass(t1);
    Type t2 = cmirr1.reflectedType; // here t1 == t0, but it throws exception
    print(">>2.1 ${t2}");
  }

  {
    Type t1 = new List<B>().runtimeType; // return List<B>
    print(">>3.1 t1: ${t1}");
  
    ClassMirror cmirr1 = reflectClass(t1);
    Type t2 = cmirr1.runtimeType; // return _LocalClassMirrorImpl
    print(">>3.2 t2: ${t2}"); 
    print(">>3.3 cmirr1.hasReflectedType: ${cmirr1.hasReflectedType}"); 
    
    //Type t4 = cmirr1.reflectedType; // here t1 == t0, but it throws exception
    //print(">>3.3 t4: ${t4}");
  }

  {
    ClassMirror cmirr = reflectClass(A);
    cmirr.getters.forEach((k, MethodMirror md){
      Type tm = (md.returnType as ClassMirror).reflectedType;
      print(">>4.1 k: ${k}, tm: ${tm}");
      
    });
  }
}

class ChouchDBFetchData<T> {
  
  List<ChouchDBFetchRowData<T>> _rows;
  T _t;
  
  List<ChouchDBFetchRowData<T>> get rows => _rows;
  void set rows( List<ChouchDBFetchRowData<T>> rows) { _rows = rows; }
  
  T get t => _t;
  void set t( T t) { _t = t; }
 
}

class ChouchDBFetchRowData<T> {
  T _doc;
  T get doc => _doc;
  void set doc(T doc) { _doc = doc; }
}


test2() {
  Type type = new ChouchDBFetchData<A>().runtimeType;
  print(">> type: ${type}");
/*
  {
  ClassMirror cmirr = reflectClass(type);
  cmirr.getters.forEach((k, MethodMirror md){
    Type tm = null;
    if (md.returnType is ClassMirror) {
      tm = (md.returnType as ClassMirror).reflectedType;
      print(">>@ k: ${k}, tm: ${tm}");
    } else if (md.returnType is TypeVariableMirror) {
      TypeVariableMirror tvmirr = md.returnType;
      print(">>@ tvmirr: ${tvmirr.runtimeType}");
    }
    
  });
  }

  {
    ClassMirror cmirr = reflect(new ChouchDBFetchData<A>()).type;
    cmirr.getters.forEach((k, MethodMirror md){
      Type tm = null;
      if (md.returnType is ClassMirror) {
        tm = (md.returnType as ClassMirror).reflectedType;
        print(">>@@ k: ${k}, tm: ${tm}");
      } else if (md.returnType is TypeVariableMirror) {
        TypeVariableMirror tvmirr = md.returnType;
        print(">>@@ tvmirr: ${tvmirr.runtimeType}");
      }
    });
  }
  */
  {
    ClassMirror cmirr = reflect(new List<A>()).type;
    print(">>0@@ cmirr.reflectedType: ${cmirr.reflectedType}");
    cmirr.getters.forEach((k, MethodMirror md){
      Type tm = null;
      if (md.returnType is ClassMirror) {
        tm = (md.returnType as ClassMirror).reflectedType;
        print(">>1@@ k: ${k}, tm: ${tm}");
      } else if (md.returnType is TypeVariableMirror) {
        TypeVariableMirror tvmirr = md.returnType;
        print(">>2@@ tvmirr: ${tvmirr.runtimeType}");
      }
    });
  }

}

main() {
  //test_generics();
  test2();
}

library dart_is_test;

import 'package:portable_mirror/mirror_api_lib.dart';
import "package:portable_mirror/mirror_dynamic_lib.dart";

class Monitored {
  final String getterName;
  const Monitored({this.getterName});
}

class A {
  @Monitored()
  int _a;
  
}

Map<Symbol, Symbol> getMonitoredFields(IInstanceMirror imirror) {
  Map<Symbol, Symbol> monitoredFields = {};
  imirror.cmirror.fieldTypes.forEach((Symbol symbol, IFieldType ft){
    if (!ft.name.startsWith('_')) {
      return;
    }
    String pubName = ft.name.substring(1);
    print('getMonitoredFields ${pubName} ${ft.name} ${ft.metadata}');
    //Monitored mo = getAnnotation(ft.metadata, (Object obj)=>obj is Monitored);
    Monitored mo = getAnnotation(ft.metadata, (Object obj){
      print(">>>>> ${obj}, ${obj.runtimeType}, ${obj is Monitored}");
      return obj is Monitored;
    });
    if (mo != null) {
      monitoredFields[new Symbol(pubName)] = symbol;
      print('!getMonitoredFields ${pubName} ${symbol}');
    } else {
      print('??getMonitoredFields ${pubName} ${symbol}');
    }
  });
  return monitoredFields;
}

Object getAnnotation(List metadata, bool cond(Object obj)) {
  for (Object obj in metadata) {
    if (obj is IInstanceMirror) {
      IInstanceMirror imirr = obj;
      print(">>0 getAnnotation annot type: ${imirr.reflectee.runtimeType}");
      if (cond(imirr.reflectee)) {
        print(">>1 getAnnotation annot obj: ${imirr.reflectee}");
        return imirr.reflectee;
      } else {
        print(">>2 getAnnotation annot obj: ${imirr.reflectee}");
      }
    }
  }
  return null;
}

test_is() {
  A a = new A();
  IInstanceMirror imirror = ClassMirrorFactory.reflect(a);
  getMonitoredFields(imirror);
}

main() {

  // register reflection factory
  initClassMirrorFactory();
  
  test_is();
  
}

/*
 * author: N, calathus
 * date: 9/23/2013
 */
library static_mirror_generator;

import 'dart:io';
import 'package:portable_mirror/mirror_api_lib.dart';
import 'package:portable_mirror/mirror_dynamic_lib.dart';

class StaticMirrorGenerator {
  // this must be changed again..
  static String folder = "/opt/dart-workspace/generic-gui-v3/web/shared/";
  
  static void generate(String fileName, List<Type> types) {
    Set<Type> stypes = types.toSet();
    
    File fileHandle = new File("${folder}${fileName}.dart");
    IOSink ssink = fileHandle.openWrite();
    _generate(fileName, stypes, ssink);
    ssink.close();
  }

  static void _generate(String fileName, Set<Type> types, StringSink sink) {
    
    sink.writeln("library ${fileName}_mirror;");
    
    sink.writeln("""
import 'mirror_libs/mirror_api_lib.dart';
import 'mirror_libs/mirror_static_lib.dart';
import 'models.dart';
    """);
    
    //
    {
    sink.writeln("""
/*
 * This must be invoked before calling any of these simple mirror APIs.
 */
void initClassMirrorFactory() {
  Type reflectType(Object obj) {""");
    for (Type type in types) {
    sink.writeln("""
    if (obj is ${type}) {
      return ${type};
    } else """);
    }
    sink.writeln("""
    {
      // throw exception??
      return null;
    }
  }
  IClassMirror reflectClass(Type type) {""");
    for (Type type in types) {
    sink.writeln("""
     if (type == ${type}) {
      return new StaticClassMirror(${type}, ()=>new ${type}.Default(), ${type}FieldInfo);
    } else""");
    }
    sink.writeln("""
    {
      return null;
    }
  }
  ClassMirrorFactory.register(reflectType, reflectClass);
}""");
    }

    // variable decls
    {
      Set<Type> ftypes = new Set();
      for (Type type in types) {
        DynamicClassMirror cmirror = new DynamicClassMirror.reflectClass(type);
        cmirror.fieldTypes.forEach((Symbol symbol, IFieldType ft) {
          ftypes.add(ft.type);
        });
      }
      sink.writeln("/*");
      sink.writeln(" * [variable declarations]");
      sink.writeln(" *   this is a temporary workaround to avoid DART bug. should be able to use Type value directly. then this part is not required.");
      sink.writeln(" */");
      for (Type ftype in ftypes) {
        sink.writeln("Type _${ftype} = ${ftype};");
      }
      sink.writeln("");
    }
    
    // 
    {
      sink.writeln("/*");
      sink.writeln(" * [FieldInfos]");
      sink.writeln(" */");
      for (Type type in types) {
        sink.writeln("""
Map<Symbol, FieldInfo> ${type}FieldInfo =
  [""");
        DynamicClassMirror cmirror = new DynamicClassMirror.reflectClass(type);
        int idx = 0;
        int lastIdx = cmirror.fieldTypes.length-1;
        cmirror.fieldTypes.forEach((Symbol symbol, IFieldType ft) {
          String comma = (idx == lastIdx)?"":",";
          idx++;
          sink.writeln(" new FieldInfo(const Symbol('${ft.name}'), _${ft.type}, (${type} e)=>e.${ft.name}, (${type} e, ${ft.type} value) { e.${ft.name} = value; })${comma}");
        });
        
        sink.writeln("""
  ].fold({}, (Map map, FieldInfo fh) => map..[fh.symbol] = fh);
""");
      }
    }
  }
}

/*
import 'mirror_libs/mirror_api_lib.dart';
import 'mirror_libs/mirror_static_lib.dart';
import 'models.dart';

/*
 * This must be invoked before calling any of these simple mirror APIs.
 */

void initClassMirrorFactory() {
  ClassMirrorFactory.register((Type type)=>(type == Expense)?
      new StaticClassMirror(()=>new Expense.Default(), expenseFieldInfo)
  :null);
}

Type _String = String;
Type _ExpenseType = ExpenseType;
Type _DateTime = DateTime;
Type _num = num;
Type _bool = bool;

Map<Symbol, FieldInfo> expenseFieldInfo =
[
 new FieldInfo(const Symbol('id'), _String, (Expense e)=>e.id, (Expense e, String value) { e.id = value; }),
 new FieldInfo(const Symbol('rev'), _String, (Expense e)=>e.rev, (Expense e, String value) { e.rev = value; }),
 new FieldInfo(const Symbol('expenseType'), _ExpenseType, (Expense e)=>e.expenseType, (Expense e, ExpenseType value) { e.expenseType = value; }),
 new FieldInfo(const Symbol('date'), _DateTime, (Expense e)=>e.date, (Expense e, DateTime value) { e.date = value; }),
 new FieldInfo(const Symbol('amount'), _num, (Expense e)=>e.amount, (Expense e, num value) { e.amount = value; }),
 new FieldInfo(const Symbol('detail'), _String, (Expense e)=>e.detail, (Expense e, String value) { e.detail = value; }),
 new FieldInfo(const Symbol('isClaimed'), _bool, (Expense e)=>e.isClaimed, (Expense e, bool value) { e.isClaimed = value; })
 ].fold({}, (Map map, FieldInfo fh) => map..[fh.symbol] = fh);
*/

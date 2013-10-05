/*
 * author: N, calathus
 * date: 9/23/2013
 */
library sample_mirror;

import 'package:portable_mirror/mirror_api_lib.dart';
import 'package:portable_mirror/mirror_static_lib.dart';
import 'models.dart';

/*
 * This must be invoked before calling any of these simple mirror APIs.
 */
typedef dynamic DefaultConstroctorFun();

Map<Type, DefaultConstroctorFun> staticClassMirrorFactory = {
  Expense: ()=>new StaticClassMirror(Expense, ()=>new Expense.Default(), expenseFieldInfo),
  ExpenseType: ()=>new StaticClassMirror(ExpenseType, null, {}), // ??
  DateTime: ()=>new StaticClassMirror(DateTime, null, {})// ??
};

void initClassMirrorFactory() {
  Type reflectType(Object obj) {
    // this is annoying.
    // Dart has plan to support obj.type.
    // that will eliminate this codes.
    // => return obj.type;
    if (obj is Expense) {
      return Expense;
    } else if (obj is ExpenseType) {
      return ExpenseType;
    } else if (obj is DateTime) {
      return DateTime;
    } else {
      // throw exception??
      return null;
    }
  }
  IClassMirror reflectClass(Type type) => [staticClassMirrorFactory[type]].fold(null, (_, ctor)=>((ctor == null)?null:ctor()));

  ClassMirrorFactory.register(reflectType, reflectClass);
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

/*
//
// This works for DartVM, but it fails dart2js.
//
Map<Symbol, FieldInfo> expenseFieldInfo =
    [
     new FieldInfo(const Symbol('id'), String, (Expense e)=>e.id, (Expense e, String value) { e.id = value; }),
     new FieldInfo(const Symbol('rev'), String, (Expense e)=>e.rev, (Expense e, String value) { e.rev = value; }),
     new FieldInfo(const Symbol('expenseType'), ExpenseType, (Expense e)=>e.expenseType, (Expense e, ExpenseType value) { e.expenseType = value; }),
     new FieldInfo(const Symbol('date'), DateTime, (Expense e)=>e.date, (Expense e, DateTime value) { e.date = value; }),
     new FieldInfo(const Symbol('amount'), num, (Expense e)=>e.amount, (Expense e, num value) { e.amount = value; }),
     new FieldInfo(const Symbol('detail'), String, (Expense e)=>e.detail, (Expense e, String value) { e.detail = value; }),
     new FieldInfo(const Symbol('isClaimed'), bool, (Expense e)=>e.isClaimed, (Expense e, bool value) { e.isClaimed = value; })
     ].fold({}, (Map map, FieldInfo fh) => map..[fh.symbol] = fh);
*/

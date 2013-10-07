/*
 * author: N, calathus
 * date: 9/23/2013
 */
library test_mirror;

import 'package:portable_mirror/mirror_api_lib.dart';
import 'package:portable_mirror/mirror_static_lib.dart';
import 'test_models.dart';

/*
 * This must be invoked before calling any of these simple mirror APIs.
 */
typedef dynamic DefaultConstroctorFun();

IClassMirror AClassMirror = new StaticClassMirror(A, ()=>new A.create(), AFieldInfo);
IClassMirror BClassMirror = new StaticClassMirror(B, ()=>new B.create(), BFieldInfo);
IClassMirror ListBClassMirror = new StaticClassMirror(_ListB, ()=>new List<B>(), {}, [BClassMirror]);

Map<Type, DefaultConstroctorFun> staticClassMirrorFactory = {A: ()=>AClassMirror, B: ()=>BClassMirror, _ListB: ()=>ListBClassMirror};

void initClassMirrorFactory() {
  Type reflectType(Object obj) => obj.runtimeType;
  
  IClassMirror reflectClass(Type type) => ((ctor)=>(ctor == null)?null:ctor())(staticClassMirrorFactory[type]);

  ClassMirrorFactory.register(reflectType, reflectClass);
}

Type _ListB = new List<B>().runtimeType;
Type _String = String;
Type _int = int;
Type _bool = bool;

Map<Symbol, FieldInfo> AFieldInfo =
[
 new FieldInfo(const Symbol('i'), _int, (A e)=>e.i, (A e, int value) { e.i = value; }),
 new FieldInfo(const Symbol('bs'), _ListB, (A e)=>e.bs, (A e, List<B> value) { e.bs = value; }),
 ].fold({}, (Map map, FieldInfo fh) => map..[fh.symbol] = fh);

Map<Symbol, FieldInfo> BFieldInfo =
[
 new FieldInfo(const Symbol('s'), _String, (B e)=>e.s, (B e, String value) { e.s = value; }),
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

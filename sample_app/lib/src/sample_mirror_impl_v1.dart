library sample_mirror_impl_v1_mirror;

import 'package:portable_mirror/mirror_api_lib.dart';
import 'package:portable_mirror/mirror_static_lib.dart';
import 'models.dart';
    
/*
 * This must be invoked before calling any of these simple mirror APIs.
 */
void initClassMirrorFactory() {  
  IClassMirror reflectClass(Type type) {
     if (type == Expense) {
      return new StaticClassMirror(Expense, ()=>new Expense.Default(), ExpenseFieldInfo);
    } else
    {
      return null;
    }
  }
  ClassMirrorFactory.register(reflectClass);
}
/*
 * [variable declarations]
 *   this is a temporary workaround to avoid DART bug. should be able to use Type value directly. then this part is not required.
 */
Type _DateTime = DateTime;
Type _bool = bool;
Type _ExpenseType = ExpenseType;
Type _num = num;
Type _String = String;

/*
 * [FieldInfos]
 */
Map<Symbol, FieldInfo> ExpenseFieldInfo =
  [
 new FieldInfo(const Symbol('id'), _String, (Expense e)=>e.id, (Expense e, String value) { e.id = value; }),
 new FieldInfo(const Symbol('rev'), _String, (Expense e)=>e.rev, (Expense e, String value) { e.rev = value; }),
 new FieldInfo(const Symbol('expenseType'), _ExpenseType, (Expense e)=>e.expenseType, (Expense e, ExpenseType value) { e.expenseType = value; }),
 new FieldInfo(const Symbol('date'), _DateTime, (Expense e)=>e.date, (Expense e, DateTime value) { e.date = value; }),
 new FieldInfo(const Symbol('amount'), _num, (Expense e)=>e.amount, (Expense e, num value) { e.amount = value; }),
 new FieldInfo(const Symbol('detail'), _String, (Expense e)=>e.detail, (Expense e, String value) { e.detail = value; }),
 new FieldInfo(const Symbol('isClaimed'), _bool, (Expense e)=>e.isClaimed, (Expense e, bool value) { e.isClaimed = value; })
  ].fold({}, (Map map, FieldInfo fh) => map..[fh.symbol] = fh);


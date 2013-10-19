/*
 * author: N, calathus
 * date: 9/23/2013
 */
library sample_mirror;

import 'package:portable_mirror/mirror_api_lib.dart';
import 'package:portable_mirror/mirror_static_lib.dart';
import 'package:gui_component/gui_annotation.dart';
import 'package:gui_component/gui_component_lib.dart';
import '../../web/sample_static_generic_gui.dart';
import 'models.dart';

/*
 * This must be invoked before calling any of these simple mirror APIs.
 */

Type _String = String;
Type _Expense = Expense;
Type _ExpenseType = ExpenseType;
Type _CRUDView = CRUDView;

Type _DateTime = DateTime;
Type _num = num;
Type _bool = bool;
Type _ButtonComp = ButtonComp;

Type type_table_expense = Component.reflectedType(()=>new Table<Expense>());
Type type_form_expense = Component.reflectedType(()=>new Form<Expense>());

Map<Type, DefaultConstroctorFun> staticClassMirrorFactory = {}
..[_Expense] = (()=>new StaticClassMirror(_Expense, ()=>new Expense.Default(), expenseFieldInfo))
..[_ExpenseType] = (()=>new StaticClassMirror(_ExpenseType, null, {}))
..[_CRUDView] = (()=>new StaticClassMirror(_CRUDView, ()=>new CRUDView(), crudViewFieldInfo))
..[type_table_expense] = (()=>new StaticClassMirror(type_table_expense, ()=>new Table<ExpenseType>(), {}))
..[type_form_expense] = (()=>new StaticClassMirror(type_form_expense, ()=>new Form<ExpenseType>(), {}))
;

Map<Symbol, FieldInfo> expenseFieldInfo =
[
 new FieldInfo(const Symbol('id'), _String, (Expense e)=>e.id, (Expense e, String value) { e.id = value; }, [new GUI_Table(invisible: true), new GUI_Form(disabled: true)]),
 new FieldInfo(const Symbol('rev'), _String, (Expense e)=>e.rev, (Expense e, String value) { e.rev = value; }, [new GUI_Table(invisible: true), new GUI_Form(disabled: true)]),
 new FieldInfo(const Symbol('expenseType'), _ExpenseType, (Expense e)=>e.expenseType, (Expense e, ExpenseType value) { e.expenseType = value; }),
 new FieldInfo(const Symbol('date'), _DateTime, (Expense e)=>e.date, (Expense e, DateTime value) { e.date = value; }),
 new FieldInfo(const Symbol('amount'), _num, (Expense e)=>e.amount, (Expense e, num value) { e.amount = value; }),
 new FieldInfo(const Symbol('detail'), _String, (Expense e)=>e.detail, (Expense e, String value) { e.detail = value; }),
 new FieldInfo(const Symbol('isClaimed'), _bool, (Expense e)=>e.isClaimed, (Expense e, bool value) { e.isClaimed = value; })
 ].fold({}, (Map map, FieldInfo fh) => map..[fh.symbol] = fh);

Map<Symbol, FieldInfo> crudViewFieldInfo =
[
 new FieldInfo(const Symbol('table'), type_table_expense, (CRUDView e)=>e.table, (CRUDView e, Object value) {}, [const UI_Table()]),
 new FieldInfo(const Symbol('form'), type_form_expense, (CRUDView e)=>e.form, (CRUDView e, Object value) {}, [const UI_Form()]),
 new FieldInfo(const Symbol('loadButtom'), _ButtonComp, (CRUDView e)=>e.loadButtom, (CRUDView e, Object value) {}, [const UI_Button(label: "Load")]),
 new FieldInfo(const Symbol('newButtom'), _ButtonComp, (CRUDView e)=>e.newButtom, (CRUDView e, Object value) {}, [const UI_Button(label: "New")]),
 new FieldInfo(const Symbol('saveButtom'), _ButtonComp, (CRUDView e)=>e.saveButtom, (CRUDView e, Object value) {}, [const UI_Button(label: "Save")]),
 new FieldInfo(const Symbol('deleteButtom'), _ButtonComp, (CRUDView e)=>e.deleteButtom, (CRUDView e, Object value) {}, [const UI_Button(label: "Delete")])
].fold({}, (Map map, FieldInfo fh) => map..[fh.symbol] = fh);


void initClassMirrorFactory() {
  ClassMirrorFactory.register(getCMirrorFun(staticClassMirrorFactory));
}

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

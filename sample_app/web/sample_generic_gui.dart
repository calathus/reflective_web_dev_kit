/*
 * author: N, calathus
 * date: 9/23/2013
 */
library sample_generic_gui;

import 'dart:html';
import "package:gui_component/gui_component_lib.dart";
import "package:couchdb/client/couchdb_client.dart";

import "../lib/src/models.dart";
import "../lib/src/sample_mirror_impl.dart";
import "../lib/src/sample_json_mapper.dart";

class CRUDView extends Component {
  static const String APP = "g_app_ctlr";
  final DivElement _uiRoot;
  DivElement _content;
  DivElement _actions;
  
  Table<Expense> table;
  Form<Expense> form;
  ButtonComp loadButtom;
  ButtonComp newButtom;
  ButtonComp saveButtom;
  ButtonComp deleteButtom;
  
  // this should be injected by AOP approach from out side..
  ICouchDbClientDAO<Expense> dao = new CouchDbClientDAO<Expense>(Expense, sampleJsonMapper);
  
  CRUDView(Component parent, this._uiRoot): super(parent, const[APP]) {
    table = new Table<Expense>.fromModelType(this, Expense, formatFunctionMap: {ExpenseType: ExpenseTypeComp.format});
    form = new Form<Expense>(this, Expense, 
        specialInputCompMap: {ExpenseType: ExpenseTypeComp.inputCompFactory},
        adhocCompMap: {'detail': 'textarea'} 
    );

    loadButtom = new ButtonComp(this, "Load", (_) {
      dao.fetchAll().then((List<Expense> es){
        table.load(es);
        //print('loaded data from db; ${es}');
      });
    });
    
    newButtom = new ButtonComp(this, "New", (_) {
      Expense e = form.create();
      _changeButtonState(true, false, true);
      //print('new in db');
    });
    
    saveButtom = new ButtonComp(this, "Save", (_) {
      if (form.e != null) {
        Expense e = form.save();
        if (e == null) {
          //print('form is empty, click New, or select arow before Save.');
          return;
        }
        // this part is tricky..
        // since e is fill from InputText, when it is empty text, it will assign "" instead of null..
        if (e.id == "") e.id = null;
        if (e.rev == "") e.rev = null;
        ((e.id == null)?dao.insert(e):dao.update(e)).then((Expense e0){
          e.id = e0.id;
          e.rev = e0.rev;
          table.addOrUpdate(e);
          _changeButtonState(false, true, true);
          //print('updated in db e0: ${sampleJsonMapper.toJson(e0)}, e: ${sampleJsonMapper.toJson(e)}');
        });
      }
    });
    
    deleteButtom = new ButtonComp(this, "Delete", (_) {
      Expense e = form.e;
      if (e != null) {
        dao.delete(e).then((ok){
          if (ok) {
            form.delete();
            table.delete(e);
            _changeButtonState(false, true, true);
            //print('deleted in db');
          }
        });
      }
    });
    
    _changeButtonState(false, true, true);
    
    table.row_listeners.add((ev, row){
      Expense e = row.e;
      form.load(e);
      _changeButtonState(false, false, false);
    });
    
    _uiRoot.nodes.add(element); // this 'element' tiggers DOM node creation!
  }
  
  void _changeButtonState(bool new_disable, bool save_disable, bool delete_disable) {
    (newButtom.element as ButtonElement).disabled = new_disable;
    (saveButtom.element as ButtonElement).disabled = save_disable;
    (deleteButtom.element as ButtonElement).disabled = delete_disable;    
  }
  
  Element createElement() => addSubComponents0(newElem("div"));
  
  Element update() => addSubComponents0(initElem());
      
  Element addSubComponents0(Element elm) => addListeners(
      elm
      ..classes.add("section")
      ..nodes.add(new Element.html("<header class='section'>${table.modelType} Table</header>"))
      ..nodes.add(_content = new Element.tag("div")
        ..nodes.add(table.element))
      ..nodes.add(_actions = new Element.tag("div")
        ..id = "actions"
        ..classes.add("section")
        ..nodes.add(loadButtom.element)
        ..nodes.add(newButtom.element)
        ..nodes.add(saveButtom.element)
        ..nodes.add(deleteButtom.element))
      ..nodes.add(form.element)
      ..nodes.add(new Element.html("<footer class='section' id='footer'></footer>")));
}

class ExpenseTypeComp extends SelectComp<ExpenseType> {
  static const String EXPENSE_TYPE_INPUT = "g_expense_type_input";
  
  static final Map<String, ExpenseType> _expenseTypes = {
    "TRV": const ExpenseType("Travel","TRV"),
    "BK": const ExpenseType("Books","BK"),
    "HT": const ExpenseType("Hotel","HT")                          
  };
  
  ExpenseTypeComp(Component parent, String label, {List<String> classes: const [SelectComp.SELECT_INPUT, EXPENSE_TYPE_INPUT]})
    : super(parent, label, ExpenseType, classes: classes);
  
  static ExpenseTypeComp inputCompFactory(Component c, String name, Type t)=>new ExpenseTypeComp(c, name);
  static String format(ExpenseType et) => (et == null)?'':et.name;
  
  Map<String, ExpenseType> get entityTypes => _expenseTypes;
  
  String getCode(ExpenseType et) => et.code;
  String getName(ExpenseType et) => et.name;
}

main() {
  // register reflection factory
  initClassMirrorFactory();
  
  Element uiContainer = document.query("#sample_generic_gui");
  CRUDView app = new CRUDView(null, uiContainer);
}

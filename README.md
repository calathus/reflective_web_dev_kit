## Overview ##

The goal of this project is to create small end to end sample application using component based web application.
In which generic/mirror based approach are employed systematically.

[portable_mirror] 
right now, darts:mirrors library cannot be used javascript mode. So if we directly use this library, most of code cannot be run on browser.
This lib provides a portable mirror API to support (small subset of) mirror features in which dart:mirrors is not used. 
There are two implementations for this API class. one depends on static classes, and the other depends on dart:mirror. 
No code changes are required to run application on javascripts mode or Dartium mode(using Dart VM). 

[json_mapper] 
json mapping based on mirror library. this automatically map json to corresponding entity instance

[coucdb] 
dao api for couchdb based on mirror/json_mapper. this provides server side json_proxy, and client side couchdb dao library

[gui_component] 
a framework to create web application using component based design, also table/form are implemented as generic class using mirror.

[sample_app]
This is a sample web application using these libraries.
This web application supports CRUD operation using Table and Form.


### To Do List ##
1) the json_mapper is not complete, need to support list/map attribute
2) also subclass identification should be done.

3) should use annotation to allow more control over the GUI presentation for gui_components.
4) use AOP style injection for DB access/logging.
...

There are a lot of thing to refine this app.
The main goal was to have a simple sample project to evaluate the feasibility of generic/mirror based approach.
so this is not bad shape for this purpose.
eventually I will fix some of the remaining issues.

### sample code ##
Here is the top level application code.
I think it is small and provide how to create new component from anotehr component.
This app class(CRUDView) itself can be used as com,ponent.


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
    // this 'element' tiggers DOM node creation!
    _uiRoot.nodes.add(element); 
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

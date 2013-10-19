/*
 * author: N, calathus
 * date: 9/23/2013
 */
part of sample_generic_gui;

class CRUDView extends Component {
  static const String CRUD = "g_cud_view";
  DivElement _content;
  DivElement _actions;

  @UI_Table()
  final Table<Expense> table = new Table<Expense>();
  
  @UI_Form()
  final Form<Expense> form = new Form<Expense>();
 
  @UI_Button(label: "Load")
  final ButtonComp loadButtom = new ButtonComp();
  
  @UI_Button(label: "New")
  final ButtonComp newButtom = new ButtonComp();
  
  @UI_Button(label: "Save")
  final ButtonComp saveButtom = new ButtonComp();
  
  @UI_Button(label: "Delete")
  final ButtonComp deleteButtom = new ButtonComp();
  
  Element _updateElement(Element elm) => 
      elm
      ..classes.add("section")
      ..nodes.add(new Element.html("<header class='section'>${table.modelType} Table</header>"))
      ..nodes.add(_content = new Element.tag("div")
        ..classes.add("g_crud_view_table")
        ..nodes.add(table.element))
      ..nodes.add(_actions = new Element.tag("div")
        ..id = "actions"
        ..classes.add("section")
        ..nodes.add(loadButtom.element)
        ..nodes.add(newButtom.element)
        ..nodes.add(saveButtom.element)
        ..nodes.add(deleteButtom.element))
      ..nodes.add(form.element)
      ..nodes.add(new Element.html("<footer class='section' id='footer'></footer>"));
  
  
  // this should be injected by AOP approach from out side..
  ICouchDbClientDAO<Expense> dao = new CouchDbClientDAO<Expense>(Expense, sampleJsonMapper);
  
  CRUDView() {
    this.classes.add(CRUD);
    Type _Expense = Expense;
    table
      ..modelType = _Expense
      ..formatFunctionMap[ExpenseType] = ExpenseTypeComp.format;
    
    form
      ..modelType = _Expense
      ..inputFactoryCache.specialInputCompMap[ExpenseType] = ExpenseTypeComp.inputCompFactory
      ..inputFactoryCache.adhocCompMap['detail'] = 'textarea'; // should be moved to annottaion!
    
    loadButtom.onClick((_) {
      dao.fetchAll().then((List<Expense> es){
        table.load(es);
        //print('loaded data from db; ${es}');
      });
    });
    
    newButtom.onClick((_) {
      Expense e = form.create();
      _changeButtonState(true, false, true);
      //print('new in db');
    });
    
    saveButtom.onClick((_) {
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
    
    deleteButtom.onClick((_) {
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
  }
  
  void _changeButtonState(bool new_disable, bool save_disable, bool delete_disable) {
    newButtom.node.disabled = new_disable;
    saveButtom.node.disabled = save_disable;
    deleteButtom.node.disabled = delete_disable; 
  }
  
  Element createElement() => addSubComponents0(newElem("div"));
  
  Element update() => addSubComponents0(initElem());
      
  Element addSubComponents0(Element elm) => addListeners(_updateElement(elm));
}

class ExpenseTypeComp extends SelectComp<ExpenseType> {
  static const String EXPENSE_TYPE_INPUT = "g_expense_type_input";
  
  static final Map<String, ExpenseType> _expenseTypes = {
    "TRV": const ExpenseType("Travel","TRV"),
    "BK": const ExpenseType("Books","BK"),
    "HT": const ExpenseType("Hotel","HT")                          
  };
  
  ExpenseTypeComp(Component parent, String label, {List<String> classes: const [SelectComp.SELECT_INPUT, EXPENSE_TYPE_INPUT]}) {
    this.classes.add(EXPENSE_TYPE_INPUT);
    this.parent = parent;
    //this.type = ExpenseType;
    if (classes != null) this.classes.addAll(classes);
  }
  
  static ExpenseTypeComp inputCompFactory(Component c, String name, Type t)=>new ExpenseTypeComp(c, name);
  static String format(ExpenseType et) => (et == null)?'':et.name;
  
  Map<String, ExpenseType> get entityTypes => _expenseTypes;
  
  String getCode(ExpenseType et) => et.code;
  String getName(ExpenseType et) => et.name;
}

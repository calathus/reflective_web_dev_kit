/*
 * author: N, calathus
 * date: 9/23/2013
 */
part of gui_component_lib;

typedef void RowAction(Event event, Row row);
typedef void RowCellAction(Event event, RowCell rcell);

typedef String FormatFunction(Object value);

/*
 * Table will display the content of entities, but it does not allow to modify the entity
 * So table has read only access to entities.
 * In order to modify/create an entity, Form must be used.
 */
abstract class TableComponent extends Component {
  bool get introspection => false; 
}

class Table<E> extends TableComponent {
  static const String TABLE = "g_table";
  static final Map<Type, FormatFunction> defaultFormatFunctionMap = {};
  Map<Type, FormatFunction> formatFunctionMap = {};
  
  Type modelType;
  IClassMirror _cmirror;
  
  TableHeader _theader;
  final List<Row<E>> rows = [];

  final List<RowAction> row_listeners = []; 
  final List<RowCellAction> rcell_listeners = []; 

  Table() {
    classes.add(TABLE);
  }
  
 /*
  Table(Component parent, this.modelType, this._formatFunctionMap, {List<String>  classes: const [TABLE]}){
    if (parent != null) this.parent = parent;
    if (classes != null) this.classes.addAll(classes);
    cmirror = ClassMirrorFactory.reflectClass(modelType);                                                                                                                                      ;
  }
  
  factory Table.fromModelType(Component parent, Type modelType, {Map<Type, FormatFunction> formatFunctionMap: const {}}) =>
    [new Table(parent, modelType, formatFunctionMap)].fold(null, (p, tbl)=>tbl..theader = new TableHeader.fromType(tbl, modelType)); 
  */
  
  IClassMirror get cmirror {
    if (_cmirror == null) {
      if (modelType == null) {
        throw new Exception("Table modelType is not set!");
      }
      _cmirror = ClassMirrorFactory.reflectClass(modelType);
    }
    return _cmirror;
  }
  
  TableHeader get theader {
    if (_theader == null) {
      if (modelType == null) {
        throw new Exception("Table modelType is not set!");
      }
      _theader = new TableHeader.fromType(this, modelType);
    }
    return _theader;
  }
  
  String valueToString(Object v, Type type) {
    FormatFunction fn = formatFunctionMap[type];
    if (fn != null) {
      return fn(v);
    }
    fn = defaultFormatFunctionMap[type];
    if (fn != null) {
      return fn(v);
    }
    return objectToString(v, type);
  }
  
  //
  void newRow() => rows.add(new Row<E>.defaultRow(this));
  
  void addRow(Row<E> row) {
    if (row.table != this) {
      print(">> addRow error");
      throw new Exception("Table<1>");
    }
    rows.add(row);
    element.nodes.add(row.element);
  }
  
  void addRowFromEntity(E e) => addRow(new Row<E>.fromEntity(this, e));
  
  void addOrUpdate(E e) {
    Row<E> row = findRow(e);
    if (row == null) {
      addRowFromEntity(e);
    } else {
      int idx = element.nodes.indexOf(row.element);
      Element newElem = row.update();
      element.nodes
        ..removeAt(idx)
        ..insert(idx, newElem);
    }
  }
  
  Row<E> findRow(E e) => rows.firstWhere((Row<E> row)=>(row.e == e), orElse: ()=>null);
  
  void clear() {
    element.nodes.clear();
    rows.clear();
  }
  
  void load(Iterable<E> es) {
    clear();
    element..nodes.add(updateComponent(theader));  
    es.forEach(addRowFromEntity);
  }
  
  void delete(E e) {
    Row<E> row = findRow(e);
    if (row != null) {
      int idx = element.nodes.indexOf(row.element);
      element.nodes
        ..removeAt(idx);
    }
  }
  
  // DOM
  TableElement createElement() => addSubComponents(rows, newElem("table")..nodes.add(getElement(theader)), getElement);
  
  TableElement update() => addSubComponents(rows, initElem()..nodes.add(updateComponent(theader)), updateComponent);
}

class TableHeader<E> extends TableComponent {
  static const String TH = "g_th";
  final Table<E> table;
  final List<HeaderCell> headerCells;
  
  TableHeader(Table parent, this.headerCells, {List<String> classes: const [TH]}): table = parent {
    if (parent != null) this.parent = parent;
    if (classes != null) this.classes.addAll(classes);
  }
  
  factory TableHeader.fromType(Table parent, Type modelType) {
    var th = new TableHeader(parent, []);
    parent.cmirror.fieldTypes.forEach((_, IFieldType ft){
      if (ft.priv) return;
      GUI_Table tab_anno = getAnnotation(ft.metadata, (obj)=>obj is GUI_Table);
      if (tab_anno == null || !tab_anno.invisible) {
        th.headerCells.add(new HeaderCell.fromSymbol(th, ft.symbol, ft.type));
      }
    });
    return th;
  }
  
  // DOM
  Element createElement() => addSubComponents(headerCells, newElem("thead"), getElement);
  
  Element update() => addSubComponents(headerCells, initElem(), updateComponent);
}

class HeaderCell extends TableComponent {
  static const String HCELL = "g_hcell";
  TableHeader tableHeader;
  Symbol symbol;
  Type type;
  
  // GUI
  String label;
  
  HeaderCell(TableHeader parent, this.symbol, this.type, this.label, {List<String> classes: const [HCELL]}):
    this.tableHeader = parent {
    if (parent != null) this.parent = parent;
    if (classes != null) this.classes.addAll(classes);
  }
  
  factory HeaderCell.fromSymbol(TableHeader tableHeader, Symbol symbol, Type type) =>
    new HeaderCell(tableHeader, symbol, type, getLabel(tableHeader,symbol));
  
  static String getLabel(TableHeader tableHeader, Symbol symbol) {
    IFieldType ft = tableHeader.table.cmirror.fieldTypes[symbol];
    GUI_Table tab_anno = getAnnotation(ft.metadata, (obj)=>obj is GUI_Table);
    if (tab_anno != null && tab_anno.label != null) {
        return tab_anno.label;
    }
    return getSymbolName(symbol);
  }
  
  RowCell defaultRowCell(Row row) => new RowCell(row, this);
  
  // DOM
  Element createElement() => addSubComponents0(new Element.td());
  
  Element update() => addSubComponents0(initElem());

  Element addSubComponents0(Element elm) => addListeners(elm..text = label..classes.add(label));
}

class Row<E> extends TableComponent {
  static const String TR = "g_tr";
  final Table<E> table;
  final E e;
  //final InstanceMirror imirr;
  final IInstanceMirror imirr;
  final List<RowCell> rowCells = [];

  Row(Table parent, E e0, {List<String> classes: const [TR]}): 
    table = parent, e = e0, imirr = parent.cmirror.reflect(e0) {
    if (parent != null) this.parent = parent;
    if (classes != null) this.classes.addAll(classes);
  }
    
  factory Row.defaultRow(Table<E> table) =>
    table.theader.headerCells.fold(new Row(table, null), 
        (Row row, HeaderCell hc) => row..rowCells.add(hc.defaultRowCell(row)));
  
  factory Row.fromEntity(Table<E> table, E e) =>
    table.theader.headerCells.fold(new Row(table, e), 
        (Row row, HeaderCell hc) => row..rowCells.add(new RowCell(row, hc)));
  
  // override
  List<ComponentAction> get listeners => table.row_listeners;

  // DOM
  TableRowElement createElement() => addSubComponents(rowCells, newElem("tr"), getElement);
  
  TableRowElement update() => addSubComponents(rowCells, initElem(), updateComponent);
}

class RowCell extends TableComponent {
  static const String RCELL = "g_rcell";
  final HeaderCell headerCell;
  IField field;
  
  RowCell(Row parent, this.headerCell, {List<String> classes : const [RCELL]}) {
    if (parent != null) this.parent = parent;
    if (classes != null) this.classes.addAll(classes);
    field = row.imirr.getField(headerCell.symbol);
  }
  
  Row get row => parent;
  
  Object get value =>  field.value;
  
  // override
  List<ComponentAction> get listeners => headerCell.tableHeader.table.rcell_listeners;

  // DOM
  Element createElement() => addSubComponents0(new Element.td());
  
  Element update() => addSubComponents0(initElem());

  Element addSubComponents0(Element elm) => addListeners(
      elm
        ..text = headerCell.tableHeader.table.valueToString(value, headerCell.type)
        ..classes.add(headerCell.label));
}


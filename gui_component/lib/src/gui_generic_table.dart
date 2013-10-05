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
class Table<E> extends Component {
  static const String TABLE = "g_table";
  static final Map<Type, FormatFunction> defaultFormatFunctionMap = {};
  final Map<Type, FormatFunction> _formatFunctionMap;
  
  Type modelType;
  IClassMirror cmirror;
  
  TableHeader theader;
  final List<Row<E>> rows;

  final List<RowAction> row_listeners = []; 
  final List<RowCellAction> rcell_listeners = []; 

  Table(Component parent, this.modelType, this._formatFunctionMap, {List<String>  classes: const [TABLE]}): 
    super(parent, classes), rows = [] {
    cmirror = ClassMirrorFactory.reflectClass(modelType);                                                                                                                                      ;
  }
  
  factory Table.fromModelType(Component parent, Type modelType, {Map<Type, FormatFunction> formatFunctionMap: const {}}) =>
    [new Table(parent, modelType, formatFunctionMap)].fold(null, (p, tbl)=>tbl..theader = new TableHeader.fromType(tbl, modelType)); 
  
  String valueToString(Object v, Type type) {
    FormatFunction fn = _formatFunctionMap[type];
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

class TableHeader<E> extends Component {
  static const String TH = "g_th";
  final Table<E> table;
  final List<HeaderCell> headerCells;
  
  TableHeader(Table parent, this.headerCells, {List<String> classes: const [TH]}): super(parent, classes), table = parent;
  
  factory TableHeader.fromType(Table parent, Type modelType) {
    var th = new TableHeader(parent, []);
    parent.cmirror.fieldTypes.forEach((_, IFieldType ft){
      th.headerCells.add(new HeaderCell.fromSymbol(th, ft.symbol, ft.type));
    });
    return th;
  }
  
  // DOM
  Element createElement() => addSubComponents(headerCells, newElem("thead"), getElement);
  
  Element update() => addSubComponents(headerCells, initElem(), updateComponent);
}

class HeaderCell extends Component {
  static const String HCELL = "g_hcell";
  TableHeader tableHeader;
  Symbol symbol;
  Type type;
  
  // GUI
  String label;
  
  HeaderCell(TableHeader parent, this.symbol, this.type, this.label, {List<String> classes: const [HCELL]}):
    super(parent, classes), this.tableHeader = parent;
  
  factory HeaderCell.fromSymbol(TableHeader tableHeader, Symbol symbol, Type type) =>
    new HeaderCell(tableHeader, symbol, type, getSymbolName(symbol));
  
  RowCell defaultRowCell(Row row) => new RowCell(row, this);
  
  // DOM
  Element createElement() => addSubComponents0(new Element.td());
  
  Element update() => addSubComponents0(initElem());

  Element addSubComponents0(Element elm) => addListeners(elm..text = label..classes.add(label));
}

class Row<E> extends Component {
  static const String TR = "g_tr";
  final Table<E> table;
  final E e;
  //final InstanceMirror imirr;
  final IInstanceMirror imirr;
  final List<RowCell> rowCells = [];

  Row(Table parent, E e0, {List<String> classes: const [TR]}): 
    super(parent, classes), table = parent, e = e0, imirr = parent.cmirror.reflect(e0);
    
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

class RowCell extends Component {
  static const String RCELL = "g_rcell";
  final HeaderCell headerCell;
  IField field;
  
  RowCell(Row parent, this.headerCell, {List<String> classes : const [RCELL]}): super(parent, classes) {
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


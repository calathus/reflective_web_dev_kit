/*
 * author: N, calathus
 * date: 9/23/2013
 */
part of gui_component_lib;

class Form<E> extends Component {
  static const String TABLE = "g_table";
  
  final InputFactoryCache inputFactoryCache;
  
  final List<Symbol> _symbols = [];
  final Map<Symbol, InputComp> inputComps = {};
  
  final Type modelType;
  IClassMirror cmirror;
  
  E _e = null;  
  
  Form(Component parent, this.modelType, 
    {
      Map<String, String> adhocCompMap, 
      Map<Type, InputCompFactory> specialInputCompMap,
      List<String> classes: const [TABLE]
    }): super(parent, classes), inputFactoryCache = new InputFactoryCache(adhocCompMap, specialInputCompMap) {
    //
    cmirror = ClassMirrorFactory.reflectClass(modelType);
    cmirror.fieldTypes.forEach((_, IFieldType ft){
      GUI_Form form_anno = getAnnotation(ft.metadata, (obj)=>obj is GUI_Form);
       _symbols.add(ft.symbol);
       InputComp inputComp = inputFactoryCache.getInputComp(this, ft.name, ft.type);
       if (form_anno != null) {
         inputComp.options = form_anno;
       }
      inputComps[ft.symbol] = inputComp;
    });
  }
  
  E get e=>_e;

  E create() => _init(cmirror.newInstance().reflectee);

  void load(E e) {
    this._e = e;
    IInstanceMirror imirr = cmirror.reflect(e);
    _symbols.forEach((Symbol symbol){
      inputComps[symbol].value = imirr.getField(symbol).value;
    });
   }
  
  E save() {
    // even if extraction fails, it won't damage the entity!
    if (_e == null) {
      print(">> no entity to save, click New or select row in the table before save");
      return null;
    }
    Map<Symbol, Object> vals = {};
    try {
      _symbols.forEach((Symbol symbol){
        vals[symbol] = inputComps[symbol].value;
      });
    } catch (e) {
      print(">> failed to save: reason: ${e.toString()}");
      return null;
    }
    
    IInstanceMirror imirr = cmirror.reflect(_e);
    vals.forEach((Symbol symbol, Object val) {
      imirr.getField(symbol).value = val;
    });
    
    E e = imirr.reflectee;
    clear();
    return e;
  }
  
  E delete() {
    if (_e == null) {
      print(">> no entity to delete.");
      return null;
    }
    E e = _e;
    clear();
    return e;
  }
  
  void clear() { _init(null); }

  E _init(E e) {
     _e = e;
    inputComps.forEach((_, InputComp inputComp){
      inputComp.value = null;
    });
    return e;
  }
  
  // DOM
  Element createElement() =>addSubComponents0(newElem("div"));
  
  Element update() => addSubComponents0(initElem());
      
  Element addSubComponents0(Element elm) => addListeners(
      _symbols.fold(elm, (Element eml0, Symbol symbol)=>
          elm
            ..nodes.add(inputComps[symbol].element)
            ..nodes.add(newElem("br")))
      );
}

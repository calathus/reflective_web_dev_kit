library json_mapper_v1;

import "dart:json";

import 'package:portable_mirror/mirror_api_lib.dart';

part 'src/dart_JsonStringifier.dart'; // this should be eliminated, dart:json should have pblic class JsonStringifier instead of _JsonStringifier

typedef dynamic ConstructorFun(Map map);
typedef dynamic StringifierFun(Object obj);
typedef dynamic ConvertFun(Object obj);

abstract class ISpecialTypeMapHandler {
  ConstructorFun entityCtor(Type type);
  StringifierFun stringifier(Type type);
  ConvertFun convert(Type type);
}

class SpecialTypeMapHandler implements ISpecialTypeMapHandler {
  final Map<Type, ConstructorFun> entityCtors;
  final Map<Type, ConvertFun> _converts = {DateTime: (Object value)=>DateTime.parse(value)};
  final Map<Type, StringifierFun> _stringifiers = {DateTime: (DateTime dt) => '"${dt.toString()}"'};
  
  SpecialTypeMapHandler(this.entityCtors, {Map<Type, ConvertFun> converts, Map<Type, StringifierFun> stringifiers}) {
    if (converts != null) _converts.addAll(converts);
    if (stringifiers != null) _stringifiers.addAll(stringifiers);
  }
  
  ConstructorFun entityCtor(Type type)=>(entityCtors == null)?null:entityCtors[type];
  ConvertFun convert(Type type)=>_converts[type];
  StringifierFun stringifier(Type type)=>_stringifiers[type];
}

//
//
//
abstract class IJsonMapper {
  
  Object fromJson(Type modelType, String json, {Map<String, String> attr_redirect_map: const{}});
  
  String toJson(final object, {StringSink output});
}

class JsonMapper implements IJsonMapper {
  EntityJsonParser parser;
  EntityJsonStringifier stringifier;
  ISpecialTypeMapHandler mapHandler;
  
  JsonMapper(this.mapHandler, {_Reviver reviver}) {
    parser = new EntityJsonParser(mapHandler, reviver: reviver);
    stringifier = new EntityJsonStringifier(mapHandler);
  }

  Object fromJson(Type modelType, String json, {Map<String, String> attr_redirect_map: const{}}) => parser.parse(modelType, json, attr_redirect_map);
  
  String toJson(final object, {StringSink output}) => stringifier.toJson(object, output: output);
}

//
// json parser
//
typedef _Reviver(var key, var value);

class EntityJsonParser {
  //EntityBuildJsonListener listener; // TODO.. this would be effcient way..
  ISpecialTypeMapHandler mapHandler;
  _Reviver _reviver;
  
  EntityJsonParser(this.mapHandler, {_Reviver reviver}) {
    _reviver = reviver;
  }
  
  EntityBuildJsonListener getListener(Type modelType, Map<String, String> attr_redirect_map) =>(_reviver == null)?new EntityBuildJsonListener(mapHandler, modelType, attr_redirect_map)
      :new EntityReviverJsonListener(mapHandler, modelType, _reviver, attr_redirect_map);

  dynamic parse(Type modelType, String json, Map<String, String> attr_redirect_map) { 
    EntityBuildJsonListener listener =  getListener(modelType, attr_redirect_map);
    new JsonParser(json, listener).parse();
    return listener.result;
  }
}

class EntityBuildJsonListener extends BuildJsonListener {
  final ISpecialTypeMapHandler mapHandler;
  final Map<String, String> attr_redirect_map;
  
  IClassMirror _currentCmirror = null;
  List<IClassMirror> cmirrorStack = [];
  
  bool debug = false;
  
  EntityBuildJsonListener(this.mapHandler, Type modelType, this.attr_redirect_map) {
    currentCmirror = ClassMirrorFactory.reflectClass(modelType);
  }
    
  IClassMirror get currentCmirror => _currentCmirror;
  
  void set currentCmirror(IClassMirror currentCmirror) {
    _currentCmirror = currentCmirror;
    if (debug) print('### _currentCmirror: ${_currentCmirror.type}');
  }
  
  /** Pushes the currently active container (and key, if a [Map]). */
  void pushContainer() {
    super.pushContainer();
    cmirrorStack.add(currentCmirror);
  }

  /** Pops the top container from the [stack], including a key if applicable. */
  void popContainer() {
    super.popContainer();
    currentCmirror = cmirrorStack.removeLast();
  }
  void beginObject() {
    if (debug) print('--->1 beginObject _currentCmirror: ${_currentCmirror.type}, key: ${key}');
    super.beginObject();
    if (key != null) {
      IFieldType ft = currentCmirror.fieldTypes[new Symbol(key)];
      if (ft != null) {
        currentCmirror = ft.cmirror;
        //currentCmirror = ClassMirrorFactory.reflectClass(ft.type);
      } else {
        print('>> beginObject ${key}');
        currentCmirror = null;
      }
    }
    if (debug) print('--->2 beginObject _currentCmirror: ${_currentCmirror.type}');
  }

  void endObject() {
    if (debug) print('--->1 endObject _currentCmirror: ${_currentCmirror.type}');
    Map map = currentContainer;
    if (currentCmirror.type != Map) {
      Map map = currentContainer;
      ConstructorFun spCtor = mapHandler.entityCtor(currentCmirror.type);
      if (spCtor != null) {
        currentContainer = spCtor(map);
      } else {
        // Dart Beans
        IInstanceMirror imiror = currentCmirror.newInstance();
        currentCmirror.fieldTypes.forEach((_, IFieldType ft){
          ConstructorFun vCtor = mapHandler.convert(ft.type);
          
          // in choucg DB, id must be mapped from _id, rev from _rev depending on teh scenario..
          String redirect_name = attr_redirect_map[ft.name];
          String name = (redirect_name == null)?ft.name:redirect_name;
          if (debug) print('===> redirect_name: ${redirect_name}, name: ${name}');
          var value = map[name];
          imiror.getField(ft.symbol).value = (vCtor != null)?vCtor(value):value;
        });
        currentContainer = imiror.reflectee;
      }
    }
    super.endObject();
    if (debug) print('--->2 endObject _currentCmirror: ${_currentCmirror.type}');
  }
  
  void beginArray() {
    if (debug) print('--->1 beginArray _currentCmirror: ${_currentCmirror.type}, key: ${key}');
    super.beginArray();
    if (key != null) {
      IFieldType ft = currentCmirror.fieldTypes[new Symbol(key)];
      if (ft != null) {
        currentCmirror = ft.cmirror;
        //currentCmirror = ClassMirrorFactory.reflectClass(ft.type);
      } else {
        print('>> beginArray ${key}');
        currentCmirror = null;
      }
      if (debug) print('>>>>beginArray: ${currentCmirror.type}');
      // adhoc way, but how to get generic classList from ClassMirror???
      String typeName = currentCmirror.type.toString();
      if (typeName.startsWith("List<") || typeName.startsWith("Set<")) {
        currentCmirror = currentCmirror.typeArguments[0];
      } else {
        throw new Exception(); //
      }
      key = null;
    } else {
      // top level
    }
    if (debug) print('--->2 beginArray _currentCmirror: ${_currentCmirror.type}');
 }

  void endArray() {
   if (debug) print('--->1 endArray _currentCmirror: ${_currentCmirror.type}');
   super.endArray();
   if (debug) print('--->2 endArray _currentCmirror: ${_currentCmirror.type}');
  }
}

class EntityReviverJsonListener extends EntityBuildJsonListener {
  final _Reviver reviver;
  
  EntityReviverJsonListener(ISpecialTypeMapHandler mapHandler, Type modelType, reviver(key, value), Map<String, String> attr_redirect_map)
  : super(mapHandler, modelType, attr_redirect_map), this.reviver = reviver;

  void arrayElement() {
    List list = currentContainer;
    value = reviver(list.length, value);
    super.arrayElement();
  }

  void propertyValue() {
    value = reviver(key, value);
    super.propertyValue();
  }

  get result {
    return reviver("", value);
  }
}

//
// entity(including list, map) stringifier
//
class EntityJsonStringifier extends _JsonStringifier {
  final ISpecialTypeMapHandler mapHandler;
  
  EntityJsonStringifier(this.mapHandler): super(null);
  
  String toJson(final obj, {StringSink output}) {
     this..sink = (output != null)?output:new StringBuffer()
    ..seen = [];
    stringifyValue(obj);
    return sink.toString();
  }

  // @Override
  void stringifyValue(final object) {
    if (!stringifyJsonValue(object)) {
      checkCycle(object);
      try {
        // if toJson is defined, it will be used.
        var customJson = object.toJson();
        if (!stringifyJsonValue(customJson)) {
          throw new JsonUnsupportedObjectError(object);
        }
      } catch (e) {
        // if toJson is not defined..
        if (!stringifyJsonValue(object)) {
          stringifyEntity(object);
        }
      }
      seen.removeLast();
    }
  }
  
  void stringifyEntity(final object) {
    // this require dirt:mirrors
    Type t = ClassMirrorFactory.getType(object);
    StringifierFun stringfier = mapHandler.stringifier(t);
    if (stringfier != null) {
      sink.write(stringfier(object));
      return;
    }
    
    //
    IClassMirror cmirror = ClassMirrorFactory.reflectClass(t); // ??
    IInstanceMirror iimirr = cmirror.reflect(object);
    
    sink.write('{');
    int idx = 0;
    Map fmap = cmirror.fieldTypes;
    int lastIdx = fmap.length-1;
    fmap.forEach((k, IFieldType ft){
      sink.write('"${ft.name}": ');
      stringifyValue(iimirr.getField(k).value);
      sink.write((idx == lastIdx)?"":",");
      idx++;
    });
    sink.write('}');   
  }
}

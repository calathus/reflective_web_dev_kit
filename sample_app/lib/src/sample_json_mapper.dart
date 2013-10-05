library sample_json_mapper;

import 'dart:json';
import "package:json_mapper/json_mapper_v1.dart";

import 'models.dart';

var _JSON_parse = parse;

IJsonMapper createSampleJsonMapper() {
  final Map<Type, ConstructorFun> entityCtors = {ExpenseType: (Map map)=>new ExpenseType(map['name'], map['code'])};
  final Map<Type, StringifierFun> stringifiers = {ExpenseType: (ExpenseType et) => '{"name": "${et.name}", "code": "${et.code}"}'};
  ISpecialTypeMapHandler mapHandler = new SpecialTypeMapHandler(entityCtors, stringifiers: stringifiers);
  return new JsonMapper(mapHandler);
}

IJsonMapper sampleJsonMapper = createSampleJsonMapper();

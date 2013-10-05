library couchdb_client;

import 'dart:html';
import 'dart:async';
import "package:json_mapper/json_mapper_v1.dart";

part '../src/client/couchdb_client_dao.dart';

abstract class ICouchDbClientDAO<T> {
  Future<List<T>> fetchAll();
  Future<T> insert(T e);
  Future<T> update(T e);
  Future<bool> delete(T e);
}


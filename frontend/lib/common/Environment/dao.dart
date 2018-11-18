import 'package:chitchat/common/Models/query_entry.dart';

abstract class DAO<T> {
  Future<Object> create(T element, [bool updateIfExist=false]);
  Future<void> update(T element, [bool createIfNotExist=false]);
  Future<bool> delete(Map<String, QueryEntry> filter);
  Future<T> get(Map<String, QueryEntry> filter);
  Future<List<T>> getAll(Map<String, QueryEntry> filter);
}

enum DAOException {
  filterNotUniqueException,     //Thrown if query for getting one element returns more than one element
}
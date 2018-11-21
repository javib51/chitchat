import 'package:chitchat/common/Models/query_entry.dart';

//Abstract class that must be implemented by all DAOs dealing with objects that can be store in any kind of storage.
abstract class DAO<T> {

  //Create a new instance of the object. Returns any kind of object back as result, including null.
  //updateIfExist: if true, overrides the existing saved element. False otherwise. Defaults to false.
  Future<Object> create(T element, [bool updateIfExist=false]);

  //Update an instance of the object. Returns any kind of object back as result, including null.
  //createIfNotExist: if true, creates a new element if the element does not exist already. False otherwise. Defaults to false.
  Future<Object> update(T element, [bool createIfNotExist=false]);

  //Delete all elements matching the given filtering criteria. Returns true if at least an element is deleted. False otherwise.
  //filter: a map of String:QueryEntry. For more info see the `QueryEntry` definition in the `Models` folder.
  Future<bool> delete(Map<String, QueryEntry<T>> filter);

  //Get all the elements matching the given filtering criteria.
  //filter: a map of String:QueryEntry. For more info see the `QueryEntry` definition in the `Models` folder.
  Future<List<T>> getAll(Map<String, QueryEntry<T>> filter);

  //Get the element matching the given filtering criteria. If there is more than one element matching, the function throws a DAOException.filterNotUniqueException.
  //filter: a map of String:QueryEntry. For more info see the `QueryEntry` definition in the `Models` folder.
  Future<T> get(Map<String, QueryEntry<T>> filter);
}

enum DAOException {
  filterNotUniqueException,     //Thrown if query for getting one element returns more than one element
}
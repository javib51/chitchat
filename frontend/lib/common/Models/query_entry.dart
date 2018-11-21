import 'package:meta/meta.dart';

enum ValueComparisonLogic {
  gt,   //>
  ge,   //>=
  e,    //==
  le,   //<=
  lt,   //<
  n,    //== null
  nn    //!= null
}

//Entity representing a single query parameter specifically dealing with Firebase database.
class QueryEntry<T> {

  QueryEntry({@required this.comparisonValue, this.l=ValueComparisonLogic.e});

  //The threshold value to insert in the query (specifically with ==, !=, >, >=, <=).
  final T comparisonValue;

  //The comparison logic to apply.
  final ValueComparisonLogic l;
}
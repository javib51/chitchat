import 'package:meta/meta.dart';

class QueryEntry<T> {

  QueryEntry({@required this.value, this.l=ValueComparisonLogic.e});

  T value;
  ValueComparisonLogic l;
}

enum ValueComparisonLogic {
  gt,   //>
  ge,   //>=
  e,    //==
  le,   //<=
  lt,   //<
  n,    //== null
  nn    //!= null
}
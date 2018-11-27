abstract class FirestoreCompatible {
  Map<String, dynamic> getTopLevelFirestoreStructure();
  //{collection_name: [element_name: {attr_1: value_1, attr_2: value_2...}...]}
  Map<String, List<MapEntry<String, Map<String, dynamic>>>> getNestedFirestoreCollections();
}
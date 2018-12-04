
class Response {
  final List<Result> results;

  Response({this.results});

  factory Response.fromJson(Map<String, dynamic> parsedJson){
    var list = parsedJson['results'] as List;

    List<Result> resultList = list.map((i) => Result.fromJson(i))
        .toList();

    return Response(
        results: resultList
    );
  }
}

class Result {
  final List<Alternative> alternatives;

  Result({this.alternatives});

  factory Result.fromJson(Map<String, dynamic> parsedJson){
    var list = parsedJson['alternatives'] as List;

    List<Alternative> alternativesList = list.map((i) => Alternative.fromJson(i))
        .toList();


    return Result(
        alternatives: alternativesList
    );
  }
}

class Alternative {
  final String transcript;
  final double confidence;

  Alternative({
  this.confidence, this.transcript
  });

  factory Alternative.fromJson(Map<String, dynamic> parsedJson){
  return Alternative(
  transcript:parsedJson['transcript'],
  confidence:parsedJson['confidence']
  );
  }
}




import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:number_trivia/core/error/exception.dart';

import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

const NUMBERS_API_COM = 'http://numbersapi.com/';

abstract class NumberTriviaRemoteDataSource {
  /// calls the http://numbersapi.com/{number} endpoint
  ///
  /// Throws a [ServerException] for all error codes
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// calls the http://numbersapi.com/random endpoint
  ///
  /// Throws a [ServerException] for all error codes
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    return await _getTriviaFromUrl(NUMBERS_API_COM + '$number');
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async {
    return await _getTriviaFromUrl(NUMBERS_API_COM + 'random');
  }

  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    final response = await client
        .get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

    if (response.statusCode != 200) throw ServerException();

    return Future.value(NumberTriviaModel.fromJson(json.decode(response.body)));
  }
}

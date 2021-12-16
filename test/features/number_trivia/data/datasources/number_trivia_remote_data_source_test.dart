import 'dart:convert';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockClient mockHttpClient;
  final tNumberTriviaModel =
      NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (realInvocation) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientBadRequest400() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (realInvocation) async => http.Response('Something went wrong', 400));
  }

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;

    test(
        'should perform a GET request on the numbers API URL with application/json header',
        () async {
      // Arrange
      setUpMockHttpClientSuccess200();
      // Act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      // Assert
      verify(mockHttpClient.get(Uri.parse(NUMBERS_API_COM + tNumber.toString()),
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTriviaModel when the status code is 200',
        () async {
      // Arrange
      setUpMockHttpClientSuccess200();
      // Act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      // Assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when Response Code is not 200',
        () async {
      // Arrange
      setUpMockHttpClientBadRequest400();
      // Act
      final call = dataSource.getConcreteNumberTrivia;
      // Assert
      expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    test('should make a GET Request to the numbers API random endpoint',
        () async {
      // Arrange
      setUpMockHttpClientSuccess200();
      // Act
      final result = await dataSource.getRandomNumberTrivia();
      // Assert
      verify(mockHttpClient.get(Uri.parse(NUMBERS_API_COM + 'random'),
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return a NumberTriviaModel when the status code is 200',
        () async {
      // Arrange
      setUpMockHttpClientSuccess200();
      // Act
      final result = await dataSource.getRandomNumberTrivia();
      // Assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the status code is not 200',
        () async {
      // Arrange
      setUpMockHttpClientBadRequest400();
      // Act
      final call = dataSource.getRandomNumberTrivia;
      // Assert
      expect(() => call(), throwsA(TypeMatcher<ServerException>()));
    });
  });
}

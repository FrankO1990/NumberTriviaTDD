import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  final tNumberTrivia = NumberTrivia(text: 'test text', number: 1);

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        concreteNumberTrivia: mockGetConcreteNumberTrivia,
        randomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test('initalState should be Empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = int.parse(tNumberString);

    void setUpMockInputConverterSuccess() {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Right(tNumberParsed));
    }

    void setUpMockGetConcreteNumberTriviaCallSuccess() {
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((realInvocation) async => Right(tNumberTrivia));
    }

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      // Arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaCallSuccess();
      // Act
      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      // Assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () async {
      // Arrange
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));
      // Assert later
      final expectedStatesInOrder = [
        Error(message: INVALID_INPUT_FAILURE_MESSAGE)
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStatesInOrder));
      // Act
      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
    });

    test('should get data from the concrete use case', () async {
      // Arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaCallSuccess();
      // Act
      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      // Assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully',
        () async {
      // Arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaCallSuccess();
      // Assert later
      final expected = [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
    });

    test(
        'should emit [Loading, Error with server failure message] when getting data fails',
        () async {
      // Arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(ServerFailure()));
      // Assert later
      final expected = [Loading(), Error(message: SERVER_FAILURE_MESSAGE)];
      expectLater(bloc.stream, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
    });

    test(
        'should emit [Loading, Error with cache failure message] when getting data from cache fails',
        () async {
      // Arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(CacheFailure()));
      // Assert later
      final expected = [Loading(), Error(message: CACHE_FAILURE_MESSAGE)];
      expectLater(bloc.stream, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
    });
  });
  group('GetTriviaForRandomNumber', () {
    void setUpMockGetRandomNumberTriviaSuccess() {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((realInvocation) async => Right(tNumberTrivia));
    }

    test('should get data from the random number use case', () async {
      // Arrange
      setUpMockGetRandomNumberTriviaSuccess();
      // Act
      bloc.add(GetTriviaForRandomNumberEvent());
      await untilCalled(mockGetRandomNumberTrivia(any));
      // Assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully',
        () async {
      // Arrange
      setUpMockGetRandomNumberTriviaSuccess();
      // Assert later
      final expected = [Loading(), Loaded(trivia: tNumberTrivia)];
      expectLater(bloc.stream, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForRandomNumberEvent());
    });
    test(
        'should emit [Loading, Error with server failure message] when failure is of type ServerFailure',
        () async {
      // Arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(ServerFailure()));
      // Assert later
      final expected = [Loading(), Error(message: SERVER_FAILURE_MESSAGE)];
      expectLater(bloc.stream, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForRandomNumberEvent());
    });

    test(
        'should emit [Loading, Error with cache failure message] when failure is of type CacheFailure',
        () async {
      // Arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(CacheFailure()));
      // Asster later
      final expected = [Loading(), Error(message: CACHE_FAILURE_MESSAGE)];
      expectLater(bloc.stream, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForRandomNumberEvent());
    });
  });
}

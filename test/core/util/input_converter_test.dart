import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInteger', () {
    test(
        'should return an integer when the string input represents an unsigned integer',
        () async {
      // Arrange
      final str = '123';
      // Act
      final result = inputConverter.stringToUnsignedInteger(str);
      // Assert
      expect(result, Right(123));
    });

    test(
        'should return InvalidInputFailure when the string input represents a negative integer',
        () async {
      // Arrange
      final str = '-123';
      // Act
      final result = inputConverter.stringToUnsignedInteger(str);
      // Assert
      expect(result, equals(Left(InvalidInputFailure())));
    });

    test(
        'should return InvalidInputFailure when the string input contains a non parsable value',
        () async {
      // Arrange
      final str = '*12+2';
      // Act
      final result = inputConverter.stringToUnsignedInteger(str);
      // Assert
      expect(result, equals(Left(InvalidInputFailure())));
    });
  });
}

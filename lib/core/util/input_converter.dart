import 'package:dartz/dartz.dart';
import 'package:number_trivia/core/error/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      int convertedInteger = int.parse(str);
      if (convertedInteger >= 0) {
        return Right(convertedInteger);
      } else {
        throw FormatException();
      }
    } catch (exception) {
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure {
  @override
  List<Object?> get props => [];
}

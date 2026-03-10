part of 'exceptions.dart';

sealed class FileException implements KebabException {
  @override
  final CodeLocation? location;

  const FileException([this.location]);
}

final class FileInputNotProvidedExceprion extends FileException {
  @override
  String get message => "Input file does not provide";

  const FileInputNotProvidedExceprion([super.location]);
}

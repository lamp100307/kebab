part of 'exceptions.dart';

sealed class FileException implements KebabException {
  @override
  final CodeLocation? location;

  const FileException([this.location]);
}

final class FileInputNotProvidedException extends FileException {
  @override
  String get message => "Input file does not provide";

  const FileInputNotProvidedException([super.location]);
}

final class FileInputNotExistsException extends FileException {
  final String path;

  @override
  String get message => "File ($path) does not exist";

  const FileInputNotExistsException(this.path, [super.location]);
}

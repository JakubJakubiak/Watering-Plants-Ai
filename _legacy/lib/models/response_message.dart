import 'package:dart_mappable/dart_mappable.dart';

part 'response_message.mapper.dart';

@MappableClass()
class ResponseMessage with ResponseMessageMappable {
  final String name;
  final String response;
  final List<String> quickQuestions;

  const ResponseMessage({
    required this.name,
    required this.response,
    required this.quickQuestions,
  });

  static const fromMap = ResponseMessageMapper.fromMap;
  static const fromJson = ResponseMessageMapper.fromJson;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'response_message.dart';

class ResponseMessageMapper extends ClassMapperBase<ResponseMessage> {
  ResponseMessageMapper._();

  static ResponseMessageMapper? _instance;
  static ResponseMessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ResponseMessageMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ResponseMessage';

  static String _$name(ResponseMessage v) => v.name;
  static const Field<ResponseMessage, String> _f$name = Field('name', _$name);
  static String _$response(ResponseMessage v) => v.response;
  static const Field<ResponseMessage, String> _f$response =
      Field('response', _$response);
  static List<String> _$quickQuestions(ResponseMessage v) => v.quickQuestions;
  static const Field<ResponseMessage, List<String>> _f$quickQuestions =
      Field('quickQuestions', _$quickQuestions);

  @override
  final MappableFields<ResponseMessage> fields = const {
    #name: _f$name,
    #response: _f$response,
    #quickQuestions: _f$quickQuestions,
  };

  static ResponseMessage _instantiate(DecodingData data) {
    return ResponseMessage(
        name: data.dec(_f$name),
        response: data.dec(_f$response),
        quickQuestions: data.dec(_f$quickQuestions));
  }

  @override
  final Function instantiate = _instantiate;

  static ResponseMessage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ResponseMessage>(map);
  }

  static ResponseMessage fromJson(String json) {
    return ensureInitialized().decodeJson<ResponseMessage>(json);
  }
}

mixin ResponseMessageMappable {
  String toJson() {
    return ResponseMessageMapper.ensureInitialized()
        .encodeJson<ResponseMessage>(this as ResponseMessage);
  }

  Map<String, dynamic> toMap() {
    return ResponseMessageMapper.ensureInitialized()
        .encodeMap<ResponseMessage>(this as ResponseMessage);
  }

  ResponseMessageCopyWith<ResponseMessage, ResponseMessage, ResponseMessage>
      get copyWith => _ResponseMessageCopyWithImpl(
          this as ResponseMessage, $identity, $identity);
  @override
  String toString() {
    return ResponseMessageMapper.ensureInitialized()
        .stringifyValue(this as ResponseMessage);
  }

  @override
  bool operator ==(Object other) {
    return ResponseMessageMapper.ensureInitialized()
        .equalsValue(this as ResponseMessage, other);
  }

  @override
  int get hashCode {
    return ResponseMessageMapper.ensureInitialized()
        .hashValue(this as ResponseMessage);
  }
}

extension ResponseMessageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ResponseMessage, $Out> {
  ResponseMessageCopyWith<$R, ResponseMessage, $Out> get $asResponseMessage =>
      $base.as((v, t, t2) => _ResponseMessageCopyWithImpl(v, t, t2));
}

abstract class ResponseMessageCopyWith<$R, $In extends ResponseMessage, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
      get quickQuestions;
  $R call({String? name, String? response, List<String>? quickQuestions});
  ResponseMessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _ResponseMessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ResponseMessage, $Out>
    implements ResponseMessageCopyWith<$R, ResponseMessage, $Out> {
  _ResponseMessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ResponseMessage> $mapper =
      ResponseMessageMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
      get quickQuestions => ListCopyWith(
          $value.quickQuestions,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(quickQuestions: v));
  @override
  $R call({String? name, String? response, List<String>? quickQuestions}) =>
      $apply(FieldCopyWithData({
        if (name != null) #name: name,
        if (response != null) #response: response,
        if (quickQuestions != null) #quickQuestions: quickQuestions
      }));
  @override
  ResponseMessage $make(CopyWithData data) => ResponseMessage(
      name: data.get(#name, or: $value.name),
      response: data.get(#response, or: $value.response),
      quickQuestions: data.get(#quickQuestions, or: $value.quickQuestions));

  @override
  ResponseMessageCopyWith<$R2, ResponseMessage, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _ResponseMessageCopyWithImpl($value, $cast, t);
}

import '../ai_client.dart';

const String _imageEditEndpoint = String.fromEnvironment(
  'AWS_LAMBDA_IMAGE_EDIT_URL',
);

Future<Map<String, dynamic>> editImage(
  String provider,
  String model,
  String image,
  String prompt, {
  Map<String, dynamic> parameters = const {},
}) async {
  final payload = {
    'provider': provider,
    'model': model,
    'image': image,
    'prompt': prompt,
    'parameters': parameters,
  };
  return await callLambdaFunction(_imageEditEndpoint, payload);
}

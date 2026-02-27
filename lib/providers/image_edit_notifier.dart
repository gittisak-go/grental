import 'package:flutter/foundation.dart';
import '../core/services/aiIntegrations/image_edit_service.dart';

class ImageEditConfig {
  final String provider;
  final String model;

  const ImageEditConfig({required this.provider, required this.model});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageEditConfig &&
          provider == other.provider &&
          model == other.model;

  @override
  int get hashCode => provider.hashCode ^ model.hashCode;
}

class ImageEditState {
  final Map<String, dynamic>? image;
  final bool isLoading;
  final Exception? error;

  const ImageEditState({this.image, this.isLoading = false, this.error});

  ImageEditState copyWith({
    Map<String, dynamic>? image,
    bool? isLoading,
    Exception? error,
    bool clearError = false,
    bool clearImage = false,
  }) {
    return ImageEditState(
      image: clearImage ? null : (image ?? this.image),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ImageEditNotifier extends ChangeNotifier {
  final String provider;
  final String model;
  ImageEditState _state = const ImageEditState();

  ImageEditState get state => _state;

  ImageEditNotifier({required this.provider, required this.model});

  Future<Map<String, dynamic>?> edit(
    String sourceImage,
    String prompt, {
    Map<String, dynamic> parameters = const {},
  }) async {
    _state = const ImageEditState(isLoading: true);
    notifyListeners();
    try {
      final result = await editImage(
        provider,
        model,
        sourceImage,
        prompt,
        parameters: parameters,
      );
      _state = ImageEditState(image: result, isLoading: false);
      notifyListeners();
      return result;
    } catch (error) {
      _state = ImageEditState(
        error: error is Exception ? error : Exception(error.toString()),
        isLoading: false,
      );
      notifyListeners();
      return null;
    }
  }

  void clearImage() {
    _state = const ImageEditState();
    notifyListeners();
  }
}
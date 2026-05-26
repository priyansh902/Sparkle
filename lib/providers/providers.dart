import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);
final errormessageProvider = StateProvider<String?>((ref) => null);


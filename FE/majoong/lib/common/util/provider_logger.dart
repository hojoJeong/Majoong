import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase<Object?> provider, Object? previousValue,
      Object? newValue, ProviderContainer container) {
    super.didUpdateProvider(provider, previousValue, newValue, container);
    print('[Provider Update] provider :  $provider, pre :  $previousValue, new : $newValue');
  }

  @override
  void didAddProvider(ProviderBase<Object?> provider, Object? value, ProviderContainer container) {
    super.didAddProvider(provider, value, container);
    print('[Provider add] provider :  $provider., value :  $value');
  }

  @override
  void didDisposeProvider(ProviderBase<Object?> provider, ProviderContainer container) {
    super.didDisposeProvider(provider, container);
    print('[Provider dispose] provider :  $provider');
  }
}
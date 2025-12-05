import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

T useDebounce<T>(T value, Duration delay) {
  final debouncedValue = useState(value);

  useEffect(() {
    final timer = Timer(delay, () {
      debouncedValue.value = value;
    });

    return timer.cancel;
  }, [value, delay]);

  return debouncedValue.value;
}

void useDebouncedEffect(
  VoidCallback effect,
  Duration delay,
  List<Object?> keys,
) {
  useEffect(() {
    final timer = Timer(delay, effect);
    return timer.cancel;
  }, keys);
}

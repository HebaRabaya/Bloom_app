double parseDouble(
  dynamic value, {
  double fallback = 0,
}) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      fallback;
}

int parseInt(
  dynamic value, {
  int fallback = 0,
}) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      fallback;
}

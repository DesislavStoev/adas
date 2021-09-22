extension NullSafe on int? {
  int makeItNullSafe() {
    return this ?? 0;
  }
}

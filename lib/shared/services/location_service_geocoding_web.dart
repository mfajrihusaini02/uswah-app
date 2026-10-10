/// Stub geocoding untuk platform web.
/// Package geocoding tidak support web, sehingga selalu fallback ke 'Jakarta'.
Future<String> geocodeCityName({
  required double latitude,
  required double longitude,
}) async {
  return 'Jakarta';
}

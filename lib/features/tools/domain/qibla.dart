import 'dart:math' as math;

/// Kaaba coordinates used for the Qibla (from the product spec).
const kaabaLatitude = 21.4225;
const kaabaLongitude = 39.8262;

/// Initial great-circle bearing from (lat, lng) to the Kaaba, degrees
/// clockwise from true north in [0, 360).
double qiblaBearing(double latitude, double longitude) {
  double rad(double d) => d * math.pi / 180;
  final phi1 = rad(latitude);
  final phi2 = rad(kaabaLatitude);
  final dLambda = rad(kaabaLongitude - longitude);
  final y = math.sin(dLambda);
  final x = math.cos(phi1) * math.tan(phi2) - math.sin(phi1) * math.cos(dLambda);
  final deg = math.atan2(y, x) * 180 / math.pi;
  return (deg + 360) % 360;
}

/// Angle to rotate the Qibla arrow on screen given the device heading
/// (degrees from north). 0 means the phone points at the Qibla.
double qiblaRelativeToHeading(double bearing, double heading) {
  final r = (bearing - heading) % 360;
  return r < 0 ? r + 360 : r;
}

/// True when the phone is within [tolerance] degrees of the Qibla.
bool isFacingQibla(double bearing, double heading, {double tolerance = 5}) {
  final r = qiblaRelativeToHeading(bearing, heading);
  return r <= tolerance || r >= 360 - tolerance;
}

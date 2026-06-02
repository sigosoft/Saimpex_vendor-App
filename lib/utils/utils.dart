import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/app_loader.dart';

String getCurrencySymbol() {
  return "MRU ";
}

savename(String key, value) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(value));
  } catch (e) {
    throw e;
  }
}

getSavedObject(String key) async {
  final prefs = await SharedPreferences.getInstance();
  var data = prefs.getString(key);
  return data != null ? json.decode(data) : null;
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

removename(String key) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  } catch (e) {
    throw e;
  }
}

showErrorMessage(error) {
  if (isInDebugMode) {
    debugPrint("Error is :$error");
  }
  if (!error.toString().contains("setState()")) {
    if (error is DioException) {
      DioException e = error;
      debugPrint("Error is :${error.response!.data}");
      var message = e.response!.data["message"];
      if (message == null) {
        message = e.response!.data["message"];
        message ??= "Oops Something went wrong try again !!";
      } else {
        message = e.response!.data["message"];
      }
      Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: error?.toString() ?? "Oops Something went wrong try again !!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

void showToast(BuildContext context, String message) {
  FocusScope.of(context).requestFocus(FocusNode());
  final overlay = Overlay.of(context);

  // Calculate the position based on the keyboard visibility
  double bottomPadding = 50.0; // Default padding for toast
  if (MediaQuery.of(context).viewInsets.bottom > 0) {
    // Keyboard is visible, adjust the position
    bottomPadding = MediaQuery.of(context).viewInsets.bottom + 50.0;
  }

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: bottomPadding, // Adjust the position of the toast
      left: MediaQuery.of(context).size.width * 0.1, // Center horizontally
      right: MediaQuery.of(context).size.width * 0.1, // Center horizontally
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  'lib/assets/images/logo.png', // Replace with your image path
                  width: 24,
                  height: 24,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.rubik(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Remove the toast after 3 seconds
  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

void navigateTo(double lat, double lng) async {
  if (Platform.isIOS) {
    var uri = Uri.parse("http://maps.apple.app/q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  } else {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }
}

bool emailValid(String email) {
  return true;
}

Future<bool> checkNetwork() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.mobile) {
    debugPrint('Connected to mobile network');
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    debugPrint('Connected to WiFi');
    return true;
  } else {
    debugPrint('No internet connection');
    return false;
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return true;
  }
}

extension PasswordValidator on String {
  bool isValidPassword() {
    return true;
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const AppLoader();
    },
  );
}

void printFormData(FormData formData) {
  debugPrint("FormData (fields):");
  if (formData.fields.isEmpty) {
    debugPrint("  <no fields>");
  } else {
    for (final entry in formData.fields) {
      debugPrint("  ${entry.key}: ${entry.value}");
    }
  }

  // If FormData contains files, print their key + filename.
  if (formData.files.isNotEmpty) {
    debugPrint("FormData (files):");
    for (final entry in formData.files) {
      // MultipartFile.filename is the best stable identifier.
      debugPrint("  ${entry.key}: ${entry.value.filename}");
    }
  }
}

int versionToCode(String? version) {
  if (version == null || version.isEmpty) return 0;
  final parts = version.split('.');
  int major = 0;
  int minor = 0;
  int patch = 0;

  if (parts.isNotEmpty) major = int.tryParse(parts[0]) ?? 0;
  if (parts.length > 1) minor = int.tryParse(parts[1]) ?? 0;
  if (parts.length > 2) patch = int.tryParse(parts[2]) ?? 0;

  return major * 10000 + minor * 100 + patch;
}

String convertToAmPm(String time24) {
  try {
    // Parse the "23:00:00" format
    final parsedTime = DateFormat("HH:mm").parse(time24);

    // Convert to "11 PM"
    return DateFormat("h a").format(parsedTime);
  } catch (e) {
    return time24; // fallback
  }
}

/// Converts duration value like "00:00:15" (HH:mm:ss) or "15" to "15 minutes".
String formatDurationToMinutes(String? value) {
  if (value == null || value.trim().isEmpty) return '0 minutes';
  final trimmed = value.trim();
  final parts = trimmed.split(':');
  if (parts.length >= 3) {
    final h = int.tryParse(parts[0].trim()) ?? 0;
    final m = int.tryParse(parts[1].trim()) ?? 0;
    final s = int.tryParse(parts[2].trim()) ?? 0;
    final totalMinutes = (h == 0 && m == 0) ? s : (h * 60 + m + s / 60).round();
    return totalMinutes == 1 ? '1 minute' : '$totalMinutes minutes';
  }
  if (parts.length == 2) {
    final m = int.tryParse(parts[0].trim()) ?? 0;
    final s = int.tryParse(parts[1].trim()) ?? 0;
    final totalMinutes = (m + s / 60).round();
    return totalMinutes == 1 ? '1 minute' : '$totalMinutes minutes';
  }
  final n = int.tryParse(trimmed);
  if (n != null) return n == 1 ? '1 minute' : '$n minutes';
  return trimmed;
}

/// Formats order placed_at (ISO or DateTime) for display.
/// Returns "Feb 07, 2026 10:45 AM" or "Today, 10:45 AM" when same day.
String formatOrderPlacedAt(DateTime? dateTime) {
  if (dateTime == null) return '';
  final now = DateTime.now();
  final isToday =
      dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;
  if (isToday) {
    return 'Today, ${DateFormat('hh:mm a').format(dateTime)}';
  }
  return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
}

String formatRatingCount(int? value) {
  if (value == null) return "0";

  if (value < 1000) {
    return value.toString(); // 1, 999 etc.
  } else if (value < 1000000) {
    // Thousands → 1K, 1.2K, 999K
    double result = value / 1000;
    return "${result.toStringAsFixed(result < 10 ? 1 : 0)}K+";
  } else {
    // Millions → 1M, 1.5M, 10M
    double result = value / 1000000;
    return "${result.toStringAsFixed(result < 10 ? 1 : 0)}M+";
  }
}

/// Calculate bearing (direction) between two GPS coordinates using the haversine formula
///
/// Returns bearing in degrees (0-360), where:
/// - 0° = North
/// - 90° = East
/// - 180° = South
/// - 270° = West
///
/// Formula: bearing = atan2(sin(Δlong) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(Δlong))
///
/// [lat1] Latitude of the starting point in degrees
/// [lon1] Longitude of the starting point in degrees
/// [lat2] Latitude of the destination point in degrees
/// [lon2] Longitude of the destination point in degrees
///
/// Returns bearing in degrees (0-360)
double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
  // Convert degrees to radians
  final lat1Rad = lat1 * math.pi / 180;
  final lat2Rad = lat2 * math.pi / 180;
  final deltaLonRad = (lon2 - lon1) * math.pi / 180;

  // Calculate bearing using haversine formula
  final y = math.sin(deltaLonRad) * math.cos(lat2Rad);
  final x =
      math.cos(lat1Rad) * math.sin(lat2Rad) -
      math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLonRad);

  // Calculate bearing in radians, then convert to degrees
  final bearingRad = math.atan2(y, x);
  final bearingDeg = bearingRad * 180 / math.pi;

  // Normalize to 0-360 range
  return (bearingDeg + 360) % 360;
}

/// Smooth bearing changes to prevent jittery rotation
///
/// Uses interpolation (lerp) to gradually transition between bearings.
/// Handles the 360/0 degree wrap-around case (e.g., transitioning from 350° to 10°
/// should go through 0°, not backwards).
///
/// [currentBearing] The newly calculated bearing in degrees (0-360)
/// [previousBearing] The previous bearing in degrees (0-360)
/// [smoothingFactor] Interpolation factor between 0.0 (no smoothing) and 1.0 (full smoothing)
///                   Default is 0.3 for smooth but responsive rotation
///
/// Returns smoothed bearing in degrees (0-360)
double smoothBearing(
  double currentBearing,
  double previousBearing, {
  double smoothingFactor = 0.3,
}) {
  // Handle wrap-around case (e.g., 350° to 10°)
  double diff = currentBearing - previousBearing;

  // Normalize difference to -180 to 180 range
  if (diff > 180) {
    diff -= 360;
  } else if (diff < -180) {
    diff += 360;
  }

  // Calculate smoothed bearing
  double smoothedBearing = previousBearing + (diff * smoothingFactor);

  // Normalize to 0-360 range
  return (smoothedBearing + 360) % 360;
}

/// Calculate distance between two GPS coordinates using Haversine formula
///
/// Returns distance in meters
///
/// [lat1] Latitude of the first point in degrees
/// [lon1] Longitude of the first point in degrees
/// [lat2] Latitude of the second point in degrees
/// [lon2] Longitude of the second point in degrees
///
/// Returns distance in meters
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // Earth radius in meters

  // Convert degrees to radians
  final lat1Rad = lat1 * math.pi / 180;
  final lat2Rad = lat2 * math.pi / 180;
  final deltaLatRad = (lat2 - lat1) * math.pi / 180;
  final deltaLonRad = (lon2 - lon1) * math.pi / 180;

  // Haversine formula
  final a =
      math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
      math.cos(lat1Rad) *
          math.cos(lat2Rad) *
          math.sin(deltaLonRad / 2) *
          math.sin(deltaLonRad / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadius * c;
}

void showConfirmationBottomSheet({
  required BuildContext context,
  required String title,
  required String message,
  required String leftButtonText,
  required String rightButtonText,
  required VoidCallback onConfirm,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.rubik(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333E63),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE5E5E5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF1EE),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          leftButtonText,
                          style: GoogleFonts.rubik(
                            color: const Color(0xFFFF5216),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5216),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          rightButtonText,
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

String translateOffreToEnglish(String name, String langCode) {
  if (langCode != 'en') return name;
  final trimmed = name.trim();
  final trimmedLower = trimmed.toLowerCase();
  
  // Direct matches
  if (trimmedLower == 'offre') return 'Offer';
  if (trimmedLower == 'offres') return 'Offers';
  if (trimmedLower == 'offre combo' || trimmedLower == 'combo offre') return 'Combo Offer';
  if (trimmedLower == 'offre basic' || trimmedLower == 'basic offre') return 'Basic Offer';
  if (trimmedLower == 'offre premium' || trimmedLower == 'premium offre') return 'Premium Offer';
  
  // Month mappings in French (e.g. "offre 1 mois" -> "1 Month Offer")
  final moisRegex = RegExp(r'^offre\s+(\d+)\s+mois$', caseSensitive: false);
  if (moisRegex.hasMatch(trimmedLower)) {
    final match = moisRegex.firstMatch(trimmedLower);
    final number = match?.group(1);
    if (number != null) {
      return '$number Month Offer';
    }
  }

  // Year mappings in French (e.g. "offre 1 an" -> "1 Year Offer")
  final anRegex = RegExp(r'^offre\s+(\d+)\s+an(s)?$', caseSensitive: false);
  if (anRegex.hasMatch(trimmedLower)) {
    final match = anRegex.firstMatch(trimmedLower);
    final number = match?.group(1);
    if (number != null) {
      return '$number Year Offer';
    }
  }

  // General mappings for prefixes
  if (trimmedLower.startsWith('offre ')) {
    var remainder = trimmed.substring(6).trim();
    // Translate some common French adjectives
    if (remainder.toLowerCase() == 'mensuelle' || remainder.toLowerCase() == 'mensuel') {
      remainder = 'Monthly';
    } else if (remainder.toLowerCase() == 'annuelle' || remainder.toLowerCase() == 'annuel') {
      remainder = 'Annual';
    } else if (remainder.toLowerCase() == 'gratuite' || remainder.toLowerCase() == 'gratuit') {
      remainder = 'Free';
    } else if (remainder.toLowerCase() == "d'essai") {
      remainder = 'Trial';
    } else if (remainder.isNotEmpty) {
      remainder = '${remainder[0].toUpperCase()}${remainder.substring(1)}';
    }
    return '$remainder Offer';
  }
  
  // General mappings for suffixes
  if (trimmedLower.endsWith(' offre')) {
    var remainder = trimmed.substring(0, trimmed.length - 6).trim();
    if (remainder.toLowerCase() == 'mensuelle' || remainder.toLowerCase() == 'mensuel') {
      remainder = 'Monthly';
    } else if (remainder.toLowerCase() == 'annuelle' || remainder.toLowerCase() == 'annuel') {
      remainder = 'Annual';
    } else if (remainder.toLowerCase() == 'gratuite' || remainder.toLowerCase() == 'gratuit') {
      remainder = 'Free';
    } else if (remainder.toLowerCase() == "d'essai") {
      remainder = 'Trial';
    } else if (remainder.isNotEmpty) {
      remainder = '${remainder[0].toUpperCase()}${remainder.substring(1)}';
    }
    return '$remainder Offer';
  }
  
  // Fallback: If it contains "offre" (case-insensitive) but wasn't caught by prefix/suffix,
  // let's replace "offre" with "Offer" and "offres" with "Offers".
  if (trimmedLower.contains('offre')) {
    String replaced = trimmed
      .replaceAll(RegExp(r'\boffres\b', caseSensitive: false), 'Offers')
      .replaceAll(RegExp(r'\boffre\b', caseSensitive: false), 'Offer');
    return replaced;
  }
  
  return name;
}


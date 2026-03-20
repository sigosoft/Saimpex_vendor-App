import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/view/home/home.dart';

import '../../../controller/login_controller.dart';
import '../../../generated/l10n.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.size,
    required this.loginController,
    required this.onLogin,
  });

  final Size size;
  final LoginController loginController;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    S.of(context).welcomeToSaimpexVendor,
                    style: GoogleFonts.rubik(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).pleaseSigninToYourAccountAndStartTheAdventure,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).username,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: loginController.userNameController,
              decoration: InputDecoration(
                hintText: S.of(context).enterYourUsername,
                hintStyle: GoogleFonts.rubik(fontSize: 14, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).password,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: loginController.passwordController,
              obscureText: !loginController.isPasswordVisible,
              decoration: InputDecoration(
                hintText: S.of(context).enterYourPassword,
                hintStyle: GoogleFonts.rubik(fontSize: 14, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    loginController.isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: loginController.togglePasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: size.width,
              height: size.height * 0.065,
              child: ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  S.of(context).login,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthModalSheet extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onUsernamePasswordSignIn;
  final VoidCallback onContinueAsGuest;

  const AuthModalSheet({
    super.key,
    required this.onGoogleSignIn,
    required this.onUsernamePasswordSignIn,
    required this.onContinueAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.iceSheetGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.auroraGradient,
              boxShadow: AppColors.softDropShadow,
            ),
            child: const Icon(
              Icons.ice_skating_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to join the fun!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.glacialBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Access exclusive features, book ice time, and connect with the community',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.mutedText),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGoogleSignIn,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Continue with Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUsernamePasswordSignIn,
              icon: const Icon(Icons.email_rounded),
              label: const Text('Username / Password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.frostPrimaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.frostPrimaryDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onContinueAsGuest,
            child: Text(
              'Continue as Guest',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

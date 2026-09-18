import 'package:flutter/material.dart';
import '../data/app_data.dart';

AppBar buildAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white),
    ),
    centerTitle: true,
    backgroundColor: kBackgroundColor,
    foregroundColor: Colors.white,
    elevation: 0,
    actions: actions,
  );
}

final ButtonStyle kPrimaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: kPrimaryColor,
  foregroundColor: Colors.black,
  padding: const EdgeInsets.symmetric(vertical: 18),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  elevation: 0,
  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
);

InputDecoration buildInputDecoration(String label, {Widget? prefixIcon, Widget? suffixIcon, String? hintText}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: kTextMuted),
    hintText: hintText,
    hintStyle: const TextStyle(color: Colors.white24),
    prefixIcon: prefixIcon != null ? IconTheme(data: const IconThemeData(color: kPrimaryColor), child: prefixIcon) : null,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: kSurfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.white10, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
    ),
  );
}

class ErrorBox extends StatelessWidget {
  final String message;

  const ErrorBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const InfoCard({super.key, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: kTextMuted, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color ?? kPrimaryColor)),
        ],
      ),
    );
  }
}

class VerticalMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const VerticalMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: kPrimaryColor, size: 26),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: kTextMuted)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

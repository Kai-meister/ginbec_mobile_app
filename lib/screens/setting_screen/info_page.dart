import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

class InfoSection {
  final String? heading;
  final String body;
  const InfoSection({this.heading, required this.body});
}

class InfoPage extends StatelessWidget {
  final String title;
  final String? intro;
  final List<InfoSection> sections;
  final String? footer;

  const InfoPage({
    super.key,
    required this.title,
    this.intro,
    required this.sections,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      appBar: AppBar(
        backgroundColor: GColor.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (intro != null) ...[
              Text(
                intro!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],
            for (final s in sections) ...[
              if (s.heading != null) ...[
                Text(
                  s.heading!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GColor.primarycolor,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                s.body,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (footer != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  footer!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
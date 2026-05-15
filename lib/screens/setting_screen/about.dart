import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/setting_screen/info_page.dart';
import 'package:ginbec_mobile_app/widgets/avatar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        title: const Text(
          'អំពី GINBEC',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AvatarWidget(
              imageUrl: 'lib/assets/ginbec_logo.png',
              size: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              'GINBEC',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'អគ្គាធិការដ្ឋានពុទ្ធិកសិក្សាជាតិ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'KhmerOSMoulLightRegular',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'General Inspectorate of National Buddhist Education',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            const _AboutCard(
              children: [
                InfoSection(
                  heading: 'បេសកកម្មរបស់យើង',
                  body:
                      'ដើម្បីគាំទ្រ និងធ្វើអធិការកិច្ចលើគ្រឹះស្ថានពុទ្ធិកសិក្សា '
                      'នៅទូទាំងព្រះរាជាណាចក្រកម្ពុជា ដោយធានាបាននូវការបង្រៀន '
                      'ប្រកបដោយគុណភាព ការការពារបេតិកភណ្ឌសាសនា និងការសិក្សា '
                      'ដែលអាចចូលដល់ ទាំងសម្រាប់ព្រះសង្ឃ និងគ្រហស្ថ។',
                ),
                InfoSection(
                  heading: 'អ្វីដែលយើងធ្វើ',
                  body:
                      '• សម្របសម្រួលកិច្ចប្រជុំ និងការអធិការកិច្ច '
                      'នៅតាមវត្តអារាម និងសាលាពុទ្ធិកសិក្សា។\n'
                      '• គ្រប់គ្រងកាលវិភាគ ឯកសារ និងការជូនដំណឹង '
                      'សម្រាប់បុគ្គលិក និងអធិការ។\n'
                      '• ផ្តល់ជូននូវវេទិកាមជ្ឈិមដ្ឋាន សម្រាប់ការទំនាក់ទំនង '
                      'និងការរាយការណ៍របស់ស្ថាប័ន។',
                ),
                InfoSection(
                  heading: 'ទំនាក់ទំនង',
                  body: 'អ៊ីមែល: info@ginbec.gov.kh\n'
                      'ទូរស័ព្ទ: +855 23 000 000\n'
                      'អាសយដ្ឋាន: ភ្នំពេញ ប្រទេសកម្ពុជា',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'GINBEC Mobile v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            Text(
              '© 2026 GINBEC. រក្សាសិទ្ធិគ្រប់យ៉ាង។',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final List<InfoSection> children;
  const _AboutCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 14),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 14),
            ],
            Text(
              children[i].heading!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: GColor.primarycolor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              children[i].body,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
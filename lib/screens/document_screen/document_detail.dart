import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/models/document.dart';

class DocumentDetail extends StatelessWidget {
  final Document document;
  const DocumentDetail({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ឯកសារ')),
      body: Center(child: Text(document.documentName)),
    );
  }
}
import 'package:dio/dio.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';

class DocumentPage {
  final List<Document> items;
  final int pageNumber;
  final bool last;
  DocumentPage({required this.items, required this.pageNumber, required this.last});
}

class DocumentService {
  DocumentService._();
  static final DocumentService instance = DocumentService._();

  Dio get _dio => ApiClient.instance.dio;

  Future<DocumentPage> list({
    int page = 0,
    int size = 20,
    String? status,
    int? expiringWithin,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      if (status != null) ...{'status': status},
      if (expiringWithin != null) ...{'expiring_within': expiringWithin},
    };
    final res = await _dio.get('/documents', queryParameters: params);
    final body = res.data['data'] as Map<String, dynamic>;
    final content = (body['content'] as List? ?? [])
        .map((e) => Document.fromJson(e as Map<String, dynamic>))
        .toList();
    return DocumentPage(
      items: content,
      pageNumber: body['pageNumber'] as int? ?? page,
      last: body['last'] as bool? ?? true,
    );
  }

  Future<Document> getById(int id) async {
    final res = await _dio.get('/documents/$id');
    return Document.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
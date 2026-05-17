import 'package:dio/dio.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';

class ApprovalService {
  ApprovalService._();
  static final ApprovalService instance = ApprovalService._();

  Dio get _dio => ApiClient.instance.dio;

  /// Finds the most recent pending approval for [documentId].
  /// Returns null if none exists.
  Future<int?> findPendingApprovalIdFor(int documentId) async {
    final res = await _dio.get(
      '/approvals',
      queryParameters: {'status': 'PENDING', 'size': 200, 'page': 0},
    );
    final list = (res.data['data']?['content'] as List? ?? []);
    for (final item in list) {
      if ((item as Map<String, dynamic>)['documentId'] == documentId) {
        return item['approvalId'] as int?;
      }
    }
    return null;
  }

  /// Decides on an approval. [statusCode] is "APPROVED" or "REJECTED".
  Future<void> decide({
    required int approvalId,
    required String statusCode,
    String comment = '',
  }) async {
    await _dio.put(
      '/approvals/$approvalId/decide',
      data: {'statusCode': statusCode, 'comment': comment},
    );
  }
}

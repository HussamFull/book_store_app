import 'dart:io';
import 'package:dio/dio.dart';

class ErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "انتهت مهلة الاتصال بالسيرفر، يرجى التحقق من سرعة الإنترنت.\n(Connection timeout with API server)";

        case DioExceptionType.sendTimeout:
          return "انتهت مهلة إرسال البيانات إلى السيرفر، حاول مرة أخرى.\n(Send timeout in connection with API server)";

        case DioExceptionType.receiveTimeout:
          return "انتهت مهلة استقبال البيانات من السيرفر، حاول لاحقاً.\n(Receive timeout in connection with API server)";

        case DioExceptionType.badCertificate:
          return "شهادة الأمان (SSL) غير صالحة، تعذر تأمين الاتصال.\n(Invalid SSL certificate)";

        case DioExceptionType.badResponse:
          return _handleBadResponse(error.response);

        case DioExceptionType.cancel:
          return "تم إلغاء الطلب.\n(Request to API server was cancelled)";

        case DioExceptionType.connectionError:
          return "لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.\n(No Internet connection)";

        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return "لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.\n(No Internet connection)";
          }
          return "حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.\n(Unexpected error occurred)";
        case DioExceptionType.transformTimeout:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    } else if (error is SocketException) {
      return "لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.\n(No Internet connection)";
    } else if (error is FormatException) {
      return "حدث خطأ في تنسيق البيانات المستلمة من السيرفر.\n(Invalid data format received from server)";
    }

    return "حدث خطأ غير متوقع: ${error.toString()}\n(Unexpected error: ${error.toString()})";
  }

  /// دالة مساعدة لتحليل أخطاء السيرفر (Status Codes) واستخراج رسالة الـ API إن وجدت
  static String _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    // محاولة استخراج رسالة الخطأ القادمة من السيرفر (مثل: "Email already taken")
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] ?? data['error'] ?? data['msg'];
    }

    switch (statusCode) {
      case 400:
        return serverMessage ?? "طلب غير صالح.\n(Bad Request - 400)";
      case 401:
        return serverMessage ??
            "انتهت جلسة الدخول أو غير مصرح لك بالوصول.\n(Unauthorized - 401)";
      case 403:
        return serverMessage ??
            "ليس لديك صلاحية للوصول إلى هذا المحتوى.\n(Forbidden - 403)";
      case 404:
        return serverMessage ??
            "المحتوى المطلوب غير موجود.\n(Not Found - 404)";
      case 422:
        return serverMessage ??
            "البيانات المدخلة غير صحيحة، يرجى مراجعتها.\n(Unprocessable Entity / Validation Error - 422)";
      case 429:
        return "تم إرسال طلبات كثيرة جداً، يرجى الانتظار قليلاً.\n(Too Many Requests - 429)";
      case 500:
        return "خطأ داخلي في السيرفر، حاول لاحقاً.\n(Internal Server Error - 500)";
      case 502:
      case 503:
        return "السيرفر غير متاح حالياً للصيانة، يرجى المحاولة لاحقاً.\n(Service Unavailable - $statusCode)";
      default:
        return serverMessage ??
            "حدث خطأ من السيرفر برمز: $statusCode\n(Received invalid status code: $statusCode)";
    }
  }
}
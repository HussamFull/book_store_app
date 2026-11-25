import 'package:dio/dio.dart';
import 'package:dio_pretty_logger/dio_pretty_logger.dart';

class DioFactory {
  static Dio ? dio;
  static void init() {
  //  if (dio == null) {
      dio = Dio(
        BaseOptions(
         // baseUrl: 'https://api.example.com',
        //  connectTimeout: ,
         /* headers: {
            'Content-Type': 'application/json',
           },*/
         // receiveTimeout: ,
        ),
      );
      dio?.interceptors.add(
        DioPrettyLogger(
  showResponseHeader: true,   // also log response headers
  showRequestBody: false,     // hide request bodies (e.g. to avoid logging passwords)
  maxWidth: 120,              // wider terminal
  maxListPrintLength: 5,      // show at most 5 list items
 // enabled: !kReleaseMode,     // explicit control
)as Interceptor);
  
  }


  
}

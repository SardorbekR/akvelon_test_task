import 'package:akvelon_test_task/rate_limiter_util.dart';

void main() {
  final rateLimiterUtil = RateLimiterUtil();

  ///Here it will send 20 requests in a row,
  ///but since allowed only 10 requests in 30 seconds
  ///it will stop after sending 10 requests until this 30 seconds pass.
  ///when 30 seconds pass, it will send rest of the requests
  for (int i = 1; i <= 20; i++) {
    rateLimiterUtil.throttleRequest(
      request: () {
        print("Sending Request$i...");
      },
      minRequestCount: 1,
      minAllowedRequestTimeMs: 1000,
      maxRequestCount: 10,
      maxAllowedRequestTimeMs: 30000,
    );
  }
}

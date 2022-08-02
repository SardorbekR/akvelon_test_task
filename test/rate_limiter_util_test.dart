import 'package:rate_limiter/rate_limiter_util.dart';
import 'package:test/test.dart';

void main() {
  late RateLimiterUtil rateLimiterUtil;
  late Function request;
  int callCount = 0;

  setUpAll(() {
    rateLimiterUtil = RateLimiterUtil();
    request = () {
      print("Sending Request...");
      callCount++;
    };
  });

  setUp(() {
    callCount = 0;
    RateLimiterUtil.minRequestTimer = 0;
    RateLimiterUtil.minRequestCounter = 0;
    RateLimiterUtil.maxRequestTimer = 0;
    RateLimiterUtil.maxRequestCounter = 0;
  });

  test('Checking if request method called', () {
    rateLimiterUtil.throttleRequest(
      request: request,
    );

    expect(callCount, 1);
  });

  test('check if exceeded requests will be re-requested later', () async {
    ///Attempt to send 2 requests in a row
    for (int i = 1; i <= 2; i++) {
      //Shortest and max interval is: 1 request per 3 second
      rateLimiterUtil.throttleRequest(
        request: request,
        minAllowedRequestTimeMs: 3000,
        minRequestCount: 1,
      );
    }

    await Future.delayed(const Duration(milliseconds: 3100));
    expect(callCount, 2);
  });

  test('At most allowed only 2 requests per minute', () async {
    ///Attempt to send 5 requests in a row
    for (int i = 1; i <= 5; i++) {
      //Shortest interval: 1 request per 0.1 second
      rateLimiterUtil.throttleRequest(
          request: request,
          minRequestCount: 1,
          minAllowedRequestTimeMs: 100,
          maxRequestCount: 2,
          maxAllowedRequestTimeMs: 60000);
    }
    await Future.delayed(const Duration(seconds: 3));
    expect(callCount, 2);
  });
}

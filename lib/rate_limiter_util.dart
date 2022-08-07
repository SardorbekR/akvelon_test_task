import 'dart:async';

///  утилитный класс, который ограничивает доступ к ресурсу по заданным rate limit.
///  Rate limit содержит:
///  timeMs: number - время лимита
///  requestCount - сколько можно отправить запросов за это время
///  Например, [{requestCount: 1, timeMs: 1000}, {requestCount:10, timeMs: 60000}].
///  То есть запросы можно отправлять раз в секунду, но не более 10 в минуту
///  Если лимит достигнут, то запросы не должны пропадать, а просто выполниться позднее.

class RateLimiterUtil {
  static int minRequestTimer = 0;
  static int maxRequestTimer = 0;
  static int minRequestCounter = 0;
  static int maxRequestCounter = 0;
  static Timer? _timer;

  void throttleRequest({
    required Function request,
    minRequestCount = 1,
    minAllowedRequestTimeMs = 1000,
    maxRequestCount = 10,
    maxAllowedRequestTimeMs = 60000,
  }) {
    _startTimer(minAllowedRequestTimeMs, maxAllowedRequestTimeMs);

    ///Check, if amount of requests per minRequestTimeMs exceeded
    if (minRequestCounter >= minRequestCount ||
        maxRequestCounter >= maxRequestCount) {
      _delayExceededRequests(
        request,
        retryInMs: minAllowedRequestTimeMs - minRequestTimer,
        minRequestCount: minRequestCount,
        minAllowedRequestTimeMs: minAllowedRequestTimeMs,
        maxRequestCount: maxRequestCount,
        maxAllowedRequestTimeMs: maxAllowedRequestTimeMs,
      );
      return;
    }

    ///Check, if amount of requests exceeds maxRequests limit
    if (maxRequestCounter < maxRequestCount) {
      request();
      minRequestCounter++;
      maxRequestCounter++;
    }
  }

  void _startTimer(minRequestTimeMs, maxRequestTimeMs) {
    _timer ??= Timer.periodic(
      Duration(milliseconds: 1),
      (_) {
        if (minRequestTimer == minRequestTimeMs) {
          minRequestTimer = 0;
          minRequestCounter = 0;
        }

        if (maxRequestTimer == maxRequestTimeMs) {
          maxRequestTimer = 0;
          maxRequestCounter = 0;
        } else {
          maxRequestTimer++;
          minRequestTimer++;
        }
      },
    );
  }

  void _delayExceededRequests(
    Function request, {
    required int retryInMs,
    minRequestCount = 1,
    minAllowedRequestTimeMs = 1000,
    maxRequestCount = 10,
    maxAllowedRequestTimeMs = 60000,
  }) {
    Future.delayed(
        Duration(milliseconds: retryInMs),
        () => throttleRequest(
              request: request,
              minRequestCount: minRequestCount,
              minAllowedRequestTimeMs: minAllowedRequestTimeMs,
              maxRequestCount: maxRequestCount,
              maxAllowedRequestTimeMs: maxAllowedRequestTimeMs,
            ));
  }
}

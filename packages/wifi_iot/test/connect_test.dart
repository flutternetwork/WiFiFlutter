import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_iot/wifi_iot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('wifi_iot');
  final calls = <MethodCall>[];
  Object? response;
  PlatformException? failure;
  var missingPlugin = false;
  var failPreparation = false;

  setUp(() {
    calls.clear();
    response = {'code': WiFiConnectCode.ok};
    failure = null;
    missingPlugin = false;
    failPreparation = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'isEnabled') {
            if (failPreparation) {
              throw PlatformException(
                code: 'permission_denied',
                message: 'No permission',
              );
            }
            return true;
          }
          if (missingPlugin) throw MissingPluginException();
          if (failure != null) throw failure!;
          return response;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('connectWithResult forwards the complete connection request', () async {
    final result = await WiFiForIoTPlugin.connectWithResult(
      'Device AP',
      bssid: '00:11:22:33:44:55',
      password: 'password123',
      security: NetworkSecurity.WPA,
      joinOnce: false,
      withInternet: true,
      isHidden: true,
      timeoutInSeconds: 12,
    );
    expect(result.isSuccess, isTrue);
    expect(result.nativeCode, isNull);
    expect(result.nativeDomain, isNull);
    expect(result.message, isNull);
    expect(calls.last.method, 'connectWithResult');
    expect(calls.last.arguments, {
      'ssid': 'Device AP',
      'bssid': '00:11:22:33:44:55',
      'password': 'password123',
      'security': 'WPA',
      'join_once': false,
      'with_internet': true,
      'is_hidden': true,
      'timeout_in_seconds': 12,
    });
  });

  test(
    'returns stable Android errors and the original suggestion status',
    () async {
      response = {
        'code': WiFiConnectCode.networkSuggestionAppDisallowed,
        'nativeCode': 2,
        'nativeDomain': 'android.net.wifi.WifiManager',
      };
      final result = await WiFiForIoTPlugin.connectWithResult('Device AP');
      expect(result.isSuccess, isFalse);
      expect(result.code, WiFiConnectCode.networkSuggestionAppDisallowed);
      expect(result.nativeCode, 2);
      expect(result.nativeDomain, 'android.net.wifi.WifiManager');
    },
  );

  test(
    'preserves the iOS NSError code, domain and localized message',
    () async {
      response = {
        'code': WiFiConnectCode.userDenied,
        'nativeCode': 7,
        'nativeDomain': 'NEHotspotConfigurationErrorDomain',
        'message': 'The user declined the request.',
      };
      final result = await WiFiForIoTPlugin.connectWithResult('Device AP');
      expect(result.isSuccess, isFalse);
      expect(result.code, WiFiConnectCode.userDenied);
      expect(result.nativeCode, 7);
      expect(result.nativeDomain, 'NEHotspotConfigurationErrorDomain');
      expect(result.message, 'The user declined the request.');
    },
  );

  test(
    'connectionUnavailable does not invent an authentication error',
    () async {
      response = {'code': WiFiConnectCode.connectionUnavailable};
      final result = await WiFiForIoTPlugin.connectWithResult('Device AP');
      expect(result.code, WiFiConnectCode.connectionUnavailable);
      expect(result.isSuccess, isFalse);
      expect(result.nativeCode, isNull);
    },
  );

  test(
    'rejects empty and oversized UTF-8 SSIDs before invoking the platform',
    () async {
      for (final ssid in ['', 'a' * 33, '界' * 11]) {
        final result = await WiFiForIoTPlugin.connectWithResult(ssid);
        expect(result.code, WiFiConnectCode.invalidSsid);
      }
      expect(calls, isEmpty);
    },
  );

  test('accepts an SSID at the UTF-8 byte limit', () async {
    final result = await WiFiForIoTPlugin.connectWithResult('界' * 10 + 'ab');
    expect(result.isSuccess, isTrue);
    expect(calls.last.method, 'connectWithResult');
  });

  test('rejects missing passwords and invalid timeout values', () async {
    final missingPassword = await WiFiForIoTPlugin.connectWithResult(
      'Device AP',
      security: NetworkSecurity.WPA,
    );
    expect(missingPassword.code, WiFiConnectCode.invalidConfiguration);
    for (final timeout in [0, -1, 2147484]) {
      final result = await WiFiForIoTPlugin.connectWithResult(
        'Device AP',
        timeoutInSeconds: timeout,
      );
      expect(result.code, WiFiConnectCode.invalidConfiguration);
    }
    expect(calls, isEmpty);
  });

  test(
    'reports null or incomplete native results as unknown failures',
    () async {
      for (final value in [null, <String, Object>{}]) {
        response = value;
        final result = await WiFiForIoTPlugin.connectWithResult('Device AP');
        expect(result.code, WiFiConnectCode.unknown);
        expect(result.isSuccess, isFalse);
      }
    },
  );

  test(
    'reports a missing native method without changing the old API',
    () async {
      missingPlugin = true;
      final result = await WiFiForIoTPlugin.connectWithResult('Device AP');
      expect(result.code, WiFiConnectCode.missingPlugin);
      expect(result.isSuccess, isFalse);
    },
  );

  test(
    'preserves platform exception code and message in the new API',
    () async {
      failure = PlatformException(
        code: 'native_error',
        message: 'Native details',
      );
      final result = await WiFiForIoTPlugin.connectWithResult('Device AP');
      expect(result.code, WiFiConnectCode.platformError);
      expect(result.nativeCode, 'native_error');
      expect(result.message, 'Native details');
    },
  );

  test('captures failures while preparing the Wi-Fi adapter', () async {
    failPreparation = true;
    final result = await WiFiForIoTPlugin.connectWithResult('Device AP');
    expect(result.code, WiFiConnectCode.platformError);
    expect(result.nativeCode, 'permission_denied');
    expect(calls.map((call) => call.method), ['isEnabled']);
  });

  test(
    'connect and findAndConnect retain their boolean channel contracts',
    () async {
      for (final value in [true, false]) {
        response = value;
        final Future<bool> connect = WiFiForIoTPlugin.connect('Device AP');
        expect(await connect, value);
        expect(calls.last.method, 'connect');
        // ignore: deprecated_member_use
        final Future<bool> find = WiFiForIoTPlugin.findAndConnect('Device AP');
        expect(await find, value);
        expect(calls.last.method, 'findAndConnect');
      }
    },
  );

  test(
    'the existing connect API still propagates platform exceptions',
    () async {
      failure = PlatformException(
        code: 'Error',
        message: 'Invalid BSSID representation',
      );
      await expectLater(
        WiFiForIoTPlugin.connect('Device AP'),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'Error',
          ),
        ),
      );
    },
  );
}

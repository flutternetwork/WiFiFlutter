import 'package:wifi_scan/wifi_scan.dart';

extension ToEnumExtension on int {
  toCanStartScan() => CanStartScan.values[this];

  toCanGetScannedNetworks() => CanGetScannedNetworks.values[this];
}

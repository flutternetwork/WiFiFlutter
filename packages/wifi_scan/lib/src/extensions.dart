import 'package:wifi_scan/wifi_scan.dart';

extension ToEnumExtension on int{
  toCanRequestScan()=> CanRequestScan.values[this];

  toCanGetScannedNetworks() => CanGetScannedNetworks.values[this];
}
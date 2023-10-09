import 'dart:async';
import 'dart:math';
import 'dart:typed_data';


import 'package:get/get.dart';
import 'dart:io';

import 'package:usb_serial/usb_serial.dart';

class ServerController extends GetxController {
  final data = "".obs;
  final selected = "".obs;
  List<UsbDevice> devices = <UsbDevice>[];

  late HttpServer server;
  late UsbPort? port;
  

  bool serverInitiated = false;

  @override
  void onInit() {
    super.onInit();
    startServer();
    Timer.periodic(Duration(seconds: 5), (timer) {
      refreshDevices();
    });

  }

  void refreshDevices() async {
    devices = await UsbSerial.listDevices();
    refresh();

    if (devices.isNotEmpty) {
      selected.value = devices[0].deviceName;
      bool connected=await isConnected();
      if(!connected){  
        connectPort();
      }
    }else{
      selected.value = "No Devices avialable";
    }
    refresh();
  }

  Future<bool> isConnected()async{
    if(serverInitiated){
        try {
          String data = "\r\n";
          await port!.write(Uint8List.fromList(data.codeUnits));
          return true;
        } catch (e) {
          return false;
        }
    }
    return false;
  }

  void connectPort() async {
    try {
      if (devices.isNotEmpty) {
        if(serverInitiated){
          port!.close();
        }
        port = await devices[0].create();
        if (port != null) {
          port?.setPortParameters(9600, 8, 1, UsbPort.PARITY_NONE);
          bool openResult = await port!.open();
          if (openResult) {
            serverInitiated=true;
            port?.inputStream?.listen((_data) {
              data.value = String.fromCharCodes(_data);
            });

          } else {
            data.value = "Failed to open";
            return;
          }
        }
      } else {
        data.value = "no port found";
      }
    } catch (e) {
      data.value = "error:$e";
    }
  }

  void startServer() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    server.forEach((HttpRequest request) {
      request.response.headers.add(HttpHeaders.accessControlAllowHeadersHeader,'*');
      request.response.headers.add(HttpHeaders.accessControlAllowMethodsHeader,'*');
      request.response.headers.add(HttpHeaders.accessControlAllowOriginHeader,'*');
      request.response.write(data.value);
      request.response.close();
    });
  }
}

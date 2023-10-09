import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usb_serial/usb_serial.dart';

import 'controllers/server_controller.dart';

void main() {
  runApp(GetMaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ServerController serverController = Get.put(ServerController());
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KataConnect')),
      body: Column(children: [
        Obx(() => Text(serverController.selected.value)),
        TextButton(
            onPressed: () {
              serverController.refreshDevices();
            },
            child: Text("List Devices")),
        TextButton(
            onPressed: () {
              serverController.connectPort();
            },
            child: Text('Connect Server')),
        Obx(() => Text(serverController.data.value)),
      ]),
    );
  }
}

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'printer_styles.dart';
export './printer_styles.dart';

class PrinterModuleBixolon {
  static const MethodChannel _channel =
  const MethodChannel('printer_module_bixolon');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future create() async {
    if(Platform.isAndroid){
      await _channel.invokeMethod('create');
    } else if(Platform.isIOS){

    }
  }

//-Testing for new method to connect printer---------------------------------------------
  static Future<PrinterModuleBixolon> connectWifi({String ipAddress}) async {
    Map params = <String, dynamic>{
      "ipAddress" : ipAddress
    };
    return await _channel.invokeMethod('connectWifiPrinter', params);
  }

  void println(
    String text, {
      PrinterStyles styles = const PrinterStyles(),
    }
  ) async {
    
    String align;
    String attribute;
    int textSize;
    int lineFeed;

    //-Text Alignment--------------------------------------------------------------------
    if(styles.align == PrinterAlign.left){
      align = 'L';
    } else if(styles.align == PrinterAlign.center){
      align = 'C';
    } else if(styles.align == PrinterAlign.right){
      align = 'R';
    }

    //-Text Attribute--------------------------------------------------------------------
    if(styles.attribute == PrinterAttribute.normal){
      attribute = 'N';
    } else if(styles.attribute == PrinterAttribute.bold){
      attribute = 'B';
    } else if(styles.attribute == PrinterAttribute.reverse){
      attribute = 'R';
    } else if(styles.attribute == PrinterAttribute.underline){
      attribute = 'U';
    }

    //-Text Size-------------------------------------------------------------------------
    if(styles.size == TextSize.size1){
      textSize = 1;
    } else if(styles.size == TextSize.size2){
      textSize = 2;
    } else if(styles.size == TextSize.size3){
      textSize = 3;
    } else if(styles.size == TextSize.size4){
      textSize = 4;
    }

    //-Line Feed-------------------------------------------------------------------------
    if(styles.feed == LineFeed.feed1){
      lineFeed = 1;
    } else if(styles.feed == LineFeed.feed2){
      lineFeed = 2;
    } else if(styles.feed == LineFeed.feed3){
      lineFeed = 3;
    }

    Map params = <String, dynamic>{
      "text" : text,
      "align" : align,
      "attribute" : attribute,
      "textSize" : textSize,
      "lineFeed" : lineFeed
    };

    await _channel.invokeMethod('printText', params);
  }

  void cutPaper() async {
    await _channel.invokeMethod('cutPaper');
  }


//-End of testing new method-------------------------------------------------------------






  static Future<String> connectWifiPrinter({String ipAddress}) async {
    Map params = <String, dynamic>{
      "ipAddress" : ipAddress
    };
    String result =await _channel.invokeMethod('connectWifiPrinter', params).catchError((e){
      print(e.toString());
    });
    return result;
  }

  static Future<String> connectBluetoothPrinter({String param}) async {
    Map parameter = <String, dynamic>{
      "deviceName" : param
    };

    String result =  await _channel.invokeMethod('connectBluetoothPrinter', parameter).catchError((e){
      print(e.toString());
    });
    return result;
  }

  static Future<String> connectBluetoothAndPrint({String param, String text}) async {
    Map parameter = <String, dynamic>{
      "deviceName" : param,
      "textToPrint" : text
    };

    String result =  await _channel.invokeMethod('connectBluetoothAndPrint', parameter).catchError((e){
      print(e.toString());
    });
    return result;
  }

  static Future<String> connectWifiAndPrint({String ipAddress, String text}) async {
    Map params = <String, dynamic>{
      "ipAddress" : ipAddress,
      "textToPrint" : text
    };
    String result =await _channel.invokeMethod('connectWifiAndPrint', params).catchError((e){
      print(e.toString());
    });
    return result;
  }

  static Future disconnectPrinter() async {
    await _channel.invokeMethod('disconnect');
  }

  static Future checkStatus() async {
    if(Platform.isAndroid) {
      String status;
      final bool stats = await _channel.invokeMethod('checkStatus');
      status = stats.toString();
      return status;
    }
  }

  static Future printToBixolon({String text}) async {
    //-Create map for method print---------------------------------------------
    Map params = <String, dynamic>{
      "text" : text
    };
    await _channel.invokeMethod('print', params);
  }
}
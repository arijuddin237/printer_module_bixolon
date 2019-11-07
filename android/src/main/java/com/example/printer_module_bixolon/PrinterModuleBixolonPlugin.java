package com.example.printer_module_bixolon;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.bixolon.printer.BixolonPrinter;

import java.util.Map;
import java.util.Set;

/** PrinterModuleBixolonPlugin */
public class PrinterModuleBixolonPlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener {
  /** Plugin registration. */
  public Result result;
  private static String deviceName;
  private static String deviceAddress;
  private static String deviceIpAddress;
  private static boolean status = false;
  private static BixolonPrinter bixolonPrinter;
  private static boolean connectAndPrint = false;
  private static String textParameter = "";

  static final Integer REQUEST_CODE_SELECT_FIRMWARE = Integer.MAX_VALUE;
  static final Integer RESULT_CODE_SELECT_FIRMWARE = Integer.MAX_VALUE - 1;
  static final Integer MESSAGE_START_WORK = Integer.MAX_VALUE - 2;
  static final Integer MESSAGE_END_WORK = Integer.MAX_VALUE - 3;

  static final String FIRMWARE_FILE_NAME = "FirmwareFileName";
  private Map<String, Object> arguments;
  private Object styles;

  public static Context context;

  public static void registerWith(Registrar registrar) {
    context = registrar.context();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "printer_module_bixolon");
    channel.setMethodCallHandler(new PrinterModuleBixolonPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    //-Initialize Printer---------------------------------------------------------------------------
    if(call.method.equals("create")){
      create();

    //-Connect Wifi Printer-------------------------------------------------------------------------
    } else if(call.method.equals("connectWifiPrinter")){
      if(!(call.arguments instanceof Map)){
        throw new IllegalArgumentException("Plugin not passing a Map as parameter");
      }
      arguments = (Map<String, Object>) call.arguments;
      findWifiPrinter((String) arguments.get("ipAddress"));

    //-Connect Bluetooth Printer--------------------------------------------------------------------
    } else if(call.method.equals("connectBluetoothPrinter")){
      if(!(call.arguments instanceof Map)){
        throw new IllegalArgumentException("Plugin not passing a Map as parameter");
      }
      arguments = (Map<String, Object>) call.arguments;
      findBluetoothPrinter((String) arguments.get("deviceName"));

    //-Connect Bluetooth printer and Print text-----------------------------------------------------
    } else if(call.method.equals("connectBluetoothAndPrint")){
      if(!(call.arguments instanceof Map)){
        throw new IllegalArgumentException("Plugin not passing a Map as parameter");
      }
      arguments = (Map<String, Object>) call.arguments;
      connectAndPrint = true;
      textParameter = (String) arguments.get("textToPrint");
      findBluetoothPrinter((String) arguments.get("deviceName"));

    //-Connect Wifi Printer and Print text----------------------------------------------------------
    } else if(call.method.equals("connectWifiAndPrint")){
      if(!(call.arguments instanceof Map)){
        throw new IllegalArgumentException("Plugin not passing a Map as parameter");
      }
      arguments = (Map<String, Object>) call.arguments;
      connectAndPrint = true;
      textParameter = (String) arguments.get("textToPrint");
      findWifiPrinter((String) arguments.get("ipAddress"));

    //-Check Status Connection----------------------------------------------------------------------
    } else if(call.method.equals("checkStatus")){
      checkStatus(result);

    //-Print Text-----------------------------------------------------------------------------------
    } else if(call.method.equals("print")){
      if(!(call.arguments instanceof Map)){
        throw new IllegalArgumentException("Plugin not passing a Map as parameter");
      }
      arguments = (Map<String, Object>) call.arguments;
      //printText((String) arguments.get("text"));

    //-Disconnect printer---------------------------------------------------------------------------
    } else if(call.method.equals("disconnect")) {
      disconnect();

    //-Test print using new method------------------------------------------------------------------
    } else if(call.method.equals("printText")){
      if(!(call.arguments instanceof Map)){
        throw new IllegalArgumentException("Plugin not passing a Map as parameter");
      }
      arguments = (Map<String, Object>) call.arguments;
      printNew(
              (String) arguments.get("text"),
              (String) arguments.get("align"),
              (String) arguments.get("attribute"),
              (Integer) arguments.get("textSize"),
              (Integer) arguments.get("lineFeed")
      );
    } else if(call.method.equals("cutPaper")){
      cutPaper();
    }
  }

  private void create() {
    bixolonPrinter = new BixolonPrinter(context, handler, null);
    bixolonPrinter.initialize();
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
      if (requestCode == REQUEST_CODE_SELECT_FIRMWARE && resultCode == RESULT_CODE_SELECT_FIRMWARE) {
          final String binaryFilePath = data.getStringExtra(FIRMWARE_FILE_NAME);
          handler.obtainMessage(MESSAGE_START_WORK).sendToTarget();
          new Thread(new Runnable() {
              public void run() {
                  bixolonPrinter.updateFirmware(binaryFilePath);
                  try {
                      Thread.sleep(5000);
                  } catch (InterruptedException e) {
                      e.printStackTrace();
                  }
                  handler.obtainMessage(MESSAGE_END_WORK).sendToTarget();
              }
          }).start();
      } else {
          return false;
      }
      return false;
  }

  private final Handler handler = new Handler(new Handler.Callback() {
    @Override
    public boolean handleMessage(Message message) {
      Log.d("bixolon", "mHandler.handleMessage(" + message + ")");
      switch (message.what) {

        //-Handler connect bluetooth printer--------------------------------------------------------
        case BixolonPrinter.MESSAGE_BLUETOOTH_DEVICE_SET:
          Set<BluetoothDevice> bluetoothDeviceSet = (Set<BluetoothDevice>) message.obj;
          for (BluetoothDevice device : bluetoothDeviceSet) {
            if (device.getName().equals(deviceName)) {
              deviceAddress = device.getAddress();
              bixolonPrinter.connect(deviceAddress);
              break;
            } else {
                handler.obtainMessage(11, "Bluetooth printer : "+deviceName+" not found").sendToTarget();
            }
          }
          break;

        //-Handler connect network printer----------------------------------------------------------
        case BixolonPrinter.MESSAGE_NETWORK_DEVICE_SET:
          if (message.obj != null) {
            Set<String> ipAddressSet = (Set<String>) message.obj;
            for (String ipAddress : ipAddressSet) {
              if (ipAddress.equals(deviceIpAddress)) {
                Log.d("ipAddress", ipAddress);
                try {
                  bixolonPrinter.connect(deviceIpAddress, 9100, 5000);
                } catch (Exception e) {
                  Log.e("test", "error connection");
                  e.printStackTrace();
                }
                break;
              } else {
                handler.obtainMessage(11, "Error: Connection Time Out").sendToTarget();
              }
            }
          } else {
              handler.obtainMessage(11, "Error connect to: "+deviceIpAddress).sendToTarget();
          }
          break;

        //-Handler State Change---------------------------------------------------------------------
        case BixolonPrinter.MESSAGE_STATE_CHANGE:
          switch (message.arg1) {
            case BixolonPrinter.STATE_CONNECTING:
              Log.d("bixolon", "Connecting");
              break;
            case BixolonPrinter.STATE_CONNECTED:
              Log.d("bixolon", "Connected");
              Toast.makeText(context, "Connected", Toast.LENGTH_LONG).show();
              status = true;
              if(connectAndPrint){
                //printText(textParameter);
              }
              break;
            case BixolonPrinter.STATE_NONE:
              Log.d("bixolon", "None");
              status = false;
              break;
          }
          break;
        case BixolonPrinter.MESSAGE_DEVICE_NAME:
          break;
        case BixolonPrinter.MESSAGE_TOAST:
          break;
        case 11:
          Toast.makeText(context, "Error "+message.obj.toString(), Toast.LENGTH_LONG).show();
          break;
      }
      return true;
    }
  });


  private void findWifiPrinter(String ipAddress) {
    deviceIpAddress = ipAddress;
    bixolonPrinter.findNetworkPrinters(5000);
  }

  private void findBluetoothPrinter(String name){
    deviceName = name;
    bixolonPrinter.findBluetoothPrinters();
  }

  private void disconnect(){
    bixolonPrinter.disconnect();
  }

  private void checkStatus(final Result result) {
    result.success(status);
    bixolonPrinter.getStatus();
  }

  private void printNew(String text, String align, String attribute, Integer textSize, Integer lineFeed){
    Integer attributeSetting = 0, attributeAlignment = 0, attributeSize = 0;

    //-Text Attribute-------------------------------------------------------------------------------
    if(attribute.charAt(0) == 'B'){ //-Bold
      attributeSetting = BixolonPrinter.TEXT_ATTRIBUTE_EMPHASIZED;
    } else if(attribute.charAt(0) == 'R'){ //-Reverse
      attributeSetting = BixolonPrinter.TEXT_ATTRIBUTE_REVERSE;
    } else if(attribute.charAt(0) == 'U'){ //-Underline
      attributeSetting = BixolonPrinter.TEXT_ATTRIBUTE_UNDERLINE1;
    } else {
      attributeSetting = BixolonPrinter.TEXT_ATTRIBUTE_FONT_A;
    }

    //-Text Alignment-------------------------------------------------------------------------------
    if(align.charAt(0) == 'L'){ //-Left
      attributeAlignment = BixolonPrinter.ALIGNMENT_LEFT;
    } else if(align.charAt(0) == 'C'){ //-Center
      attributeAlignment = BixolonPrinter.ALIGNMENT_CENTER;
    } else if(align.charAt(0) == 'R'){ //-Right
      attributeAlignment = BixolonPrinter.ALIGNMENT_RIGHT;
    }

    //-Text Size------------------------------------------------------------------------------------
    if(textSize == 1){
      attributeSize = BixolonPrinter.TEXT_SIZE_HORIZONTAL1;
      attributeSize |= BixolonPrinter.TEXT_SIZE_VERTICAL1;
    } else if(textSize == 2){
      attributeSize = BixolonPrinter.TEXT_SIZE_HORIZONTAL2;
      attributeSize |= BixolonPrinter.TEXT_SIZE_VERTICAL2;
    } else if(textSize == 3){
      attributeSize = BixolonPrinter.TEXT_SIZE_HORIZONTAL3;
      attributeSize |= BixolonPrinter.TEXT_SIZE_VERTICAL3;
    } else if(textSize == 4){
      attributeSize = BixolonPrinter.TEXT_SIZE_HORIZONTAL4;
      attributeSize |= BixolonPrinter.TEXT_SIZE_VERTICAL4;
    }
    bixolonPrinter.printText(text, attributeAlignment, attributeSetting, attributeSize, true);
    bixolonPrinter.lineFeed(lineFeed, true);
  }

  //-Cut Paper--------------------------------------------------------------------------------------
  private void cutPaper(){
    bixolonPrinter.lineFeed(4, true);
    bixolonPrinter.cutPaper(true);
  }

  /*public void printText(String text) {
    char alignment, attribute, fontSize, lineFeed;
    String tempText;
    Integer attributeSetting = 0, attributeAlignment = 0, attributeSize = 0;
    String[] textList = text.split("/n");
    int countLine = textList.length;

    for (int line = 0; line <countLine; line++) {
      tempText = textList[line];

      attribute = Character.toUpperCase(tempText.charAt(0));
      if (attribute == 'E') { //Bold
        attributeSetting = BixolonPrinter.TEXT_ATTRIBUTE_EMPHASIZED;
      } else if (attribute == 'B') { //Highlight
        attributeSetting = BixolonPrinter.TEXT_ATTRIBUTE_REVERSE;
      }

      alignment = Character.toUpperCase(tempText.charAt(2));
      if (alignment == 'L') {
        attributeAlignment = BixolonPrinter.ALIGNMENT_LEFT;
      } else if (alignment == 'C' || alignment == 'M') {
        attributeAlignment = BixolonPrinter.ALIGNMENT_CENTER;
      } else if (alignment == 'R') {
        attributeAlignment = BixolonPrinter.ALIGNMENT_RIGHT;
      }

      fontSize = Character.toUpperCase(tempText.charAt(4));
      if (fontSize == '1') {
        attributeSize = BixolonPrinter.TEXT_SIZE_HORIZONTAL1;
        attributeSize |= BixolonPrinter.TEXT_SIZE_VERTICAL1;
      } else if (fontSize == '2') {
        attributeSize = BixolonPrinter.TEXT_SIZE_HORIZONTAL2;
        attributeSize |= BixolonPrinter.TEXT_SIZE_VERTICAL2;
      } else if (fontSize == '3') {
        attributeSize = BixolonPrinter.TEXT_SIZE_HORIZONTAL3;
        attributeSize |= BixolonPrinter.TEXT_SIZE_VERTICAL3;
      } else if (fontSize == '4') {
        attributeSize = BixolonPrinter.TEXT_SIZE_HORIZONTAL4;
        attributeSize |= BixolonPrinter.TEXT_SIZE_VERTICAL4;
      }

      lineFeed = Character.toUpperCase(tempText.charAt(6));
      int lineSpace = 1;
      if(lineFeed == '1'){
        lineSpace = 1;
      } else if (lineFeed == '2'){
        lineSpace = 2;
      }

      String textToPrint = tempText.substring(7);

      bixolonPrinter.printText(textToPrint, attributeAlignment, attributeSetting, attributeSize, true);
      bixolonPrinter.lineFeed(lineSpace, true);
      connectAndPrint = false;
      textParameter = "";
    }
    bixolonPrinter.lineFeed(4, true);
    bixolonPrinter.cutPaper(true);
  }*/
}

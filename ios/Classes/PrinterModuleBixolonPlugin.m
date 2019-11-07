#import "PrinterModuleBixolonPlugin.h"

@implementation PrinterModuleBixolonPlugin

NSDictionary *arguments;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"printer_module_bixolon"
            binaryMessenger:[registrar messenger]];
  PrinterModuleBixolonPlugin* instance = [[PrinterModuleBixolonPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        [self getPlatform: result];
        
    //-initialize printer--------------------------------------------------------
    } else if ([@"create" isEqualToString:call.method]) {
        [self initializePrinter];
        
    //-connect wifi printer------------------------------------------------------
    } else if ([@"connectWifiPrinter" isEqualToString:call.method]){
        if(![call.arguments isKindOfClass:[NSDictionary class]]){
            NSLog(@"plugin not passing a map as parameter");
        }
        arguments = call.arguments;
        const char *ipAddressAsChar = [arguments[@"ipAddress"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
        [self bridge_addPrinterToList:"SRP-350plusIII" LogicName:"bixolonPrinter" Type:2 Address:ipAddressAsChar Port:9100];
    
    //-connect bluetooth printer-------------------------------------------------
    } else if ([@"connectBluetoothPrinter" isEqualToString:call.method]){
        if(![call.arguments isKindOfClass:[NSDictionary class]]){
            NSLog(@"Plugin not passing a map as parameter");
        }
        arguments = call.arguments;
        const char *bdAddress = [arguments[@"bdAddress"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
        [self bridge_addPrinterToList:"SPP-R310" LogicName:"bixolonPrinter" Type:0 Address:bdAddress Port:0];
        
    //-Print text----------------------------------------------------------------
    } else if ([@"doPrintText" isEqualToString:call.method]){
        if(![call.arguments isKindOfClass:[NSDictionary class]]){
            NSLog(@"Plugin not passing a map as parameter");
        }
        arguments = call.arguments;
        const char *textToPrint = [arguments[@"data"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
        [self bridge_doPrintText:textToPrint];
    
    //-Disconnect printer---------------------------------------------------------
    } else if([@"disconnect" isEqualToString:call.method]){
        [self bridge_disconnectPrinter];
        
    //-Check status---------------------------------------------------------------
    } else if([@"checkStatus" isEqualToString:call.method]){
        [self bridge_checkStatus:result];
    
    } else if([@"cutPaper" isEqualToString:call.method]){
        [self bridge_cutPaper];
    } else if([@"printText" isEqualToString:call.method]){
        if(![call.arguments isKindOfClass:[NSDictionary class]]){
            NSLog(@"Plugin not passing a map as parameter");
        }
        int textSizeInt, lineFeedInt;
        
        arguments = call.arguments;
        const char *text = [arguments[@"text"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
        const char *align = [arguments[@"align"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
        const char *attribute = [arguments[@"attribute"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
        NSString *textSize = [NSString stringWithUTF8String:[arguments[@"textSize"] cStringUsingEncoding:[NSString defaultCStringEncoding]]];
        textSizeInt = [textSize intValue];
        
        NSString *lineFeed = [NSString stringWithUTF8String:[arguments[@"lineFeed"] cStringUsingEncoding:[NSString defaultCStringEncoding]]];
        lineFeedInt = [lineFeed intValue];
        
        [self bridge_printText:text Align:align Attribute:attribute TextSize:textSizeInt LineFeed:lineFeedInt];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void) getPlatform :(FlutterResult) result{
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
}

- (void) initializePrinter {
    [PrinterFunction initializePrinter];
}

- (void) bridge_addPrinterToList:(const char *)modelName LogicName:(const char *)logicName Type:(int)type Address:(const char *)address Port:(int)port {
    
    [PrinterFunction addPrinterToList:modelName LogicName:logicName Type:type Address:address Port:port];
}

- (void) bridge_disconnectPrinter {
    [PrinterFunction disconnectPrinter];
}

- (void) bridge_checkStatus :(FlutterResult) result{
    result([PrinterFunction checkStatus]);
}

- (void) bridge_doPrintText:(const char *)data{
    [PrinterFunction doPrintText:data];
}

- (void) bridge_cutPaper {
    [PrinterFunction cutPaper];
}

- (void) bridge_printText:(const char *)text Align:(const char *)align
                Attribute:(const char *)attribute TextSize:(int)textSize
                 LineFeed:(int)lineFeed {
    [PrinterFunction printText:text Align:align Attribute:attribute TextSize:textSize LineFeed:lineFeed];
}

@end

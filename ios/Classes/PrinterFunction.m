//
//  PrinterFunction.m
//  printer_module_bixolon
//
//  Created by Bernard Ho on 9/18/19.
//

#import "PrinterFunction.h"
#import "UPOSPrinterController.h"

@interface PrinterFunction ()

@end

@implementation PrinterFunction

UPOSPrinters *deviceList;
UPOSPrinterController *printerController;
long uposResult;
NSString *statusConnection = @"Disconnected";

+ (void) initializePrinter {
    printerController = [UPOSPrinterController new];
    [printerController setLogLevel:LOG_SHOW_NEVER];
    //printerController.delegate = self;
    [printerController setTextEncoding:NSASCIIStringEncoding];
    printerController.CharacterSet = 437;
    
    deviceList = (UPOSPrinters *)[printerController getRegisteredDevice];
    while ([deviceList getList].count) {
        [deviceList removeDevice:[[deviceList getList] lastObject]];
    }
    NSLog(@"initialize printer");
}

+ (void) addPrinterToList:(const char *)modelName LogicName:(const char *)logicName Type:(int)type Address:(const char *)address Port:(int)port {
    UPOSPrinter *newDevice = [[UPOSPrinter alloc] init];
    //UPOSPrinter *newDevice = [[UPOSPrinter alloc] init];
    NSLog(@"address = %s", address);
    
    newDevice.modelName = [NSString stringWithFormat:@"%s", modelName];
    newDevice.ldn = [NSString stringWithFormat:@"%s", logicName];
    
    if (type == 0) {
        newDevice.interfaceType = [NSNumber numberWithInt:_INTERFACETYPE_BLUETOOTH];
    } else if (type == 1){
        newDevice.interfaceType = [NSNumber numberWithInt:_INTERFACETYPE_ETHERNET];
    } else if (type == 2){
        newDevice.interfaceType = [NSNumber numberWithInt:_INTERFACETYPE_WIFI];
    }
    
    newDevice.address = [NSString stringWithFormat:@"%s", address];
    if (port == 0) {
        newDevice.port = @"";
    } else {
        newDevice.port = [NSString stringWithFormat:@"%d", port];
    }
    
    //-Check if printer already in list------------------------------------------
    if([[deviceList getList] count] > 0){
        const char *deviceName = [newDevice.ldn cStringUsingEncoding:[NSString defaultCStringEncoding]];
        [self connectPrinter:deviceName];
    } else {
        [self addPrinter:newDevice];
    }
}

+ (void) addPrinter:(UPOSPrinter *)printer {
    [deviceList addDevice:printer];
    [deviceList save];
    
    NSArray *listDevicePrinter;
    listDevicePrinter = [deviceList getList];
    NSString *deviceListName = [listDevicePrinter componentsJoinedByString:@" "];
    NSLog(@"test %@",deviceListName);
    
    NSLog(@"list printer = %lu", [listDevicePrinter count]);
    
    //const char *ipAddressAsChar = [arguments[@"ipAddress"] cStringUsingEncoding:[NSString defaultCStringEncoding]];  ]
    const char *deviceName = [printer.ldn cStringUsingEncoding:[NSString defaultCStringEncoding]];
    NSLog(@"Element 0 = %@", [[listDevicePrinter objectAtIndex:0] ldn]);
    [self connectPrinter:deviceName];
}

+ (void) connectPrinter:(const char *)printerName {
    uposResult = [printerController connect:[NSString stringWithFormat:@"%s", printerName]];
    NSLog(@"%ld", uposResult);
    NSLog(@"%s", printerName);
    
    NSArray *listDevice;
    listDevice = [deviceList getPairedDevices];

    NSLog(@"device list = %lu", [listDevice count]);
    
    if (uposResult == UPOS_SUCCESS){
        statusConnection = @"Connected";
        NSLog(@"Connected");
    } else {
        statusConnection = @"Connecting Failed";
        NSLog(@"Connecting Failed!");
    }
}

+ (void) disconnectPrinter {
    statusConnection = @"Disconnected";
    NSLog(@"Disconnected");
    [printerController close];
}

+ (NSString *) checkStatus {
    return statusConnection;
}

+ (void) printText:(const char *)text Align:(const char *)align Attribute:(const char *)attribute TextSize:(int)textSize LineFeed:(int)lineFeed {
    NSString *ESC = @"\x1B";
    NSString *formatText = @"";
    NSString *line = @"";
    NSString *stringAttribute = [NSString stringWithUTF8String:attribute];
    NSString *stringAlign = [NSString stringWithUTF8String:align];
    NSString *stringText = [NSString stringWithUTF8String:text];
    char alignmentChar, attributeChar;
    
    alignmentChar = [[stringAlign uppercaseString]characterAtIndex:0];
    attributeChar = [[stringAttribute uppercaseString]characterAtIndex:0];
    
    if(attributeChar == 'B'){
        formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|bC", ESC]];
    } else if(attributeChar == 'R'){
        formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|rvC", ESC]];
    }
    
    if(alignmentChar == 'L'){
        formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|N", ESC]];
    } else if(alignmentChar == 'C'){
        formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|cA", ESC]];
    } else if(alignmentChar == 'R'){
        formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|rA", ESC]];
    }
    
    if(textSize == 1){
        formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|1C", ESC]];
    } else if(textSize == 2){
        formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|2C", ESC]];
    } else if(textSize == 3){
        formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|3C", ESC]];
    } else if(textSize == 4){
        formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|4C", ESC]];
    }
    
    if(lineFeed == 1){
        line = @"\n";
    } else if(lineFeed == 2){
        line = @"\n\n";
    }
    
    NSString *textToPrint = [NSString stringWithFormat:@"%@%@", formatText, stringText];
    NSLog(@"test textToPrint %@", textToPrint);
    [printerController printNormal:PTR_S_RECEIPT data:[NSString stringWithFormat:@"%@", textToPrint]];
    [printerController printNormal:PTR_S_RECEIPT data:line];
}

+ (void) doPrintText:(const char *)data {
    NSString *stringText, *tempText;
    NSMutableString *tempMutableString;
    long countLine;
    char attribute, alignment, fontSize, lineFeed;
    NSString *ESC = @"\x1B";
    NSString *formatText = @"";
    
    NSArray *divideText;
    
    stringText = [NSString stringWithUTF8String:data];
    countLine = [[stringText componentsSeparatedByString:@"\n"] count];
    divideText = [stringText componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    
    for (int line = 0; line < countLine; line++) {
        tempText = divideText[line];
        
        //attribute setting
        attribute = [[tempText uppercaseString] characterAtIndex:0];
        
        if (attribute == 'E') {
            formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|bC", ESC]];
        } else if (attribute == 'B') {
            formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|rvC", ESC]];
        }
        
        //alignment setting
        alignment = [[tempText uppercaseString] characterAtIndex:2];
        if (alignment == 'L') {
            formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|N", ESC]];
        } else if (alignment == 'C' || alignment == 'M') {
            formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|cA", ESC]];
        } else if (alignment == 'R') {
            formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|rA", ESC]];
        }
        
        //font size
        fontSize = [[tempText uppercaseString] characterAtIndex:4];
        if (fontSize == '1') {
            formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|1C", ESC]];
        } else if (fontSize == '2') {
            formatText = [formatText stringByAppendingString:[NSString stringWithFormat:@"%@|2C", ESC]];
        }
        
        //line feed
        lineFeed = [[tempText uppercaseString] characterAtIndex:6];
        NSString *line = @"";
        if (lineFeed == '1') {
            line = @"\n";
        } else if (lineFeed == '2') {
            line = @"\n\n";
        }
        
        tempMutableString = [tempText mutableCopy];
        [tempMutableString deleteCharactersInRange:NSMakeRange(0, 7)];
        tempText = tempMutableString;
        
        //NSLog(@"textToPrint = %@", tempText);
        NSString *textToPrint = [NSString stringWithFormat:@"%@%@", formatText, tempText];
        NSLog(@"text to print %@", textToPrint);
        
        //[printerController printNormal:PTR_S_RECEIPT data:[NSString stringWithFormat:@"%@%@",formatText, tempText]];
        //[printerController printNormal:PTR_S_RECEIPT data:line];
        
        [printerController printNormal:PTR_S_RECEIPT data:[NSString stringWithFormat:@"%@", textToPrint]];
        [printerController printNormal:PTR_S_RECEIPT data:line];
    }
    
    [printerController printNormal:PTR_S_RECEIPT data:@"\n\n\n\n"];
    [printerController cutPaper:PTR_CP_FULLCUT];
}

+ (void) doPrintImage:(const char *)imagename {
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s", imagename]]];
    UIImage *imagePrint = [[UIImage alloc] initWithData:imgData];
    
    [printerController printBitmap:PTR_S_RECEIPT image:imagePrint width:printerController.RecLineWidth alignment:PTR_BM_CENTER brightness:10050];
}

+ (void) cutPaper {
    [printerController printNormal:PTR_S_RECEIPT data:@"\n\n\n\n"];
    [printerController cutPaper:PTR_CP_FULLCUT];
}
@end

#import <UIKit/UIKit.h>
#import "UPOSPrinterController.h"

@interface PrinterFunction : UIViewController <UPOSDeviceControlDelegate>

+ (void) initializePrinter;
+ (void) addPrinterToList:(const char *)modelName LogicName:(const char *)logicName Type:(int)type Address:(const char *)address Port:(int)port;
+ (void) addPrinter:(UPOSPrinter *)printer;
+ (void) connectPrinter:(const char *)printerName;
+ (void) disconnectPrinter;
+ (NSString *) checkStatus;
+ (void) doPrintText:(const char *)data;
+ (void) printText:(const char *)text Align:(const char *)align
         Attribute:(const char *)attribute TextSize:(int)textSize LineFeed:(int)lineFeed;
+ (void) cutPaper;

@end

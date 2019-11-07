//
//  UPOSDevices.h
//  BixolonUPOS
//
//  Created by savin on 13. 11. 5..
//  Copyright (c) 2013년 savin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPOSDefines.h"


///////////////////////////////////////////////////////////////////
//  UPOS Devices  delegate
///////////////////////////////////////////////////////////////////
@protocol UPOSDevicesDelegate <NSObject>

@required

@optional

-(void)didFinish_ShowBluetoothAccessory:(NSError*) error;   //  if Success,  error will be nil
@end




//@class DevicesList;
///////////////////////////////////////////////////////////////////
@interface UPOSDevice : NSObject
@property (retain)  NSString        *modelName;
@property (retain)  NSString        *ldn;
@property (retain)  NSNumber        *interfaceType;
@property (retain)  NSString        *address;
@property (retain)  NSString        *serialNumber;
@property (retain)  NSString        *port;
@property (retain)  NSString        *bluetoothDeviceName;
@property (nonatomic)  BOOL         connectedFlag;


@end



///////////////////////////////////////////////////////////////////
@interface UPOSDevices : NSObject

@property (weak, nonatomic)				id<UPOSDevicesDelegate>	delegate;

-(NSArray*)getPairedDevices;
-(NSArray*)getPairedDevices:(NSError**) errorCode
                     action:(NSInteger) action; //  if (action!=_SHOW_BLUETOOTH_SETTINGS_NEVER), the result is nil.
-(NSArray*)getList;
-(NSString*)getDeviceIdentity;
-(BOOL) save;
-(BOOL) addDevice:(id)device;       //  UPOSDevice, UPOSPrinter, UPOSMSR, UPOSSCR
-(BOOL) removeDevice:(id)device;    //  UPOSDevice, UPOSPrinter, UPOSMSR, UPOSSCR
@end




///////////////////////////////////////////////////////////////////
//  Printers
///////////////////////////////////////////////////////////////////
@interface UPOSPrinter : UPOSDevice
@end

///////////////////////////////////////////////////////////////////
@interface UPOSPrinters : UPOSDevices
@end


///////////////////////////////////////////////////////////////////
//  CashDrawers
///////////////////////////////////////////////////////////////////
@interface UPOSCashDrawer : UPOSDevice

@property (retain)  NSString        *selectedPrinterName;
@property (retain)  NSNumber        *pinNumber;
@property (retain)  NSNumber        *pinLevel;
@property (retain)  NSNumber        *pulseOnTime;
@property (retain)  NSNumber        *pulseOffTime;

@end

///////////////////////////////////////////////////////////////////
@interface UPOSCashDrawers : UPOSDevices
@end


///////////////////////////////////////////////////////////////////
//  MSRs
///////////////////////////////////////////////////////////////////
@interface UPOSMSR : UPOSDevice
@property (retain)  NSString        *selectedPrinterName;

@end

///////////////////////////////////////////////////////////////////
@interface UPOSMSRs : UPOSDevices
@end




///////////////////////////////////////////////////////////////////
//  MSRs
///////////////////////////////////////////////////////////////////
@interface UPOSSCR : UPOSDevice

@end

///////////////////////////////////////////////////////////////////
@interface UPOSSCRs : UPOSDevices
@end
















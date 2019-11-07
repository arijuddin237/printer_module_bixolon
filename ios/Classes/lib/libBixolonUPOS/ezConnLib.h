//
//  ezConnLib.h
//  ezConnLib
//
//  Created by inc_tech on 2016. 8. 18..
//  Copyright © 2016년 com.inctech.Print_Test. All rights reserved.
//

#import <Foundation/Foundation.h>

const int DEFAULT_PORT = 27032;

@protocol ezConnDelegate <NSObject>
@required
- (void) result_out: (NSString*) result;
@end

@interface ezConnLib : NSObject
{
    __unsafe_unretained id <ezConnDelegate> delegate;
    
    Byte mSSID[32], mPassword[64], mIP[4];
    
    int maxSSID, maxPassword, maxIP, maxSendLen, currSeq, maxGw;
    
    int targetIP;
    int targetPort;
}



// 10 ~ 20
// 40
// 1

// 스타트 22초 스탑 재시도
// 100m 스펙
// 프린터와 AP
// 신호세기에 따라서



@property (nonatomic, assign) id <ezConnDelegate> delegate;

-(NSString *) SCSendInit: (NSString*)ssid :(NSString*)password :(int)port :(NSString*)myIP :(NSString*)myGw;    // 모듈 초기화
-(void)       SCSendStart;      // 스마트 커넥션 시작
-(void)       SCSendStop;       // 스마트 커넥션 종료
-(void)       SCHalt;           //
-(void)       SCSocketOpen;
-(void)       SCSocketClose;
-(NSString*)  getIPAddress;
@end

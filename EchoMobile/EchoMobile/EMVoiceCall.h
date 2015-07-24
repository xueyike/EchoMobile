//
//  EMVoiceCall.h
//  EchoMobile
//
//  Created by Macmini on 03/11/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCall.h>

@interface EMVoiceCall : NSObject

typedef void (^EMCallBlock)(NSTimeInterval duration);
typedef void (^EMCancelBlock)(void);

+ (BOOL)callPhoneNumber:(NSString *)phoneNumber
                   call:(EMCallBlock)callBlock
                 cancel:(EMCancelBlock)cancelBlock;

@end

//
//  SKReceiptVerifier.h
//  TestingiOSInAppPurchase
//
//  Created by Vandad Nahavandipoor on 19/03/2012.
//  Copyright (c) 2012 Pixolity Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SKTransactionReceiptVerifierReceiptVerified)(BOOL paramSucceeded, NSError *paramFailureError, BOOL paramisValidReceipt, NSDictionary *responseDictionary);

@interface SKTransactionReceiptVerifier : NSObject

- (void) verifyTransactionReceipt:(NSData *)paramTransactionReceipt completionBlock:(SKTransactionReceiptVerifierReceiptVerified)paramCompletionBlock;

+ (SKTransactionReceiptVerifier *)sharedInstance;

@end

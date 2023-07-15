//
//  MonkeyStore.h
//  moneky
//
//  Created by Sood, Abhishek on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class MonkeyStore;

@protocol MonkeyStoreDelgate <NSObject>

-(void)monkeyStore:(MonkeyStore*)mkStore didGetProduct:(SKProduct*)product;
-(void)monkeyStoreBuySuccessful:(MonkeyStore*)mkStore;
-(void)monkeyStoreRestoreSuccessful:(MonkeyStore*)mkStore;
-(void)monkeyStoreBuyFailed:(MonkeyStore*)mkStore;
@end

@interface MonkeyStore : NSObject<SKPaymentTransactionObserver,SKProductsRequestDelegate>{
    SKProduct* _unlockGameProduct;
    NSMutableArray* _logs;
}

@property(nonatomic,assign)id<MonkeyStoreDelgate> delegate;

+(id)sharedStore;

-(void)requestProductData;
-(void)restore;
-(void)buy;

@end

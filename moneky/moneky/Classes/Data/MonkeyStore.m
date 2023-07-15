//
//  MonkeyStore.m
//  moneky
//
//  Created by Sood, Abhishek on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MonkeyStore.h"
#import "MonkeyClientData.h"
#import "Flurry.h"
#import "SKTransactionReceiptVerifier.h"

#define kUnlockFullGameIdentifier @"fullversion"
static MonkeyStore* store;

@implementation MonkeyStore
@synthesize delegate;

+(id)sharedStore{
    if (!store) {
        store = [[MonkeyStore alloc] init];
    }
    return store;
}

-(id)init{
    self = [super init];
    if (self) {
        _logs = [[NSMutableArray alloc] initWithCapacity:10];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [_unlockGameProduct release];
    [_logs release];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [super dealloc];
}

-(NSString*)getFileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    return [cacheDirectory stringByAppendingPathComponent:@"buy.log"];
}

-(void)synchronize{
    NSString* filename = [self getFileName];
    [_logs writeToFile:filename atomically:YES];
}

-(void)log:(NSString*)log{
    [_logs addObject:log];
}

- (void)requestProductData
{
    [self log:@"Sending product request"];
    SKProductsRequest *request= [[[SKProductsRequest alloc] initWithProductIdentifiers:
                                 [NSSet setWithObject: kUnlockFullGameIdentifier]] autorelease];
    request.delegate = self;
    [request start];
    [self synchronize];
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [self log:@"Got product response"];
    [_unlockGameProduct release];
    _unlockGameProduct = nil;
    NSArray *myProducts = response.products;
    if (myProducts && [myProducts count]>0) {
        for (SKProduct* p in myProducts) {
            if ([p.productIdentifier isEqualToString:kUnlockFullGameIdentifier]) {
                _unlockGameProduct = [p retain];
                [self log:@"Got full version product"];
                break;
            }
        }
    }else {
        DLog(@"Unable to get proguct: %@",request.debugDescription);
        [self log:@"Unable to get product"];
    }
    [delegate monkeyStore:self didGetProduct:_unlockGameProduct];
    [self synchronize];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self log:@"Failed to request product"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"In-App Store unavailable" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    if (_unlockGameProduct == nil) {
        [delegate monkeyStore:self didGetProduct:_unlockGameProduct];
    }
    [alert show];
    [alert release];
    [self synchronize];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    [self log:[NSString stringWithFormat:@"Restore failed with code %d",error.code]];
    if (error.code != SKErrorPaymentCancelled) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        [alertView autorelease];
    }
    [self.delegate monkeyStoreBuyFailed:self];
    [self synchronize];
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    // TODO:
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    if ([[MonkeyClientData sharedData] isPurchased]) {
//        alertView.title = @"Success";
//        alertView.message = @"The game has been unlocked";
//
//    }else {
//        alertView.title = @"Error";
//        alertView.message = @"Nothing to restore.";
//    }
//    [alertView show];
//    [alertView autorelease];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        [self log:[NSString stringWithFormat:@"Updating transaction with state %d",transaction.transactionState]];
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
    [self synchronize];
}

-(void)completeTransaction:(SKPaymentTransaction *)transaction{
    [self log:@"Transaction completed"];
    NSData* data = transaction.transactionReceipt;
    [[SKTransactionReceiptVerifier sharedInstance] verifyTransactionReceipt:data completionBlock:^(BOOL paramSucceeded, NSError *paramFailureError, BOOL paramisValidReceipt, NSDictionary *responseDictionary) {
        if (paramisValidReceipt) {
            [self log:@"Valid reciept"];
            [self provideContent:transaction.payment.productIdentifier];
            [self.delegate monkeyStoreBuySuccessful:self];  
        }else {
            [self log:@"Inavlid buy reciept"];
            DLog(@"Invalid reciept");
            [self.delegate monkeyStoreBuyFailed:self];
        }
        if (paramFailureError) {
            [self log:[NSString stringWithFormat:@"error verifiying reciept: %@",paramFailureError.localizedDescription]];
            DLog(@"Error verifying reciept: %@",[paramFailureError localizedDescription]);
            [self.delegate monkeyStoreBuyFailed:self];
        }
        if (!paramSucceeded) {
            [self log:@"Unsuccessful verifying buy reciept"];
            DLog(@"Unsuccessful verifying reciept");
            [self.delegate monkeyStoreBuyFailed:self];
        }
        
    }];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self synchronize];
}

-(void)failedTransaction:(SKPaymentTransaction *)transaction{
    [self log:[NSString stringWithFormat:@"Transaction failed. Error code: %d",transaction.error.code]];
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        if (transaction.error.code == SKErrorPaymentInvalid) {
            alertView.message = @"Invalid Payment Method. Please check credit card info.";
        }else if (transaction.error.code == SKErrorPaymentNotAllowed)  {
            alertView.message = @"In App Purchase not allowed.";
        }
        [alertView show];
        [alertView autorelease];
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self.delegate monkeyStoreBuyFailed:self];
    [self synchronize];
}

-(void)restoreTransaction:(SKPaymentTransaction *)transaction{
    [self log:@"Restoring transaction"];
    NSData* data = transaction.transactionReceipt;
    if (!data) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Nothing to restore!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        [alertView autorelease];
        [self.delegate monkeyStoreBuyFailed:self];
        [self log:@"Nothing to restore"];
        return;
    }
    [[SKTransactionReceiptVerifier sharedInstance] verifyTransactionReceipt:data completionBlock:^(BOOL paramSucceeded, NSError *paramFailureError, BOOL paramisValidReceipt, NSDictionary *responseDictionary) {
        if (paramisValidReceipt) {
            [self provideContent:transaction.originalTransaction.payment.productIdentifier];
            [self.delegate monkeyStoreRestoreSuccessful:self];
            [self log:@"Restore verified"];
        }else {
            DLog(@"Invalid reciept");
            [self log:@"Invalid reciept"];
            [self.delegate monkeyStoreBuyFailed:self];
        }
        if (paramFailureError) {
            DLog(@"Error verifying reciept: %@",[paramFailureError localizedDescription]);
            [self log:@"Error verifying reciept"];
            [self.delegate monkeyStoreBuyFailed:self];
        }
        if (!paramSucceeded) {
            DLog(@"Unsuccessful verifying reciept");
            [self log:@"Unsuccessful verifying reciept"];
            [self.delegate monkeyStoreBuyFailed:self];
        }
        
    }];
    [self log:@"Finish restore transaction"];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self synchronize];
}

-(void)provideContent:(NSString*)identifier{
    if ([identifier isEqualToString:kUnlockFullGameIdentifier]) {
        [[MonkeyClientData sharedData] setPurchased:[NSNumber numberWithBool:YES]];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Full game has been unlocked.\nThank you for your support!" delegate:nil cancelButtonTitle:@"Let's Go!" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [Flurry logEvent:@"Full game unlocked"];
        [self log:@"Full game unlocked"];
    }else {
        [self log:[NSString stringWithFormat:@"Provide content called with unknown id: %@",identifier]];
    }
    [self synchronize];
}

-(void)buy{
    [self log:@"Buy initiated"];
    if ([SKPaymentQueue canMakePayments]) {
        if (!_unlockGameProduct) {
            [self log:@"Unlock game product is nil"];
            [self.delegate monkeyStoreBuyFailed:self];
            return;
        }
        SKPayment *payment = [SKPayment paymentWithProduct:_unlockGameProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [self log:@"Payment added to paymentqueue"];
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"In-App purchases has been disabled. Please enable them from Settings->General->Restrictions" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        [alertView autorelease];
        [self.delegate monkeyStoreBuyFailed:self];
        [self log:@"In app purchases unavailable"];
    }
    [self synchronize];
}

-(void)restore{
    [self log:@"Restore initiated"];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [self log:@"Restore added to paymentqueue"];
    [self synchronize];
}




@end

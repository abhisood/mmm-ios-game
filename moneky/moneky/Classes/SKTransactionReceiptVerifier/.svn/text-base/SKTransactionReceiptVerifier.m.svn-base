//
//  SKReceiptVerifier.m
//  TestingiOSInAppPurchase
//
//  Created by Vandad Nahavandipoor on 19/03/2012.
//  Copyright (c) 2012 Pixolity Ltd. All rights reserved.
//

#import "SKTransactionReceiptVerifier.h"

@implementation SKTransactionReceiptVerifier

#if DEBUG
const NSString *kSKTransactionReceiptVerifierURL = @"https://sandbox.itunes.apple.com/verifyReceipt";
#else
const NSString *kSKTransactionReceiptVerifierURL = @"https://buy.itunes.apple.com/verifyReceipt";
#endif

const NSInteger kSKTransactionReceiptVerifierErrorJSONDeserializationFailure = -1;
const NSInteger kSKTransactionReceiptVerifierErrorNoDataCameBackFromServer = -2;
const NSInteger kSKTransactionReceiptVerifierErrorUnfamiliarResponseFormat = -3;

static SKTransactionReceiptVerifier *SharedInstance = nil;

static char Base64EncodingTable[64] = {
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
  'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
  'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
  'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

- (NSString *) base64StringFromData:(NSData *)paramData length:(NSInteger)paramLength {
  
  NSInteger ixtext = 0, dataLength = 0;
  long remainingCharacters;
  unsigned char inputCharacters[3] = {0, 0, 0}, outputCharacters[4] = {0, 0, 0, 0};
  short counter, charsonline = 0, charactersToCopy = 0;
  const unsigned char *rawBytes;
  
  NSMutableString *result;
  
  dataLength = [paramData length]; 
  if (dataLength < 1){
    return [NSString string];
  }
  result = [NSMutableString stringWithCapacity: dataLength];
  rawBytes = [paramData bytes];
  ixtext = 0; 
  
  while (YES) {
    remainingCharacters = dataLength - ixtext;
    if (remainingCharacters <= 0) 
      break;        
    for (counter = 0; counter < 3; counter++) { 
      NSInteger index = ixtext + counter;
      if (index < dataLength)
        inputCharacters[counter] = rawBytes[index];
      else
        inputCharacters[counter] = 0;
    }
    outputCharacters[0] = (inputCharacters[0] & 0xFC) >> 2;
    outputCharacters[1] = ((inputCharacters[0] & 0x03) << 4) | ((inputCharacters[1] & 0xF0) >> 4);
    outputCharacters[2] = ((inputCharacters[1] & 0x0F) << 2) | ((inputCharacters[2] & 0xC0) >> 6);
    outputCharacters[3] = inputCharacters[2] & 0x3F;
    charactersToCopy = 4;
    switch (remainingCharacters) {
      case 1: 
        charactersToCopy = 2; 
        break;
      case 2: 
        charactersToCopy = 3; 
        break;
    }
    
    for (counter = 0; counter < charactersToCopy; counter++){
      [result appendString: [NSString stringWithFormat: @"%c", Base64EncodingTable[outputCharacters[counter]]]];
    }
    
    for (counter = charactersToCopy; counter < 4; counter++){
      [result appendString: @"="];
    }
      
    ixtext += 3;
    charsonline += 4;
    
    if ((paramLength > 0) && (charsonline >= paramLength)){
      charsonline = 0;
    }
  }     
  return result;
}

+ (SKTransactionReceiptVerifier *)sharedInstance{
  @synchronized(self){
    if (SharedInstance == nil){
      SharedInstance = [[self alloc] init];
    }
    return SharedInstance;
  }
}

- (NSError *) errorWithDescription:(NSString *)paramDescription errorCode:(NSInteger)paramErrorCode{
  
  NSDictionary *errorDictionary = [[[NSDictionary alloc] initWithObjectsAndKeys:paramDescription, NSLocalizedDescriptionKey, nil] autorelease];
  return [[[NSError alloc] initWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:paramErrorCode userInfo:errorDictionary] autorelease];
  
}

- (void) verifyTransactionReceipt:(NSData *)paramTransactionReceipt completionBlock:(SKTransactionReceiptVerifierReceiptVerified)paramCompletionBlock{
  
  if (paramTransactionReceipt == nil){
    DLog(@"The given transaction receipt is nil.");
    paramCompletionBlock(NO, nil, NO, nil);
    return;
  }
  
  NSError *jsonSerializationError = nil;

  NSString *transactionReceiptAsString = [self base64StringFromData:paramTransactionReceipt length:[paramTransactionReceipt length]];
  NSDictionary *receiptDictionary = [[[NSDictionary alloc] initWithObjectsAndKeys:transactionReceiptAsString, @"receipt-data", nil] autorelease];
    id receiptDictionaryAsData = [NSJSONSerialization dataWithJSONObject:receiptDictionary options:NSJSONWritingPrettyPrinted error:&jsonSerializationError];
  if (receiptDictionaryAsData == nil ||
      jsonSerializationError != nil){
    DLog(@"Could not serialize the request into a JSON object.");
    paramCompletionBlock(NO, jsonSerializationError, NO, nil);
    return;
  }
  
  NSURL *urlToCall = [NSURL URLWithString:(NSString *)kSKTransactionReceiptVerifierURL];
  
  NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:urlToCall cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0f] autorelease];
  [urlRequest setHTTPMethod:@"POST"];
  [urlRequest setHTTPBody:receiptDictionaryAsData];
  
  [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *paramResponse, NSData *paramData, NSError *paramError) {
    
    if (paramData != nil &&
        paramError == nil){
      
      NSError *jsonDeserializationError = nil;
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:paramData options:0 error:&jsonDeserializationError];
      if (responseDictionary != nil &&
          jsonDeserializationError == nil){
        
        __block BOOL statusKeyExists = NO;
        [responseDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *paramKey, id paramObject, BOOL *paramStop) {
          if ([paramKey isEqualToString:@"status"]){
            statusKeyExists = YES;
            *paramStop = YES;
          }
        }];
        
        if (statusKeyExists){
          NSNumber *status = [responseDictionary objectForKey:@"status"];
          NSDictionary *receiptInResponseJSON = [responseDictionary objectForKey:@"receipt"];
          if (status != nil &&
              receiptInResponseJSON != nil){
            if ([status integerValue] == 0){
              /* Status is zero (success) */ 
              paramCompletionBlock(YES, nil, YES, receiptInResponseJSON);
            } else {
              /* The status is NOT 0, which means the transaction receipt we sent to Apple is not a valid transaction receipt */
              paramCompletionBlock(YES, nil, NO, receiptInResponseJSON);
            } 
          } else {
            /* The server sent a response that doesn't contain the objects that we were expecting */
            paramCompletionBlock(NO, [self errorWithDescription:@"Unfamiliar server response format" errorCode:kSKTransactionReceiptVerifierErrorUnfamiliarResponseFormat], NO, nil);
          }
        } else {
          /* The "status" key doesn't exist in the response dictionary */
          paramCompletionBlock(NO, nil, NO, [responseDictionary objectForKey:@"receipt"]);
        }
      }
      else {
        /* Error happened during the deserialization of the JSON object */
        paramCompletionBlock(NO, [self errorWithDescription:@"Failed to deserialize the response JSON" errorCode:kSKTransactionReceiptVerifierErrorJSONDeserializationFailure], NO, nil);
      }
      
    }
    else if (paramData == nil &&
             paramError == nil){
      /* No data came back from the connection and no error exists either */
      paramCompletionBlock(NO, [self errorWithDescription:@"No data came back from the remote server" errorCode:kSKTransactionReceiptVerifierErrorNoDataCameBackFromServer], NO, nil);
    }
    else if (paramError != nil){
      paramCompletionBlock(NO, paramError, NO, nil);
    }
    
  }];
  
  
}

@end

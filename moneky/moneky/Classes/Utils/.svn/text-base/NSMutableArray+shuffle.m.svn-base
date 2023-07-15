//
//  NSMutableArray+shuffle.m
//  moneky
//
//  Created by Sood, Abhishek on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray+shuffle.h"

@implementation NSMutableArray (shuffle)

//Fisher–Yates shuffle 
-(void)shuffle{
    for (int i=([self count]-1); i>1; i--) {
        int j = rand()%i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
}

@end

//
//  PlayMenuItem.m
//  moneky
//
//  Created by Sood, Abhishek on 10/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayMenuItem.h"

@implementation PlayMenuItem

-(void)setOpacity:(GLubyte)opacity{
    [super setOpacity:opacity];
    id item;
	CCARRAY_FOREACH(children_, item){
        if ([item conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            [((id<CCRGBAProtocol>)item) setOpacity:opacity];
        }
    }
}

-(CGRect) rect
{
    CGRect rect = super.rect;
    id item;
	CCARRAY_FOREACH(children_, item){
        if ([item respondsToSelector:@selector(rect)]) {
            rect = CGRectUnion(rect, [item rect]);
        }else if ([item respondsToSelector:@selector(boundingBox)]) {
            rect = CGRectUnion(rect, [item boundingBox]);
        }
    }    
    return rect;
}

@end

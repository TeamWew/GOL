//
//  GOLCell.m
//  GOL
//
//  Created by niccs on 13/07/15.
//  Copyright (c) 2015 TeamWew. All rights reserved.
//

#import "GOLCell.h"

@implementation GOLCell

-(void)wakeUp
{
    self.backgroundColor = [UIColor blackColor];
    self.alive = YES;
}

-(void)kill
{
    self.backgroundColor = [UIColor whiteColor];
    self.alive = NO;
}

@end

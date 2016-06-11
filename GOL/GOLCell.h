//
//  GOLCell.h
//  GOL
//
//  Created by niccs on 13/07/15.
//  Copyright (c) 2015 TeamWew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOLCell : UICollectionViewCell

@property (nonatomic, assign) BOOL alive;

- (void)wakeUp;
- (void)kill;

@end

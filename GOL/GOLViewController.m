//
//  GOLViewController.m
//  GOL
//
//  Created by niccs on 13/07/15.
//  Copyright (c) 2015 TeamWew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GOLViewController.h"
#import "GOLCell.h"

#define WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface GOLViewController ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation GOLViewController

int _MIN_ROW;
int _MIN_COL;
int _MAX_COL;
int _MAX_ROW;
double _CELL_SIZE = 10.0;
double _DELIMITER_SIZE = 1.0;

- (instancetype)init
{
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    double MAGIC_NUMBER = _DELIMITER_SIZE + _CELL_SIZE + 0.3;
    _MIN_ROW = 0;
    _MIN_COL = 0;
    _MAX_ROW = ceil(HEIGHT / MAGIC_NUMBER);
    _MAX_COL = floor(WIDTH / MAGIC_NUMBER);
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSLog(@"%fx%f", HEIGHT, WIDTH);

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:pan];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setScrollEnabled:false];
    [_collectionView registerClass:[GOLCell class] forCellWithReuseIdentifier:@"GOLCell"];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:_collectionView];
}

- (void)handleLongPress:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    if (velocity.y < -600.0) {
        //NSLog(@"%f", velocity.y);
        NSLog(@"wew");
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _MAX_COL + 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _MAX_ROW + 1;
}

- (GOLCell *)collectionView:(UICollectionView *)collectionView
     cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GOLCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GOLCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GOLCell *cell = (GOLCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell wakeUp];

    NSMutableArray *neighbors = (NSMutableArray *)[self neighboursForCellAtIndexPath:indexPath collectionView:collectionView];
    NSMutableArray *random = [[NSMutableArray alloc] init];

    for (GOLCell *n in neighbors) {
        if (arc4random() % 100 < 50) {
            [random addObject:n];
        }
    }

    for (GOLCell *c in random) {
        [c wakeUp];
    }

    if (!self.timer) {
        NSLog(@"Timer not created, creating...");
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(lifeCycle:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (NSArray *)neighboursForCellAtIndexPath:(NSIndexPath *)indexPath
                      collectionView:(UICollectionView *)collectionView
{
    int row = (int)indexPath.section;
    int col = (int)indexPath.row;
    GOLCell *originalCell = (GOLCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSMutableArray *neighbors = [[NSMutableArray alloc] init];
    for (int j = row - 1; j < row + 2; j++) {
        for (int i = col - 1 ; i < col + 2; i++) {
            NSIndexPath *neighborIndexPath = [NSIndexPath indexPathForRow:i inSection:j];
            if (![self isIllegalNeighborForIndexPath:neighborIndexPath]) {
                GOLCell *cell = (GOLCell *)[collectionView cellForItemAtIndexPath:neighborIndexPath];
                [neighbors addObject:cell];
            }
        }
        
    }
    [neighbors removeObjectIdenticalTo:originalCell];
    return neighbors;
}

- (int)aliveNeighborsForCellAtIndexPath:(NSIndexPath *)indexPath
                         collectionView:(UICollectionView *)collectionView
{
    int count = 0;
    for (GOLCell *cell in [self neighboursForCellAtIndexPath:indexPath collectionView:collectionView]) {
        if ([cell alive]) {
            count++;
        }
    }
    return count;
}

- (BOOL)isIllegalNeighborForIndexPath:(NSIndexPath *)indexPath
{
    int y = (int)indexPath.section;
    int x = (int)indexPath.row;
    
    return (x < _MIN_COL) || (x > _MAX_COL) || (y < _MIN_ROW) || (y > _MAX_ROW);
}


- (void)lifeCycle:(NSTimer *)timer
{
    for (int y = _MIN_ROW; y < _MAX_ROW + 1 ; y++ ) {
        for (int x = _MIN_COL; x < _MAX_COL + 1; x++) {
            NSIndexPath *neighborIndexPath = [NSIndexPath indexPathForRow:x inSection:y];

            if (![self isIllegalNeighborForIndexPath:neighborIndexPath]) {
                GOLCell *cell = (GOLCell *)[_collectionView cellForItemAtIndexPath:neighborIndexPath];
                if (![self cellShouldDie:cell atIndexPath:neighborIndexPath collectionView:_collectionView]) {
                    [cell wakeUp];
                }
                else {
                    [cell kill];
                }
            }
        }
    }
    [_collectionView setNeedsDisplay];
}

- (BOOL)cellShouldDie:(GOLCell *)cell atIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView
{
    int neighborCount = [self aliveNeighborsForCellAtIndexPath:indexPath collectionView:collectionView];

    if (cell.alive) {
            if (neighborCount == 1) return YES;
            if (neighborCount == 2) return NO;
            if (neighborCount == 3) return NO;
    }
    else {
            if (neighborCount == 3) return NO;
    }

    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(_DELIMITER_SIZE, _DELIMITER_SIZE);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_CELL_SIZE, _CELL_SIZE);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _DELIMITER_SIZE;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _DELIMITER_SIZE;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end

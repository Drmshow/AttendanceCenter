//
//  AttendanceViewController.m
//  AttendanceCenter
//
//  Created by admin on 16/3/16.
//  Copyright © 2016年 drmshow. All rights reserved.
//

#import "AttendanceViewController.h"
#import "AttendanceTableViewCell.h"
#import "TimeLineView.h"

#define kCellHeight             90
#define kDelayFactor            0.3
#define kAnimationDuration      0.6

@interface AttendanceViewController ()
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *earthImageView;
@property (weak, nonatomic) IBOutlet UIImageView *markerImageView;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, weak) TimeLineView *timeLineView;
@property (nonatomic, strong) TimeLineView *tableLine;
@property (nonatomic, strong) NSMutableArray *attendanceArrays;
@end

@implementation AttendanceViewController

#pragma mark -View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"AttendanceTableViewCell" bundle:nil] forCellReuseIdentifier:@"attendanceTableViewCell"];
}

#pragma mark -UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.attendanceArrays.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AttendanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attendanceTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell.tag == 11) {
        cell.tag = 0;
        [cell setNeedsDisplay];
    }
    if (indexPath.row == self.attendanceArrays.count-1) {
        cell.tag = 11;
        [cell setNeedsDisplay];
    }
    return cell;
}

#pragma mark -UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

#pragma mark -Button attendanceCenter click event

- (IBAction)attendanceCenterClick {
    if (self.isAnimating) {
        NSLog(@"正在动画...");
        return;
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionNone animated:YES];
    self.coverView.hidden = NO;
    [self.attendanceArrays insertObject:@"1" atIndex:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];

    AttendanceTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    UIView *newCell = [cell snapshotViewAfterScreenUpdates:YES];
    newCell.frame = CGRectMake(0, -kCellHeight, cell.frame.size.width, kCellHeight);
    [self.coverView insertSubview:newCell aboveSubview:self.timeLineView];
    [self markerImageViewBeginAnimation];
    [self earthImageViewBeginAnimation];
    [self cellAnimation];
}

#pragma mark -Button attendanceSuccess click event

- (IBAction)attendanceSuccessClick
{
    CALayer *layer = self.markerImageView.layer;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x, layer.position.y-15)];
    animation.autoreverses = YES;
    animation.duration = kAnimationDuration;
    animation.repeatCount = 2;
    animation.removedOnCompletion = NO;
    [layer addAnimation:animation forKey:nil];
}

#pragma mark -Cell animation

- (void)cellAnimation
{
    NSInteger tableViewH = [UIScreen mainScreen].bounds.size.height -100 -64 -100;
    NSInteger cellCount = 2 + tableViewH / kCellHeight;
    self.isAnimating = YES;
    NSInteger index = 0;
    NSInteger count = self.coverView.subviews.count -1;
    if (count > cellCount) {
        count = cellCount;
    }
    self.timeLineView.frame = CGRectMake(1, 0, 40, (count-1) *kCellHeight);
    for (NSInteger i=count; i>=0; i--) {
        if (i == 0) {
            return;
        }
        UIView *subview = self.coverView.subviews[i];
        if ([subview isKindOfClass:[TimeLineView class]]) {
            continue;
        }
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(subview.layer.position.x, subview.layer.position.y+kCellHeight)];
        animation.duration = kAnimationDuration -0.1;
        animation.removedOnCompletion = NO;
        if (i == 1) {
            animation.delegate = self;
        }
        animation.fillMode = kCAFillModeForwards;
        animation.beginTime = CACurrentMediaTime()+kDelayFactor*index +kAnimationDuration;
        [subview.layer addAnimation:animation forKey:nil];
        index++;
    }
}

#pragma mark -CAAnimationDelegate

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    self.coverView.hidden = YES;
    self.isAnimating = NO;
    for (UIView *subview in self.coverView.subviews) {
        if ([subview isKindOfClass:[TimeLineView class]]) {
            continue;
        }
        [subview.layer removeAllAnimations];
        subview.frame = CGRectOffset(subview.frame, 0, kCellHeight);
    }
}

#pragma mark -MarkerImageView animation

- (void)markerImageViewBeginAnimation
{
    CALayer *layer = self.markerImageView.layer;
    CABasicAnimation *animTranslate = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animTranslate.toValue = @(-46-15);
    CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animScale.toValue = @(1.5);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animTranslate];
    group.duration = kAnimationDuration;
    group.autoreverses = YES;
    [layer addAnimation:group forKey:nil];
}

#pragma mark -EarthImageView animation

- (void)earthImageViewBeginAnimation
{
    CALayer *layer = self.earthImageView.layer;
    CABasicAnimation *animTranslate = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animTranslate.toValue = @(-30);
    CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animScale.toValue = @(1.2);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animTranslate, animScale];
    group.duration = kAnimationDuration;
    group.autoreverses = YES;
    [layer addAnimation:group forKey:nil];
}

#pragma mark -lazy coverView

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.tableView.frame];
        _coverView.backgroundColor = [UIColor whiteColor];
        self.tableView.backgroundColor = [UIColor whiteColor];
        TimeLineView *timeLineView = [[TimeLineView alloc] initWithFrame:CGRectMake(1, 0, 40, _coverView.frame.size.height -35)];
        self.timeLineView = timeLineView;
        timeLineView.backgroundColor = [UIColor whiteColor];
        [_coverView addSubview:timeLineView];
        NSArray *visibleCells = [self.tableView visibleCells];
        for (AttendanceTableViewCell *cell in visibleCells) {
            UIView *copyCell = [cell snapshotViewAfterScreenUpdates:YES];
            copyCell.frame = cell.frame;
            [_coverView addSubview:copyCell];
        }
        
    }
    [self.view insertSubview:_coverView belowSubview:self.bottomView];
    [self.view bringSubviewToFront:self.headerView];
    return _coverView;
}

#pragma mark -lazy attendanceArrays

- (NSMutableArray *)attendanceArrays
{
    if (!_attendanceArrays) {
        _attendanceArrays = [NSMutableArray array];
        [_attendanceArrays addObject:@"1"];
        [_attendanceArrays addObject:@"1"];
    }
    return _attendanceArrays;
}

#pragma mark -TableView timeLine

- (TimeLineView *)tableLine
{
    if (!_tableLine) {
        _tableLine = [[TimeLineView alloc] init];
        _tableLine.backgroundColor = self.tableView.backgroundColor;
        [self.tableView addSubview:_tableLine];
    }
    return _tableLine;
}

#pragma  mark -UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        self.tableLine.frame = CGRectMake(1, scrollView.contentOffset.y, 40, -scrollView.contentOffset.y);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isAnimating) {
        return;
    }
    [self markerImageViewBeginAnimation];
    [self earthImageViewBeginAnimation];
}

@end

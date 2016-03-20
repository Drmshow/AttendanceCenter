//
//  AttendanceTableViewCell.m
//  AttendanceCentre
//
//  Created by admin on 16/3/14.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "AttendanceTableViewCell.h"

#define kColorValue(value)  value/255.0
#define kTimeLineX          22
#define kLastCellTag        11
#define kNodeWidth          15

@interface AttendanceTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
@implementation AttendanceTableViewCell

- (void)awakeFromNib
{
    self.bgView.layer.cornerRadius = 5;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat height = self.frame.size.height;
    CGContextMoveToPoint(ctx, kTimeLineX, 0.0);
    CGContextAddLineToPoint(ctx, kTimeLineX, height-35);
    [[UIColor colorWithRed:kColorValue(0) green:kColorValue(214) blue:kColorValue(165) alpha:1] setStroke];
    CGContextSetLineWidth(ctx, 4);
    CGContextStrokePath(ctx);
    
    if (self.tag != kLastCellTag) {
        CGContextMoveToPoint(ctx, kTimeLineX, 55 +kNodeWidth *0.5);
        CGContextAddLineToPoint(ctx, kTimeLineX, height);
        [[UIColor colorWithRed:kColorValue(0) green:kColorValue(214) blue:kColorValue(165) alpha:1] setStroke];
        CGContextSetLineWidth(ctx, 4);
        CGContextStrokePath(ctx);
    }
    UIImage *image = [UIImage imageNamed:@"node"];
    [image drawInRect:CGRectMake(kNodeWidth, 55 -kNodeWidth *0.5, kNodeWidth, kNodeWidth)];
}

@end

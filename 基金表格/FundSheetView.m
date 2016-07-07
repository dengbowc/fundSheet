//
//  FundSheetView.m
//  基金表格
//
//  Created by 瑶波波 on 16/7/6.
//  Copyright © 2016年 dengbowc. All rights reserved.
//

//上下左右的边距
#define kLeftMargin 45
#define kRightMargin 10
#define kBottomMargin 20
#define kTopMargin    (self.frame.size.height - kBottomMargin - 125)
// 表格高度
#define kSheetHeight 125
// 表格宽度
#define kSheetWidth  (self.frame.size.width - kLeftMargin - kRightMargin)
// 表格中每一个格子的高度 (125 / 5)
#define kSectionHeight 25
// 横坐标每一个单位的宽度
#define kXSectionWidth (kSheetWidth / (self.locations1.count - 1))

#import "FundSheetView.h"
#import "DBPoint.h"

@interface FundSheetView ()

/**
 *  日期数组(横坐标)
 */
@property (nonatomic,strong)NSArray *dateSets;

/**
 *  纵坐标数组1
 */
@property (nonatomic,strong)NSArray *ySets;

/**
 *  纵坐标数组2
 */
@property (nonatomic,strong)NSArray *anotherYSets;

/**
 *  纵坐标是否是百分比
 */
@property(nonatomic ,assign) BOOL isPercent;

/**
 *  纵坐标数字数组，按产品要求应该是6个
 */
@property (nonatomic,strong)NSMutableArray *ySetNumber;

/**
 *  坐标数组1(里面存放的是DBPoint)
 */
@property (nonatomic,strong) NSMutableArray *locations1;

/**
 *  坐标数组2
 */
@property (nonatomic,strong) NSMutableArray *locations2;

/**
 *  横线
 */
@property (nonatomic,strong)UIView *hengLine;
/**
 *  竖线
 */
@property (nonatomic,strong)UIView *shuLine;
/**
 *  十字中间的圆圈
 */
@property (nonatomic,strong)UIView *cirCle;

/**
 *  横坐标、纵坐标label数组
 */
@property (nonatomic,strong)NSMutableArray *labels;

@end


@implementation FundSheetView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 添加坐标线
    [self drawSetLine:ctx];
    
    // 画折线图
    [self drawLine:ctx points:self.locations1 index:1 isXian:NO];
    [self drawLine:ctx points:self.locations1 index:1 isXian:YES];
    
    // 如果有第二条折现，再画一条折线图
    if (self.locations2.count > 0) {
        [self drawLine:ctx points:self.locations2 index:2 isXian:NO];
        [self drawLine:ctx points:self.locations2 index:2 isXian:YES];
    }
}


/**
 *  画折线图并填充颜色
 *
 *  @param ctx ctx
 *  @param points 坐标点
 *  @param index  第一条线段还是第二条(用于区分颜色)
 *  @param isXian 是划线还是填充颜色
 */
- (void)drawLine:(CGContextRef)ctx points:(NSArray *) points index:(int)index isXian:(BOOL)isXian{
    CGContextMoveToPoint(ctx, kLeftMargin, kTopMargin + kSheetHeight);
    for (DBPoint *point in points) {
        CGContextAddLineToPoint(ctx, point.xSet, point.ySet);
    }
    // 闭合曲线
    CGContextAddLineToPoint(ctx, kLeftMargin + kSheetWidth, kTopMargin + kSheetHeight);
    
    //渐变色填充
    if (!isXian) {
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGFloat colorComponents[8] = {
            81 / 255.0, 125 / 255.0, 177 / 255.0, 0.2,
            1.0, 1.0, 1.0, 0.5
        };
        CGFloat secondColorComponents[8] = {
            153 / 255.0, 153 / 255.0, 153 / 255.0, 0.2,
            1.0, 1.0, 1.0, 0.5
        };
        CGGradientRef gradient;
        if (index == 1) {
            gradient = CGGradientCreateWithColorComponents(rgb, colorComponents, NULL, 2);
        }else {
            gradient = CGGradientCreateWithColorComponents(rgb, secondColorComponents, NULL, 2);
        }
        CGColorSpaceRelease(rgb);
        CGContextSaveGState(ctx);
        CGContextClip(ctx);
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(kLeftMargin + kSheetWidth / 2, kTopMargin), CGPointMake(kLeftMargin + kSheetWidth / 2, kTopMargin + kSheetHeight), kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
        CGContextRestoreGState(ctx);
    }
    
    // 把线画出来
    [[UIColor colorWithRed:81/255.0 green:125/255.0 blue:177/255.0 alpha:1.0] set];
    CGContextDrawPath(ctx, kCGPathStroke);
}

/**
 *  添加坐标线
 *
 *  @param ctx ctx
 */
- (void)drawSetLine:(CGContextRef)ctx {
    //添加虚线
    for (int i = 0; i < 5; i++) {
        [[UIColor lightGrayColor] set];
        CGFloat ySet = kTopMargin + i * kSectionHeight;
        NSLog(@"%f",ySet);
        CGContextMoveToPoint(ctx, kLeftMargin, ySet);
        CGContextAddLineToPoint(ctx, self.frame.size.width - kRightMargin, ySet);
        CGFloat lengths[] = {2,2};
        CGContextSetLineDash(ctx, 0, lengths, 2);
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    // 横坐标线
    CGContextMoveToPoint(ctx, kLeftMargin, kTopMargin + 5 * kSectionHeight);
    CGContextAddLineToPoint(ctx, self.frame.size.width - kRightMargin, kTopMargin + 5 * kSectionHeight);
    [[UIColor brownColor]set];
    CGContextSetLineDash(ctx, 0, NULL, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
}

/**
 *  刷新视图方法，传入刷新视图的所有值，计算出横坐标，纵坐标，刷新表格
 *  @param dateSets     日期数组(横坐标)
 *  @param ySets        纵坐标数组1
 *  @param anotherYsets 纵坐标数组2（如果没有的话传nil），因为有时候会需要两条折现，所以加了这个参数
 *  @param isPercent    纵坐标是否是百分比，如果是，纵坐标要加上百分比符号
 */
- (void)refreshWithDateSets:(NSArray *)dateSets ySets:(NSArray *)ySets anotherYsets:(NSArray *)anotherYsets isPercent:(CGFloat)isPercent {
    [self clearData];
    
    self.ySets = ySets;
    self.anotherYSets = anotherYsets;
    self.dateSets = dateSets;
    self.isPercent = isPercent;
    
    // 获取两个数组中所有值的最大值和最小值，计算出y坐标的6个数字
    NSMutableArray *array = [NSMutableArray arrayWithArray:ySets];
    [array addObjectsFromArray:anotherYsets];
    [self getYsetsNumbers:array];
    // 纵坐标6个值已经知道了，添加label
    for (int i = 0; i < 6; i++) {
        CGFloat ySet = kTopMargin + kSheetHeight - i * kSectionHeight;
        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kLeftMargin - 4, 10)];
        numLabel.center = CGPointMake(kLeftMargin / 2 - 2, ySet);
        numLabel.font = [UIFont systemFontOfSize:10];
        numLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        numLabel.textAlignment = NSTextAlignmentRight;
        // 取出数字
        NSNumber *num = self.ySetNumber[i];
        numLabel.text = [NSString stringWithFormat:@"%.1f",num.floatValue];
        [self addSubview:numLabel];
        [self.labels addObject:numLabel];
    }
    // 横坐标需要显示的3个label
    
    // 坐标已经完成，需要画点
    // 每个横坐标单元的宽度，取决于数据的个数
    CGFloat margin = kSheetWidth / (dateSets.count - 1);
    for (int i = 0; i < ySets.count; i++) {
        // 取出具体值
        NSNumber *num = ySets[i];
        @autoreleasepool {
            DBPoint *point = [DBPoint new];
            point.xSet = kLeftMargin + i * margin;
            point.ySet = [self calcuYset:num.floatValue];
            [_locations1 addObject:point];
        }
    }
    // 如果传入了第二条折现的数据，则计算第二条折现的坐标
    if (anotherYsets.count > 0) {
        for (int i = 0; i < ySets.count; i++) {
            // 取出具体值
            NSNumber *num = anotherYsets[i];
            @autoreleasepool {
                DBPoint *point = [DBPoint new];
                point.xSet = kLeftMargin + i * margin;
                point.ySet = [self calcuYset:num.floatValue];
                [_locations2 addObject:point];
            }
        }
    }
    [self setNeedsDisplay];
}

/**
 *  清除上一个图表数据
 */
- (void)clearData {
    self.locations1 = [NSMutableArray array];
    self.locations2 = [NSMutableArray array];
    self.ySetNumber = [NSMutableArray array];
    // 清空labels
    for (UILabel * label in self.labels) {
        [label removeFromSuperview];
    }
    self.labels = [NSMutableArray array];
}

/**
 *  获取纵坐标数组的数字(6个)
 */
- (void)getYsetsNumbers:(NSArray *)numbers {
    CGFloat min = [self findMin:numbers];
    CGFloat max = [self findMax:numbers];
    // 计算平均数，保留一位
    CGFloat aver = (max - min) / 5;
    NSString *average = [NSString stringWithFormat:@"%.1f",aver];
    aver = average.floatValue + 0.1;
    for (int i = 0; i < 6; i++) {
        // 往坐标数组里面添加值
        [self.ySetNumber addObject:@(min + aver * i)];
    }
}

/**
 *  从一组数中找出最小数
 *
 *  @param numbers 数组
 *
 *  @return 最小数
 */
- (CGFloat)findMin:(NSArray *)numbers {
    CGFloat min = MAXFLOAT;
    for (NSNumber *num in numbers) {
        if (num.doubleValue >= min) {
            continue;
        }else {
            min = num.doubleValue;
        }
    }
    return min;
}

/**
 *  从一组数中找出最大数
 *
 *  @param numbers 数组
 *
 *  @return 最大数
 */
- (CGFloat)findMax:(NSArray *)numbers {
    CGFloat max = -1000.0;
    for (NSNumber *num in numbers) {
        if (num.doubleValue <= max) {
            continue;
        }else {
            max = num.doubleValue;
        }
    }
    return max;
}

/**
 *  根据当前y坐标对应值计算y的实际高度
 *
 *  @param yValue 坐标对应值
 *
 *  @return 实际高度
 */
- (CGFloat)calcuYset:(CGFloat)yValue {
    NSNumber *min = [self.ySetNumber firstObject];
    NSNumber *max = [self.ySetNumber lastObject];
    
    CGFloat averHeight = kSheetHeight / (max.floatValue - min.floatValue);
    
    return kTopMargin + (max.floatValue - yValue) * averHeight;
}

#pragma mark 重写touch手势，控制数据的隐藏和显示
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    // 得到触摸点
    CGPoint location = [touch locationInView:self];
    int index = [self locationIndex:location.x];
    //根据索引得到点
    DBPoint *point = self.locations1[index];
    //显示十字
    [self concentrateOnPoint:point];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    // 得到触摸点
    CGPoint location = [touch locationInView:self];
    int index = [self locationIndex:location.x];
    //根据索引得到点
    DBPoint *point = self.locations1[index];
    //显示十字
    [self concentrateOnPoint:point];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setSubHidden:YES];
}

/**
 *  根据当前触摸到点的x坐标计算出点击区域的索引
 *
 *  @param locationX x坐标
 *
 *  @return 点击区域的索引
 */
- (int)locationIndex:(CGFloat)locationX {
    return (locationX - kLeftMargin + kXSectionWidth / 2) / kXSectionWidth;
}

#pragma mark lazy

- (UIView *)hengLine {
    if (!_hengLine) {
        _hengLine = [[UIView alloc]initWithFrame:CGRectMake(kLeftMargin, kTopMargin, kSheetWidth, 1)];
        _hengLine.backgroundColor = [UIColor redColor];
        [self addSubview:_hengLine];
        _hengLine.hidden = YES;
    }
    return _hengLine;
}

- (UIView *)shuLine {
    if (!_shuLine) {
        _shuLine = [[UIView alloc]initWithFrame:CGRectMake(kLeftMargin, kTopMargin, 1, kSheetHeight)];
        _shuLine.backgroundColor = [UIColor redColor];
        [self addSubview:_shuLine];
        _shuLine.hidden = YES;
    }
    return _shuLine;
}

- (UIView *)cirCle {
    if (!_cirCle) {
        _cirCle = [[UIView alloc]initWithFrame:CGRectMake(kLeftMargin, kTopMargin, 8, 8)];
        _cirCle.layer.borderWidth = 1.5;
        _cirCle.layer.borderColor = [UIColor redColor].CGColor;
        _cirCle.layer.cornerRadius = 4;
        _cirCle.layer.masksToBounds = YES;
        _cirCle.opaque = NO;
        _cirCle.backgroundColor = [UIColor whiteColor];
        [self addSubview:_cirCle];
        _cirCle.hidden = YES;
    }
    return _cirCle;
}

/**
 *  现在滑动到哪一个点
 *
 *  @param point 点
 */
- (void)concentrateOnPoint:(DBPoint *)point {
    [self setSubHidden:NO];
    CGRect frame = self.hengLine.frame;
    frame.origin.y = point.ySet;
    self.hengLine.frame = frame;
    frame = self.shuLine.frame;
    frame.origin.x = point.xSet;
    self.shuLine.frame = frame;
    self.cirCle.center = CGPointMake(point.xSet, point.ySet);
}


- (void)setSubHidden:(BOOL)hidden {
    self.hengLine.hidden = hidden;
    self.shuLine.hidden = hidden;
    self.cirCle.hidden = hidden;
}


@end

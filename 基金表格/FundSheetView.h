//
//  FundSheetView.h
//  基金表格
//
//  Created by 瑶波波 on 16/7/6.
//  Copyright © 2016年 dengbowc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FundSheetView : UIView

/**
 *  刷新视图方法，传入刷新视图的所有值，刷新表格
 *  @param dateSets     日期数组(横坐标)
 *  @param ySets        纵坐标数组1
 *  @param anotherYsets 纵坐标数组2（如果没有的话传nil），因为有时候会需要两条折现，所以加了这个参数
 *  @param isPercent    纵坐标是否是百分比，如果是，纵坐标要加上百分比符号
 */

- (void)refreshWithDateSets:(NSArray *)dateSets ySets:(NSArray *)ySets anotherYsets:(NSArray *)anotherYsets isPercent:(CGFloat)isPercent;

@end

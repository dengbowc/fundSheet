//
//  ViewController.m
//  基金表格
//
//  Created by 瑶波波 on 16/7/6.
//  Copyright © 2016年 dengbowc. All rights reserved.
//

#import "ViewController.h"
#import "FundSheetView.h"

@interface ViewController ()

@property (nonatomic,strong)FundSheetView *sheetView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FundSheetView *sheetView = [[FundSheetView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 205)];
    
    [self.view addSubview:sheetView];
    self.sheetView = sheetView;
    
    [self test];
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 *  测试数据
 */
- (void)test {
    int count = arc4random_uniform(100) + 10;
    NSMutableArray *ySets = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *anotherYsets = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *dateSets = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        CGFloat rand1 = rand() /((double)(RAND_MAX)/10);
        CGFloat rand2 = rand() /((double)(RAND_MAX)/10);
        [ySets addObject:@(rand1)];
        [anotherYsets addObject:@(rand2)];
        [dateSets addObject:@"06/21"];
    }
    
    [self.sheetView refreshWithDateSets:dateSets ySets:ySets anotherYsets:anotherYsets isPercent:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self test];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

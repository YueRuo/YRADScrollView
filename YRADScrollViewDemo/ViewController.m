//
//  ViewController.m
//  YRADScrollViewDemo
//
//  Created by 王晓宇 on 15/5/21.
//  Copyright (c) 2015年 YueRuo. All rights reserved.
//

#import "ViewController.h"
#import "YRADScrollView.h"

@interface ViewController ()<YRADScrollViewDataSource,YRADScrollViewDelegate>
@property (strong,nonatomic) NSMutableArray *nameArray;
@property (strong,nonatomic) NSMutableArray *colorArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _nameArray = [NSMutableArray arrayWithCapacity:20];
    int count = 3;
    for (int i=0; i<count; i++) {
        NSString *name = [NSString stringWithFormat:@"第%d页",i+1];
        [_nameArray addObject:name];
    }
    _colorArray = [NSMutableArray arrayWithCapacity:20];
    [_colorArray addObject:[UIColor colorWithRed:251/255.0 green:71/255.0 blue:70/255.0 alpha:1]];
    [_colorArray addObject:[UIColor colorWithRed:253/255.0 green:184/255.0 blue:37/255.0 alpha:1]];
    [_colorArray addObject:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:255/255.0 alpha:1]];
    [_colorArray addObject:[UIColor colorWithRed:84/255.0 green:223/255.0 blue:129/255.0 alpha:1]];
    
    YRADScrollView *adScrollView = [[YRADScrollView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 150)];
    adScrollView.dataSource = self;
    adScrollView.delegate = self;
//    adScrollView.cycleEnabled = NO;//如果设置为NO，则关闭循环滚动功能。
    [self.view addSubview:adScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark adViewDataSource
-(UIView *)viewForYRADScrollView:(YRADScrollView *)adScrollView atPage:(NSInteger)pageIndex{
    UILabel *label = [adScrollView dequeueReusableView];//先获取重用池里面的
    if (!label) {//如果重用池里面没有就创建
        label = [[UILabel alloc]init];
        label.font = [UIFont systemFontOfSize:30];
        label.textColor = [UIColor purpleColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
    label.text = [_nameArray objectAtIndex:pageIndex];
    label.backgroundColor = [_colorArray objectAtIndex:pageIndex];
    return label;
}
-(NSUInteger)numberOfViewsForYRADScrollView:(YRADScrollView *)adScrollView{
    return _nameArray.count;
}
#pragma mark adViewDelegate
-(void)adScrollView:(YRADScrollView *)adScrollView didClickedAtPage:(NSInteger)pageIndex{
    NSLog(@"-->>点击了:%@",[_nameArray objectAtIndex:pageIndex]);
}
-(void)adScrollView:(YRADScrollView *)adScrollView didScrollToPage:(NSInteger)pageIndex{
    NSLog(@"--->>当前已展示:%@",[_nameArray objectAtIndex:pageIndex]);
}
@end

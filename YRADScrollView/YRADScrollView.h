//
//  YRADScrollView.h
//  Demo
//
//  Created by 王晓宇 on 15-4-17.
//  Copyright (c) 2015年 YueRuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol YRADScrollViewDataSource;
@protocol YRADScrollViewDelegate;
@interface YRADScrollView : UIView
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL scrollEnabled; //default is YES
@property (assign, nonatomic) BOOL cycleEnabled;  //是否可循环滚动，default is YES
@property (weak, nonatomic) id<YRADScrollViewDataSource> dataSource;
@property (weak, nonatomic) id<YRADScrollViewDelegate> delegate;

- (id)dequeueReusableView; //重用池中取出一个控件
- (void)reloadData;

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;
- (void)scrollToNextPage:(BOOL)animated;
- (void)scrollToPrePage:(BOOL)animated;
@end

@protocol YRADScrollViewDataSource <NSObject>
/*!
 *	@brief	获取数据源，要注意的是，使用dequeueReusableView进行获取，如果返回为nil，则再进行创建，类似tableView早前的数据获取方式。
 *
 *	@param 	pageIndex 	第几页
 *
 *	@return	要展示的控件
 */
- (UIView *)viewForYRADScrollView:(YRADScrollView *)adScrollView atPage:(NSInteger)pageIndex;
- (NSUInteger)numberOfViewsForYRADScrollView:(YRADScrollView *)adScrollView;
@end

@protocol YRADScrollViewDelegate <NSObject>
@optional
- (void)adScrollView:(YRADScrollView *)adScrollView didClickedAtPage:(NSInteger)pageIndex;//点击了某一页
- (void)adScrollView:(YRADScrollView *)adScrollView didScrollToPage:(NSInteger)pageIndex;//滚动到某一页
- (void)adScrollView:(YRADScrollView *)adScrollView willDisplayView:(UIView *)view forPage:(NSInteger)pageIndex;//某页要出现了
- (void)adScrollView:(YRADScrollView *)adScrollView didEndDisplayView:(UIView *)view forPage:(NSInteger)pageIndex;//某页要消失了
@end

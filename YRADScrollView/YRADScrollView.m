//
//  YRADScrollView.m
//  Demo
//
//  Created by 王晓宇 on 15-4-17.
//  Copyright (c) 2015年 YueRuo. All rights reserved.
//

#import "YRADScrollView.h"

@interface YRADScrollView () <UIScrollViewDelegate> {
    NSMutableSet *_reusableViewSet;
    NSMutableDictionary *_onShowViewDictionary;
    UIScrollView *_scrollView;

    NSInteger _totalPageNumber;
    NSInteger _positionIndex;
}
@end
@implementation YRADScrollView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _reusableViewSet = [[NSMutableSet alloc] initWithCapacity:4];
        _onShowViewDictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
        _cycleEnabled = true;

        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = true;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        [self addSubview:_scrollView];

        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_scrollView addGestureRecognizer:gesture];
    }
    return self;
}

- (void)layoutSubviews {
    _scrollView.frame = self.bounds;
    [self reloadData];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark public

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollView.scrollEnabled = scrollEnabled;
}

- (BOOL)scrollEnabled {
    return _scrollView.scrollEnabled;
}

- (id)dequeueReusableView {
    id obj = [_reusableViewSet anyObject];
    if (obj) {
        [_reusableViewSet removeObject:obj];
    }
    return obj;
}

- (void)reloadData {
    if (self.dataSource) {
        if ([self.dataSource respondsToSelector:@selector(numberOfViewsForYRADScrollView:)]) {
            _totalPageNumber = [self.dataSource numberOfViewsForYRADScrollView:self];
        }
    }
    if (_onShowViewDictionary.count > 0) {
        [_reusableViewSet addObjectsFromArray:[_onShowViewDictionary allValues]];
        [_onShowViewDictionary removeAllObjects];
    }

    if (_cycleEnabled) {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 2000 * _totalPageNumber, 0);
        _positionIndex = 1000 * _totalPageNumber + self.currentPage;
        [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width, 0) animated:false];
    } else {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _totalPageNumber, 0);
        _positionIndex = self.currentPage;
        [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width, 0) animated:false];
    }

    if (_totalPageNumber > 0) {
        [self setPageToPositionIndex:_positionIndex];
    }
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated{
    NSInteger safePage = MIN(0, MAX(page, _totalPageNumber));
    if (safePage == _currentPage) {
        return;
    }
    NSInteger leftOffset = safePage-_currentPage;
    NSInteger rightOffset = safePage+_totalPageNumber-_currentPage;
    _positionIndex = _positionIndex+(ABS(leftOffset)<rightOffset?leftOffset:rightOffset);
    [self setPageToPositionIndex:_positionIndex];
    [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width, 0) animated:animated];
}
- (void)scrollToNextPage:(BOOL)animated{
    _positionIndex = _positionIndex+1;
    [self setPageToPositionIndex:_positionIndex];
    [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width, 0) animated:animated];
}
- (void)scrollToPrePage:(BOOL)animated{
    _positionIndex = _positionIndex-1;
    [self setPageToPositionIndex:_positionIndex];
    [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width, 0) animated:animated];
}

#pragma mark private

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (_delegate && [_delegate respondsToSelector:@selector(adScrollView:didClickedAtPage:)]) {
        [_delegate adScrollView:self didClickedAtPage:_currentPage];
    }
}

- (void)setPageToPositionIndex:(NSInteger)positionIndex {
    [self prepareViewAtPositionIndex:positionIndex];
    [self prepareViewAtPositionIndex:positionIndex - 1];
    [self prepareViewAtPositionIndex:positionIndex + 1];

    NSArray *allKeyArray = _onShowViewDictionary.allKeys;
    for (NSInteger i = allKeyArray.count - 1; i >= 0; i--) {
        NSNumber *key = [allKeyArray objectAtIndex:i];
        NSInteger index = [key integerValue];
        UIView *view = [_onShowViewDictionary objectForKey:key];
        if (ABS(index - positionIndex) > 1) {
            view.hidden = true;
            [_reusableViewSet addObject:view];
            [_onShowViewDictionary removeObjectForKey:key];
        } else {
            view.hidden = false;
        }
    }
    if ([_delegate respondsToSelector:@selector(adScrollView:willDisplayView:forPage:)]) {
        UIView *view = [_onShowViewDictionary objectForKey:@(positionIndex)];
        [_delegate adScrollView:self willDisplayView:view forPage:self.currentPage];
    }
}

- (NSInteger)pageFromPositionIndex:(NSInteger)positionIndex {
    if (_totalPageNumber == 0) {
        return 0;
    }
    NSInteger showIndex = positionIndex;
    if (positionIndex > 0) {
        showIndex = positionIndex % _totalPageNumber;
    } else if (positionIndex < 0) {
        showIndex = positionIndex % _totalPageNumber + _totalPageNumber;
    }
    return showIndex;
}

- (void)prepareViewAtPositionIndex:(NSInteger)positionIndex {
    if (!_cycleEnabled) {
        if (positionIndex < 0 || positionIndex > _totalPageNumber - 1) {
            return;
        }
    }
    NSInteger showIndex = [self pageFromPositionIndex:positionIndex];
    UIView *view = [_onShowViewDictionary objectForKey:@(positionIndex)];
    if (!view && self.dataSource && [self.dataSource respondsToSelector:@selector(viewForYRADScrollView:atPage:)]) {
        view = [self.dataSource viewForYRADScrollView:self atPage:showIndex];
        [_scrollView addSubview:view];
        [_onShowViewDictionary setObject:view forKey:@(positionIndex)];
    }
    view.frame = CGRectMake(positionIndex * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    view.hidden = false;
}


#pragma mark scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_totalPageNumber == 0) {
        return;
    }
    CGFloat pageWidth = _scrollView.frame.size.width;
    NSInteger page = (_scrollView.contentOffset.x / pageWidth) + 0.5;
    if (page != _positionIndex) {
        if (!_cycleEnabled) {
            if (page < 0 || page > _totalPageNumber - 1) {
                return;
            }
        }
        if ([_delegate respondsToSelector:@selector(adScrollView:didEndDisplayView:forPage:)]) {
            UIView *view = [_onShowViewDictionary objectForKey:@(_positionIndex)];
            [_delegate adScrollView:self didEndDisplayView:view forPage:_positionIndex];
        }
        _positionIndex = page;
        _currentPage = [self pageFromPositionIndex:_positionIndex];
        if (_delegate && [_delegate respondsToSelector:@selector(adScrollView:didScrollToPage:)]) {
            [_delegate adScrollView:self didScrollToPage:_currentPage];
        }

        [self setPageToPositionIndex:_positionIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_delegate adScrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_delegate && [_delegate respondsToSelector:@selector(adScrollView:didScrollToPage:)]) {
        [_delegate adScrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

@end

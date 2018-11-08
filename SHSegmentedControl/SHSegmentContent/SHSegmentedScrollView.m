//
//  SHSegmentedScrollView.m
//  SHSegmentedControlTableView
//
//  Created by angle on 2018/1/9.
//  Copyright © 2018年 angle. All rights reserved.
//

#import "SHSegmentedScrollView.h"


@interface IDCMSHScrollView : UIScrollView <UIGestureRecognizerDelegate>

@end

@implementation IDCMSHScrollView
#pragma mark -
#pragma mark   ==============处理和系统侧滑手势冲突的问题==============
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([self panBack:gestureRecognizer]) {
        return YES;
    }
    return NO;
    
}
- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    
    int location_X = 100;//侧滑左侧的响应距离
    
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            CGPoint location = [gestureRecognizer locationInView:self];
            if (point.x > 0 && location.x < location_X && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([self panBack:gestureRecognizer]) {
        return NO;
    }
    return YES;
    
}

@end



@interface SHSegmentedScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) IDCMSHScrollView *scrollView;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) BOOL scroll;

@end


@implementation SHSegmentedScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.scrollView];
        self.index = 0;
        self.scroll = YES;
    }
    return self;
}
- (IDCMSHScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[IDCMSHScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.showsVerticalScrollIndicator = YES;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

#pragma mark -
#pragma mark   ==============set==============
- (void)setTopView:(UIView *)topView {
    if (_topView != nil) {
        [_topView removeFromSuperview];
        _topView = nil;
    }
    _topView = topView;
    if (_topView) {
        _topView.frame = CGRectMake(0, 0, self.frame.size.width, _topView.frame.size.height);
        [self addSubview:_topView];
        if (self.barView != nil) {
            self.barView.frame = CGRectMake(0, _topView.frame.size.height, self.frame.size.width, self.barView.frame.size.height);
            self.scrollView.frame = CGRectMake(0, _topView.frame.size.height + self.barView.frame.size.height, self.frame.size.width, self.frame.size.height - _topView.frame.size.height - self.barView.frame.size.height);
        }else {
            self.scrollView.frame = CGRectMake(0, _topView.frame.size.height, self.frame.size.width, self.frame.size.height - _topView.frame.size.height);
        }
    }else {
        if (self.barView != nil) {
            self.barView.frame = CGRectMake(0, 0, self.frame.size.width, self.barView.frame.size.height);
            self.scrollView.frame = CGRectMake(0, self.barView.frame.size.height, self.frame.size.width, self.frame.size.height - self.barView.frame.size.height);
        }else {
            self.scrollView.frame = self.bounds;
        }
    }
}
- (void)setBarView:(UIView *)barView {
    if (_barView != nil) {
        [_barView removeFromSuperview];
        _barView = nil;
    }
    _barView = barView;
    if (_barView) {
        [self addSubview:_barView];
        if (self.topView != nil) {
            _barView.frame = CGRectMake(0, self.topView.frame.size.height, self.frame.size.width, _barView.frame.size.height);
            self.scrollView.frame = CGRectMake(0, self.topView.frame.size.height + _barView.frame.size.height, self.frame.size.width, self.frame.size.height - self.topView.frame.size.height - _barView.frame.size.height);
        }else {
            _barView.frame = CGRectMake(0, 0, self.frame.size.width, _barView.frame.size.height);
            self.scrollView.frame = CGRectMake(0, _barView.frame.size.height, self.frame.size.width, self.frame.size.height - _barView.frame.size.height);
        }
    }else {
        if (self.topView != nil) {
            self.scrollView.frame = CGRectMake(0, self.topView.frame.size.height, self.frame.size.width, self.frame.size.height - self.topView.frame.size.height);
        }else {
            self.scrollView.frame = self.bounds;
        }
    }
}
- (void)setFootView:(UIView *)footView {
    if (_footView != nil) {
        [_footView removeFromSuperview];
        _footView = nil;
    }
    _footView = footView;
    if (_footView) {
        [self addSubview:_footView];
        _footView.frame = CGRectMake(0, self.frame.size.height - _footView.frame.size.height, self.frame.size.width, _footView.frame.size.height);
        CGRect scrolFrame = self.scrollView.frame;
        scrolFrame.size.height -= _footView.frame.size.height;
        self.scrollView.frame = scrolFrame;
    }else {
        CGRect scrolFrame = self.scrollView.frame;
        scrolFrame.size.height = self.frame.size.height - scrolFrame.origin.y;
        self.scrollView.frame = scrolFrame;
    }
}
- (void)setTableViews:(NSArray *)tableViews {
    _tableViews = tableViews;
    if (_tableViews.count > 0) {
        if (self.scrollView.subviews.count > 0) {
            [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width * _tableViews.count, 0);
        for (NSInteger index = 0; index < tableViews.count; index++) {
            UIView *view = tableViews[index];
            view.frame = CGRectMake(self.frame.size.width * index, 0, self.frame.size.width, self.scrollView.frame.size.height);
            if ([view isKindOfClass:[UITableView class]] || [view isKindOfClass:[UICollectionView class]]) {
                [(UITableView *)view reloadData];
            }
            [self.scrollView addSubview:view];
        }
    }
}
- (void)setSegmentSelectIndex:(NSInteger)selectedIndex {
    if (selectedIndex != self.index && selectedIndex >= 0 && selectedIndex < self.tableViews.count) {
        CGPoint point = CGPointMake(selectedIndex * self.frame.size.width, 0);
        self.index = selectedIndex;
        self.scroll = NO;
        [self.scrollView setContentOffset:point animated:NO];
    }
}
#pragma mark -
#pragma mark   ==============数据刷新==============
//- (void)setRefreshHeader:(MJRefreshHeader *)refreshHeader {
//    _refreshHeader = refreshHeader;
//    if (refreshHeader) self.scrollView.mj_header = refreshHeader;
//}
- (NSInteger)selectedIndex {
    return self.index;
}
#pragma mark -
#pragma mark   ==============UIScrollViewDelegate==============
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.scroll) {
        if (self.delegateCell && [self.delegateCell respondsToSelector:@selector(scrollViewDidScrollIndex:)]) {
            NSInteger index = (NSInteger)((scrollView.contentOffset.x + self.frame.size.width * 0.5) / self.frame.size.width);
            if (index != self.index) {
                self.index = index;
                [self.delegateCell scrollViewDidScrollIndex:index];
            }
        }
    }
    self.scroll = YES;
}

@end

//
//  UINavigationScrollView.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/5/8.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "UINavigationScrollView.h"

@interface UINavigationScrollView () <UIScrollViewDelegate>
@property(assign, nonatomic) CGFloat frameWidth;
@property(assign, nonatomic) CGFloat scrollItemWidth;
@property(assign, nonatomic) CGFloat scrollHeight;

@property(strong, nonatomic) UIScrollView *navScrollView;
@property(strong, nonatomic) NSMutableArray *titleArray;
@property(strong, nonatomic) NSMutableArray *labelArray;
@property(assign, nonatomic) NSInteger count;
@end

@implementation UINavigationScrollView

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titles {
    self = [super initWithFrame:frame];
    if (self) {
        _frameWidth = frame.size.width;
        _scrollHeight = frame.size.height;
        _scrollItemWidth = 60.0;
        _titleArray = [NSMutableArray arrayWithArray:titles];
        _labelArray = [NSMutableArray array];
        _count = self.titleArray.count;
        _index = NSUIntegerMax;

        [self setupNavScrollView];
    }
    return self;
}

- (UIScrollView *)scrollView {
    return self.navScrollView;
}

- (UIScrollView *)navScrollView {
    if (_navScrollView == nil) {
        _navScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, self.scrollHeight)];
        _navScrollView.scrollEnabled = YES;
        _navScrollView.bounces = NO;
        _navScrollView.showsHorizontalScrollIndicator = NO;
        _navScrollView.directionalLockEnabled = YES;
        _navScrollView.backgroundColor = [UIColor lightGrayColor];
    }
    return _navScrollView;
}

- (void)setupNavScrollView {
    self.navScrollView.delegate = self;
    CGFloat scrollWith = MAX(self.frameWidth, (self.count - 1) * self.scrollItemWidth);

    self.navScrollView.contentSize = CGSizeMake(scrollWith, self.scrollHeight);

    for (NSInteger i = 0; i < self.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollItemWidth * i, 0.0, self.scrollItemWidth, self.scrollHeight)];
        label.backgroundColor = [UIColor whiteColor];
        label.text = (NSString *) self.titleArray[i];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = YES;
        label.tag = i;

        [self.labelArray addObject:label];
        [self.navScrollView addSubview:label];

        CGRect pageViewRect = self.navScrollView.bounds;
        CGFloat offset = pageViewRect.origin.x;
        [self.navScrollView setContentOffset:CGPointMake(offset, pageViewRect.origin.y) animated:NO];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tap.numberOfTapsRequired = 1;
        [label addGestureRecognizer:tap];
    }

    if (self.count > 0) {
        [self setIndex:0];
        // add view
        [self addSubview:self.navScrollView];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    NSUInteger index = (NSUInteger) gesture.view.tag;
    [self setIndex:index];
}

- (void)setIndex:(NSUInteger)index {
    if (self.count == 0 || index > self.count - 1 || index < 0) {
        return;
    }
    if (self.index != index) {
        if (self.index <= self.count - 1 && self.index >= 0) {
            // last index
            UILabel *lastLabel = self.labelArray[self.index];
            lastLabel.font = [UIFont systemFontOfSize:16];
            lastLabel.textColor = [UIColor blackColor];
        }
        _index = index;
        if (self.delegate != nil) {
            [self.delegate indexChanged:self.index];
        }
        // current index
        UILabel *curLabel = self.labelArray[self.index];
        curLabel.font = [UIFont systemFontOfSize:18];
        curLabel.textColor = [UIColor redColor];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
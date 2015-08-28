//
//  UINavigationScrollView.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/5/8.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "UINavigationScrollView.h"

CGFloat const FontSizeUnselect = 16;
CGFloat const FontSizeSelect = 16;
CGFloat const ScrollItemMinWidth = 56.0;
CGFloat const ScrollItemMargin = 8.0;

@interface UINavigationScrollView () <UIScrollViewDelegate>
@property(assign, nonatomic) CGFloat frameWidth;
@property(assign, nonatomic) CGFloat scrollItemWidth;
@property(assign, nonatomic) CGFloat scrollHeight;

@property(strong, nonatomic) UIScrollView *navScrollView;
@property(strong, nonatomic) NSMutableArray *titleArray;
@property(assign, nonatomic) NSInteger count;
@property(strong, nonatomic) UIColor *fontColorUnselect;
@property(strong, nonatomic) UIColor *fontColorSelect;
@end

@implementation UINavigationScrollView

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titles {
    self = [super initWithFrame:frame];
    if (self) {
        _frameWidth = frame.size.width;
        _scrollHeight = frame.size.height;
        _titleArray = [NSMutableArray arrayWithArray:titles];
        _count = self.titleArray.count;
        _index = NSUIntegerMax;

        _fontColorUnselect = [UIColor blackColor];
        _fontColorSelect = [UIColor redColor];

        if (self.count > 0) {
            [self setupNavScrollView];
        }
    }
    return self;
}

- (NSUInteger)titleCount {
    return self.titleArray.count;
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
    }
    return _navScrollView;
}

- (void)setBarTintColor:(UIColor *)color {
    _barTintColor = color;
    if (self.navScrollView != nil) {
        self.navScrollView.backgroundColor = self.barTintColor;
    }
}

- (void)setupNavScrollView {
    self.navScrollView.delegate = self;

    CGFloat scrollWidth = 0.0f;
    for (NSUInteger i = 0; i < self.count; i++) {
        NSString *title = (NSString *) self.titleArray[i];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i + 100;

        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:FontSizeUnselect];
        [button setTitleColor:self.fontColorUnselect forState:UIControlStateNormal];
        [button setTitleColor:self.fontColorSelect forState:UIControlStateSelected];

        // get right width of title.
// before IOS 7.0
//        CGFloat titleWidth = [title sizeWithFont:[UIFont systemFontOfSize:FontSizeUnselect]
//                               constrainedToSize:CGSizeMake(self.frameWidth, self.scrollHeight)
//                                   lineBreakMode:NSLineBreakByTruncatingTail].width;
// after IOS 7.0
//      method 1
//        CGFloat titleWidth = [title boundingRectWithSize:CGSizeMake(self.frameWidth, self.scrollHeight)
//                                                 options:NSStringDrawingTruncatesLastVisibleLine |
//                                                         NSStringDrawingUsesLineFragmentOrigin |
//                                                         NSStringDrawingUsesFontLeading
//                                              attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:FontSizeUnselect]}
//                                                 context:nil].size.width;
//      method 2
        CGFloat titleWidth = [title sizeWithAttributes:@{NSFontAttributeName : button.titleLabel.font}].width;

        titleWidth = MAX(titleWidth + ScrollItemMargin * 2, ScrollItemMinWidth);
        [button setFrame:CGRectMake(scrollWidth, 0.0, titleWidth, self.scrollHeight)];

        [button addTarget:self action:@selector(selectTitle:) forControlEvents:UIControlEventTouchUpInside];

        scrollWidth = scrollWidth + titleWidth;

        [self.navScrollView addSubview:button];
    }

    // set real width
    scrollWidth = MAX(self.frameWidth, scrollWidth);
    self.navScrollView.contentSize = CGSizeMake(scrollWidth, self.scrollHeight);

    if (self.count > 0) {
        // default is 0
        [self setIndex:0];
        // add view
        [self addSubview:self.navScrollView];
    }
}

- (void)selectTitle:(UIButton *)button {
    NSUInteger index = (NSUInteger) button.tag - 100;
    [self setIndex:index];
}

- (BOOL)highLightIndex:(NSUInteger)index {
    if (self.count == 0 || index > self.count - 1 || index < 0) {
        return NO;
    }

    if (self.index != index) {
        if (self.index <= self.count - 1 && self.index >= 0) {
            UIButton *lastButton = (UIButton *) [self.navScrollView viewWithTag:self.index + 100];
            lastButton.selected = NO;
        }

        _index = index;

        UIButton *curButton = (UIButton *) [self.navScrollView viewWithTag:self.index + 100];
        if (!curButton.selected) {
            curButton.selected = YES;

            [self adjustContentOffset:curButton];
        }
        return YES;
    }
    return NO;
}

- (void)setIndex:(NSUInteger)index {
    if ([self highLightIndex:index]) {
        if (self.delegate != nil) {
            [self.delegate indexChanged:self.index];
        }
    }
}

- (void)adjustContentOffset:(UIButton *)button {
    if (button.frame.origin.x < self.navScrollView.contentOffset.x) {
        // over left side
        CGFloat leftOffset = self.navScrollView.contentOffset.x - button.frame.origin.x;
        [self.navScrollView setContentOffset:CGPointMake(self.navScrollView.contentOffset.x - leftOffset, 0) animated:YES];
    } else if (button.frame.origin.x + button.frame.size.width > self.navScrollView.frame.size.width + self.navScrollView.contentOffset.x) {
        // over right side
        CGFloat rightOffset = button.frame.origin.x + button.frame.size.width - (self.navScrollView.frame.size.width + self.navScrollView.contentOffset.x);
        [self.navScrollView setContentOffset:CGPointMake(self.navScrollView.contentOffset.x + rightOffset, 0) animated:YES];
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

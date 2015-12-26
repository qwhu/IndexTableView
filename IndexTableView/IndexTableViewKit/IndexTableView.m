//
//  IndexTableView.m
//  IndexTableView
//
//  Created by HQW on 15/12/18.
//  Copyright © 2015年 HQW. All rights reserved.
//

#import "IndexTableView.h"
#import "IndexBar.h"

#define HIGHLIGHT_CELLHEIGHT    50
#define SURNAME_CELLHEIGHT      35
#define HIGHLIGHT_FONTSIZE      30
#define SURNAME_FONTSIZE        20

@interface IndexTableView () <IndexBarDelegate, UIScrollViewDelegate> {
    BOOL        _isTouchBegan;
    NSString    *_currentSectionTitle;
    NSArray     *_currentSurnames;
    BOOL        _isShowSurname;
    NSArray     *_indexTitles;
}

@property (nonatomic, strong) UITableView *internalTableView;
@property (nonatomic, strong) UIView *highlightView;
@property (nonatomic, strong) NSArray *highlightLabels;
@property (nonatomic, strong) IndexBar *indexBar;
@property (nonatomic, strong) UIScrollView *surnameView;

@end

@implementation IndexTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.internalTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.internalTableView.showsVerticalScrollIndicator = NO;
        self.internalTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.internalTableView];
        [self setupIndexBar];
        [self setupHighlightView];
        [self setupSurnameView];
    }
    return self;
}

- (void)setupIndexBar {
    self.indexBar = [[IndexBar alloc] initWithFrame:(CGRect){CGRectGetWidth(self.bounds) - 20, 10, 20, CGRectGetHeight(self.bounds) - 20}];
    self.indexBar.delegate = self;
    [self addSubview:self.indexBar];
    _indexTitles = @[@"☆", @"#",
                     @"A", @"B", @"C", @"D", @"E", @"F", @"G",
                     @"H", @"I", @"J", @"K", @"L", @"M", @"N",
                     @"O", @"P", @"Q", @"R", @"S", @"T", @"U",
                     @"V", @"W", @"X", @"Y", @"Z"];
    self.indexBar.indexes = _indexTitles;
}

- (void)setupHighlightView {
    self.highlightView = [[UIView alloc] initWithFrame:(CGRect){(self.bounds.size.width - HIGHLIGHT_CELLHEIGHT) / 2, (self.bounds.size.height - HIGHLIGHT_CELLHEIGHT * 7) / 2, HIGHLIGHT_CELLHEIGHT, HIGHLIGHT_CELLHEIGHT * 7}];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int32_t i = 0; i < 7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){0, HIGHLIGHT_CELLHEIGHT * i, HIGHLIGHT_CELLHEIGHT, HIGHLIGHT_CELLHEIGHT}];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blueColor];
        label.font = [UIFont systemFontOfSize:HIGHLIGHT_FONTSIZE];
        label.tag = i;
        if(i == 3) {
            label.backgroundColor = [UIColor blueColor];
            label.font = [UIFont boldSystemFontOfSize:HIGHLIGHT_FONTSIZE];
            label.textColor = [UIColor whiteColor];
            label.layer.cornerRadius = 5;
            label.layer.masksToBounds = YES;
        }
        if(i == 2 || i == 4) {
            label.alpha = 0.7f;
        }
        else if(i == 1 || i == 5) {
            label.alpha = 0.4f;
        }
        else if(i == 0 || i == 6) {
            label.alpha = 0.1f;
        }
        [self.highlightView addSubview:label];
        [tempArray addObject:label];
    }
    _highlightLabels = [tempArray copy];
    [self addSubview:self.highlightView];
    self.highlightView.hidden = YES;
}

- (void)setupSurnameView {
    self.surnameView = [[UIScrollView alloc] initWithFrame:(CGRect){self.bounds.size.width - (SURNAME_CELLHEIGHT*2 + 4) - 25, 0, SURNAME_CELLHEIGHT*2 + 4, 0}];
    self.surnameView.showsHorizontalScrollIndicator = NO;
    self.surnameView.showsVerticalScrollIndicator = NO;
    self.surnameView.contentSize = CGSizeMake(0, 0);
    self.surnameView.delegate = self;
    [self addSubview:self.surnameView];
}

- (void)setDataSource:(id<IndexTableViewDataSource>)dataSource {
    _dataSource = dataSource;
    self.internalTableView.dataSource = dataSource;
}

- (void)setDelegate:(id<IndexTableViewDelegate>)delegate {
    _delegate = delegate;
    self.internalTableView.delegate = delegate;
}

- (void)setHighlightText:(NSString *)title {
    _currentSectionTitle = title;
    NSInteger index = -1;
    if([self.indexBar.indexes containsObject:title]) {
        index = [self.indexBar.indexes indexOfObject:title];
    }
    if(index >= 0) {
        NSInteger indexCount = [self.indexBar.indexes count];
        for (UILabel *label in _highlightLabels) {
            if(label.tag == 0) {
                label.text = index - 3 >= 0 ? [self.indexBar.indexes objectAtIndex:index - 3] : @"";
            }
            else if(label.tag == 1) {
                label.text = index - 2 >= 0 ? [self.indexBar.indexes objectAtIndex:index - 2] : @"";
            }
            else if(label.tag == 2) {
                label.text = index - 1 >= 0 ? [self.indexBar.indexes objectAtIndex:index - 1] : @"";
            }
            else if(label.tag == 3) {
                label.text = [self.indexBar.indexes objectAtIndex:index];
            }
            else if(label.tag == 4) {
                label.text = index + 1 < indexCount ? [self.indexBar.indexes objectAtIndex:index + 1] : @"";
            }
            else if(label.tag == 5) {
                label.text = index + 2 < indexCount ? [self.indexBar.indexes objectAtIndex:index + 2] : @"";
            }
            else if(label.tag == 6) {
                label.text = index + 3 < indexCount ? [self.indexBar.indexes objectAtIndex:index + 3] : @"";
            }
        }
    }
}

- (void)hideSurnameView {
    if(_isShowSurname && !self.surnameView.hidden) {
        _isShowSurname = NO;
        [UIView animateWithDuration:0.3f animations:^{
            self.surnameView.alpha = 0;
        } completion:^(BOOL finished) {
            if(!_isShowSurname) {
                self.surnameView.hidden = YES;
            }
        }];
    }
}

- (void)resetTableViewIndexHeight {
    if(self.internalTableView.tableHeaderView) {
        CGFloat headerHeight = CGRectGetHeight(self.internalTableView.tableHeaderView.frame);
        CGRect frame =  CGRectMake(CGRectGetWidth(self.frame) - 20, headerHeight + 10, 20, CGRectGetHeight(self.frame) - 20 - headerHeight);
        self.indexBar.frame = frame;
        self.indexBar.indexes = _indexTitles;
    }
}

- (void)reloadData {
    [self.internalTableView reloadData];
}

#pragma mark - ContactTableViewIndexDelegate

- (void)indexBar:(IndexBar *)indexBar didSelectSectionAtIndex:(NSInteger)index sectionTitle:(NSString *)title {
    if(title.length <= 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(indexTableView:didSelectSection:)]) {
        [self.delegate indexTableView:self didSelectSection:title];
    }
}

- (void)indexBarTouchesBegan:(IndexBar *)indexBar {
    _isTouchBegan = YES;
    _isShowSurname = NO;
    self.surnameView.hidden = YES;
}
- (void)indexBarTouchesMoved:(IndexBar *)indexBar {
    if(self.highlightView.hidden) {
        self.highlightView.alpha = 1;
        self.highlightView.hidden = NO;
    }
}

- (void)indexBartTouchesEnd:(IndexBar *)indexBar {
    _isTouchBegan = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.highlightView.alpha = 0;
    } completion:^(BOOL finished) {
        if(!_isTouchBegan) {
            self.highlightView.hidden = YES;
        }
    }];
    if ([self.dataSource respondsToSelector:@selector(indexTableView:surnamesForSection:)]) {
        _currentSurnames = [self.dataSource indexTableView:self surnamesForSection:_currentSectionTitle];
        [self updateSurnameView];
    }
}

- (void)updateSurnameView {
    if([_currentSurnames count] <= 0) {
        self.surnameView.hidden = YES;
        return;
    }
    _isShowSurname = YES;
    self.surnameView.alpha = 1;
    self.surnameView.hidden = NO;
    [self.surnameView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int32_t i = 0; i < [_currentSurnames count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){(i%2)*(SURNAME_CELLHEIGHT + 4), (i/2)*(SURNAME_CELLHEIGHT + 4), SURNAME_CELLHEIGHT, SURNAME_CELLHEIGHT}];
        label.backgroundColor = [UIColor blueColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:SURNAME_FONTSIZE];
        label.layer.cornerRadius = 5;
        label.layer.masksToBounds = YES;
        label.text = [_currentSurnames objectAtIndex:i];
        label.userInteractionEnabled = YES;
        [self.surnameView addSubview:label];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSurnameView:)];
        [label addGestureRecognizer:tapGesture];
    }
    
    CGRect frame = self.surnameView.frame;
    if([_currentSurnames count] > 1) {
        frame.origin.x = self.bounds.size.width - (SURNAME_CELLHEIGHT*2 + 4) - 25;
    }
    else {
        frame.origin.x = self.bounds.size.width - SURNAME_CELLHEIGHT - 25;
    }
    if ([_currentSurnames count]%2 > 0) {
        frame.size.height = ([_currentSurnames count]/2 + 1)*(SURNAME_CELLHEIGHT + 4) - 4;
    }
    else {
        frame.size.height = ([_currentSurnames count]/2)*(SURNAME_CELLHEIGHT + 4) - 4;
    }
    self.surnameView.contentSize = CGSizeMake(0, frame.size.height);
    if(frame.size.height > CGRectGetHeight(self.frame) - 10) {
        frame.size.height = CGRectGetHeight(self.frame) - 10;
    }
    self.surnameView.frame = frame;
    
    CGPoint center = self.surnameView.center;
    CGRect indexFrame = [self.indexBar getIndexTitleFrame:_currentSectionTitle];
    CGRect currentViewFrame = [self convertRect:indexFrame fromView:self.indexBar];
    center.y = currentViewFrame.origin.y + currentViewFrame.size.height/2;
    self.surnameView.center = center;
    
    frame = self.surnameView.frame;
    if(frame.origin.y < 5) {
        frame.origin.y = 5;
    }
    else if(frame.origin.y > self.bounds.size.height - frame.size.height - 5) {
        frame.origin.y = self.bounds.size.height - frame.size.height - 5;
    }
    self.surnameView.frame = frame;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSurnameView) object:nil];
    [self performSelector:@selector(hideSurnameView) withObject:nil afterDelay:3.0f];
}

- (void)tapSurnameView:(UITapGestureRecognizer *)gesture {
    UIView *tapView = gesture.view;
    if([tapView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)tapView;
        NSString *surname = label.text;
        if ([self.delegate respondsToSelector:@selector(indexTableView:didSelectSurname:sectionTitle:)]) {
            [self.delegate indexTableView:self didSelectSurname:surname sectionTitle:_currentSectionTitle];
        }
    }
    self.surnameView.hidden = YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.surnameView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSurnameView) object:nil];
    }
}

@end

//
//  IndexBar.m
//  IndexTableView
//
//  Created by HQW on 15/12/18.
//  Copyright © 2015年 HQW. All rights reserved.
//

#import "IndexBar.h"

@interface IndexBar () {
    NSArray *_textLabelArray;
    NSString *_highlightTitle;
    UIColor *_foregroundColor;
}

@end

@implementation IndexBar

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _foregroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [self updateSubviews];
}

- (void)setIndexes:(NSArray *)indexes {
    _indexes = indexes;
    [self updateSubviews];
}

- (void)updateSubviews {
    if([self.indexes count] <= 0) {
        return;
    }
    [_textLabelArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat letterHeight = CGRectGetHeight(self.frame)/[_indexes count];
    CGFloat fontSize = letterHeight * 0.75;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self.indexes enumerateObjectsUsingBlock:^(NSString *letter, NSUInteger idx, BOOL *stop) {
        CGFloat originY = idx * letterHeight;
        UILabel *label = [self textLabelWithSize:fontSize
                                          content:letter
                                            frame:CGRectMake((CGRectGetWidth(self.frame) - letterHeight)/2, originY, letterHeight, letterHeight)];
        [self addSubview:label];
        [tempArray addObject:label];
    }];
    _textLabelArray = [tempArray copy];
}

- (UILabel *)textLabelWithSize:(CGFloat)size content:(NSString *)content frame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:size];
    [label setTextColor:_foregroundColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = content;
    return label;
}

- (void)updateTextLabels {
    for (UILabel *label in _textLabelArray) {
        if(_highlightTitle && [_highlightTitle isEqualToString:label.text]) {
            [label setBackgroundColor:[UIColor blueColor]];
            [label setTextColor:[UIColor whiteColor]];
        }
        else {
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextColor:_foregroundColor];
        }
    }
}

- (CGRect)getIndexTitleFrame:(NSString *)title {
    CGRect frame = CGRectZero;
    for (UILabel *label in _textLabelArray) {
        if([title isEqualToString:label.text]) {
            frame = label.frame;
            break;
        }
    }
    return frame;
}

- (void)setHighlightIndexTitle:(NSString *)title {
    if([title isEqualToString:_highlightTitle]) {
        return;
    }
    _highlightTitle = title;
    [self updateTextLabels];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _foregroundColor = [UIColor grayColor];
    [self updateTextLabels];
    [self sendEventToDelegate:event];
    [self.delegate indexBarTouchesBegan:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self sendEventToDelegate:event];
    [self.delegate indexBarTouchesMoved:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    _foregroundColor = [UIColor lightGrayColor];
    [self updateTextLabels];
    [self.delegate indexBartTouchesEnd:self];
}

- (void)sendEventToDelegate:(UIEvent*)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat letterHeight = CGRectGetHeight(self.frame)/[_indexes count];
    NSInteger idx = ((NSInteger) floorf(point.y) / letterHeight);
    if (idx < 0 || idx >= [self.indexes count]) {
        return;
    }
    [self.delegate indexBar:self didSelectSectionAtIndex:idx sectionTitle:self.indexes[idx]];
}

@end

//
//  IndexBar.h
//  IndexTableView
//
//  Created by HQW on 15/12/18.
//  Copyright © 2015年 HQW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndexBar;

@protocol IndexBarDelegate <NSObject>

@required

- (void)indexBar:(IndexBar *)indexBar didSelectSectionAtIndex:(NSInteger)index sectionTitle:(NSString *)title;
- (void)indexBarTouchesBegan:(IndexBar *)indexBar;
- (void)indexBarTouchesMoved:(IndexBar *)indexBar;
- (void)indexBartTouchesEnd:(IndexBar *)indexBar;

@end

@interface IndexBar : UIView

@property (nonatomic, strong) NSArray *indexes;
@property (nonatomic, weak) id<IndexBarDelegate> delegate;

- (void)setHighlightIndexTitle:(NSString *)title;
- (CGRect)getIndexTitleFrame:(NSString *)title;

@end

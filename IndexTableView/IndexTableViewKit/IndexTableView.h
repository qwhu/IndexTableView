//
//  IndexTableView.h
//  IndexTableView
//
//  Created by HQW on 15/12/18.
//  Copyright © 2015年 HQW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexBar.h"

@class IndexTableView;

@protocol IndexTableViewDataSource <UITableViewDataSource>

@optional

//section下所有的姓氏
- (NSArray *)indexTableView:(IndexTableView *)tableView surnamesForSection:(NSString *)sectionTitle;

@end

@protocol IndexTableViewDelegate <UITableViewDelegate>

@optional

- (void)indexTableView:(IndexTableView *)tableView didSelectSection:(NSString *)title;
- (void)indexTableView:(IndexTableView *)tableView didSelectSurname:(NSString *)surname sectionTitle:(NSString *)sectionTitle;

@end

@interface IndexTableView : UIView

@property (nonatomic, readonly, strong) UITableView *internalTableView;
@property (nonatomic, readonly, strong) IndexBar *indexBar;
@property (nonatomic, weak) id<IndexTableViewDataSource> dataSource;
@property (nonatomic, weak) id<IndexTableViewDelegate> delegate;

- (void)setHighlightText:(NSString *)title;
- (void)hideSurnameView;
- (void)reloadData;

@end

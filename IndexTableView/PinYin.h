//
//  PinYin.h
//  IndexTableView
//
//  Created by HQW on 15/12/21.
//  Copyright © 2015年 HQW. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  OTHER_KEY  '#'

@interface PinYin : NSObject

- (NSString*)getChineseFirstLetterByString:(NSString *)str;
- (NSString*)getChineseFirstLetter:(unichar)hanzi;

@end


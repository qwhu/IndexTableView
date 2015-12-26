//
//  PinYin.m
//  IndexTableView
//
//  Created by HQW on 15/12/21.
//  Copyright © 2015年 HQW. All rights reserved.
//

#import "PinYin.h"

@interface PinYin () {
    NSString *_pinyinTable;
}

@end

@implementation PinYin

#define HANZI_START 19968
#define HANZI_COUNT 20902
#define HANZI_TABLE_FILE  @"pinyin"
#define HANZI_TABLE_TYPE  @"data"

- (id)init {
    self = [super init];
    if(self) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:HANZI_TABLE_FILE ofType:HANZI_TABLE_TYPE];
        _pinyinTable = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    }
    return self;
}

- (NSString*)getChineseFirstLetterByString:(NSString *)str {
    if (str.length > 0) {
        return [self getChineseFirstLetter:[str characterAtIndex:0]];
    }
    else {
        return [NSString stringWithFormat:@"%c", OTHER_KEY];
    }
}

- (NSString*)getChineseFirstLetter:(unichar)hanzi {
    NSString* re = nil;
    int index = hanzi - HANZI_START;
    if(index >= 0 && index <= HANZI_COUNT && _pinyinTable) {
        if (index < [_pinyinTable length]) {
            re = [_pinyinTable substringWithRange:NSMakeRange(index, 1)];
        }
    }
    unichar letter;
    if(re) {
        letter = [re characterAtIndex:0];
    }
    else {
        letter = hanzi;
    }
    if(letter >= 'a' && letter <= 'z') {
        letter += 'A' - 'a';
    }
    else if(letter < 'A' || letter > 'Z') {
        letter = OTHER_KEY;
    }
    return [NSString stringWithFormat:@"%c", letter];
}

@end

//
//  ViewController.m
//  IndexTableView
//
//  Created by HQW on 15/12/18.
//  Copyright © 2015年 HQW. All rights reserved.
//

#import "ViewController.h"
#import "IndexTableView.h"
#import "PinYin.h"
#import <AddressBook/AddressBook.h>

@interface ViewController () <IndexTableViewDataSource, IndexTableViewDelegate> {
    NSInteger _currentSection;
}

@property (nonatomic, strong) IndexTableView *contactsTableView;
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *sortKeys;
@property (nonatomic, strong) NSDictionary *contactDic;

@end

@implementation ViewController

- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.origin.y = 0;
    frame.size.height -= self.navigationController.navigationBar.frame.size.height;
    self.view = [[UIView alloc] initWithFrame:frame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = NSLocalizedString(@"Contacts", nil);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _contactsTableView = [[IndexTableView alloc] initWithFrame:self.view.bounds];
    _contactsTableView.backgroundColor = [UIColor greenColor];
    _contactsTableView.dataSource = self;
    _contactsTableView.delegate = self;
    _contactsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_contactsTableView];
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self loadAllContacts];
            }
            else {
                // Waring
            }
        });
    }
    else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self loadAllContacts];
    }
    else {
        // Warning
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadAllContacts {
    PinYin *pinyin = [[PinYin alloc] init];
    NSMutableDictionary *tempContactDic = [[NSMutableDictionary alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *allPeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex count = ABAddressBookGetPersonCount(addressBook);
    for ( int i = 0; i < count; i++) {
        ABRecordRef ref = (__bridge ABRecordRef)allPeople[i];
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonMiddleNameProperty);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSString *fullName = [NSString stringWithFormat:@"%@%@%@", lastName ? lastName : @"", middleName ? middleName : @"" , firstName ? firstName : @""];
        if(fullName != nil && [fullName length] > 0) {
            NSString *groupKey = [pinyin getChineseFirstLetterByString:fullName];
            NSMutableArray *subContacts = [tempContactDic objectForKey:groupKey];
            if(subContacts == nil) {
                subContacts = [[NSMutableArray alloc] init];
                [tempContactDic setObject:subContacts forKey:groupKey];
            }
            [subContacts addObject:fullName];
        }
    }
    _contactDic = tempContactDic;
    NSMutableArray *keys = [[tempContactDic allKeys] mutableCopy];
    [keys sortUsingSelector:@selector(compare:)];
    _sortKeys = keys;
    [_contactsTableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sortKey = [_sortKeys objectAtIndex:section];
    NSArray *subContacts = [_contactDic objectForKey:sortKey];
    return [subContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableViewCell"];
    }
    NSString *sortKey = [_sortKeys objectAtIndex:indexPath.section];
    NSString *fullName = [[_contactDic objectForKey:sortKey] objectAtIndex:indexPath.row];
    cell.textLabel.text = fullName;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sortKeys count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_sortKeys objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(indexPath.section != _currentSection) {
            if([[tableView visibleCells] count] > 0) {
                NSUInteger section = [[tableView indexPathForCell:[[tableView visibleCells] objectAtIndex:0]] section];
                if(_currentSection != section) {
                    _currentSection = section;
                    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
                    [_contactsTableView.indexBar setHighlightIndexTitle:sectionTitle];
                }
            }
        }
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ContactTableViewDataSource & ContactTableViewDelegate

- (NSArray *)indexTableView:(IndexTableView *)tableView surnamesForSection:(NSString *)sectionTitle {
    NSInteger index = -1;
    if([_sortKeys containsObject:sectionTitle]) {
        index = [_sortKeys indexOfObject:sectionTitle];
    }
    if(index >= 0) {
        NSArray *items = _contactDic[sectionTitle];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id item in items) {
            if([item isKindOfClass:[NSString class]]) {
                NSString *fullName = (NSString *)item;
                if(fullName.length > 0) {
                    NSString *surname = [fullName substringWithRange:NSMakeRange(0, 1)];
                    if(![tempArray containsObject:surname]) {
                        [tempArray addObject:surname];
                    }
                }
            }
        }
        return [tempArray copy];
    }
    else {
        return nil;
    }
}

- (void)indexTableView:(IndexTableView *)tableView didSelectSection:(NSString *)title {
    if(title.length <= 0) {
        return;
    }
    NSInteger tableIndex = -1;
    if([title isEqualToString:@"☆"]) {
        tableIndex = 0;
    }
    else {
        tableIndex = [_sortKeys indexOfObject:title];
    }
    if(tableIndex >= 0 && tableIndex < [_sortKeys count]) {
        [tableView.internalTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:tableIndex]
                                           atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [tableView setHighlightText:title];
    }
}

- (void)indexTableView:(IndexTableView *)tableView didSelectSurname:(NSString *)surname sectionTitle:(NSString *)sectionTitle {
    if(![_sortKeys containsObject:sectionTitle]) {
        return;
    }
    NSInteger sectionIndex = [_sortKeys indexOfObject:sectionTitle];
    NSInteger rowIndex = 0;
    NSArray *items = _contactDic[sectionTitle];
    for (int32_t i = 0; i < items.count; i++) {
        id item = [items objectAtIndex:i];
        if([item isKindOfClass:[NSString class]]) {
            NSString *fullName = item;
            if(fullName.length > 0 && [fullName hasPrefix:surname])
            {
                rowIndex = i;
                break;
            }
        }
    }
    [tableView.internalTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]
                              atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

@end

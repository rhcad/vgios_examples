//
//  WDSettingsController.m
//  Inkpad
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2011-2013 Steve Sprang
//

#import "WDSettingsController.h"
#import "GiViewHelper.h"

@implementation WDSettingsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (!self) {
        return nil;
    }
    
    self.navigationItem.title = NSLocalizedString(@"Settings", @"Settings");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(done:)];
    }
    
    NSString *settingsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Settings.plist"];
    configuration_ = [NSArray arrayWithContentsOfFile:settingsPath];
    hlp_ = [GiViewHelper sharedInstance];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)loadView
{
    CGRect frame = CGRectMake(0, 0, 300, 1 * 28 + 11 * 44);
    
    table_ = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    table_.delegate = self;
    table_.dataSource = self;
    table_.sectionHeaderHeight = 0;
    table_.sectionFooterHeight = 0;
    table_.separatorColor = [UIColor lightGrayColor];
    self.view = table_;
#ifdef __IPHONE_7_0
    table_.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.preferredContentSize = self.view.frame.size;
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 28;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return configuration_.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = configuration_[section][@"Items"];
    
    return items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return configuration_[section][@"Title"];
}

- (NSString *) localizedTitleForKey:(NSString *)key
{
    // we could duplicate the Settings.plist for every localization, but this seems less error prone
    static NSMutableDictionary *map_ = nil;
    if (!map_) {
        map_ = [NSMutableDictionary dictionary];
        map_[@"Snap Enabled"]           = NSLocalizedString(@"Snap Enabled", @"Snap Enabled");
        map_[@"Snap to Vertext"]        = NSLocalizedString(@"Snap to Vertext", @"Snap to Vertext");
        map_[@"Snap to Center"]         = NSLocalizedString(@"Snap to Center", @"Snap to Center");
        map_[@"Snap to Midpoint"]       = NSLocalizedString(@"Snap to Midpoint", @"Snap to Midpoint");
        map_[@"Snap to Quadrant"]       = NSLocalizedString(@"Snap to Quadrant", @"Snap to Quadrant");
        map_[@"Snap to Edge"]           = NSLocalizedString(@"Snap to Edge", @"Snap to Edge");
        map_[@"Snap to Perp"]           = NSLocalizedString(@"Snap to Perp", @"Snap to Perp");
        map_[@"Snap to Intersection"]   = NSLocalizedString(@"Snap to Intersection", @"Snap to Intersection");
        map_[@"Context Actions"]        = NSLocalizedString(@"Context Actions", @"Context Actions");
        map_[@"Show Magnifier"]         = NSLocalizedString(@"Show Magnifier", @"Show Magnifier");
    }
    
    return map_[key];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *cellDescription = configuration_[indexPath.section][@"Items"][indexPath.row];
    
    if (cell == nil) {
        UITableViewCellStyle cellStyle = [cellDescription[@"Type"] isEqualToString:@"Dimensions"] ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
        cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self localizedTitleForKey:cellDescription[@"Title"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cellDescription[@"Type"] isEqualToString:@"Switch"]) {
        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = mySwitch;
        
        mySwitch.onTintColor = [UIColor colorWithRed:0.0f green:(118.0f / 255.0f) blue:1.0f alpha:1.0f];
        [mySwitch setOn:[(hlp_.options)[cellDescription[@"Key"]] boolValue]];
        [mySwitch addTarget:self action:NSSelectorFromString(cellDescription[@"Selector"]) forControlEvents:UIControlEventValueChanged];
    } else if ([cellDescription[@"Type"] isEqualToString:@"TextField"]) {
    }
    
    return cell;
}

- (void) takeSnapEnabledFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"snapEnabled"];
}
                                                             
- (void) takeSnapVertextFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"snapVertext"];
}

- (void) takeSnapCenterFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"snapCenter"];
}

- (void) takeSnapMidPointFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"snapMidPoint"];
}

- (void) takeSnapQuadrantFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"snapQuadrant"];
}

- (void) takeSnapNearFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"snapNear"];
}

- (void) takeSnapPerpFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"snapPerp"];
}

- (void) takeSnapCrossFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"snapCross"];
}

- (void) takeContextActionEnabledFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"contextActionEnabled"];
}

- (void) takeShowMagnifierFrom:(id)sender {
    UISwitch    *mySwitch = (UISwitch *)sender;
    [hlp_ setOption:@(mySwitch.isOn) forKey:@"showMagnifier"];
}

@end

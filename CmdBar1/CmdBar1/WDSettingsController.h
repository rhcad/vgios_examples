//
//  WDSettingsController.h
//  Inkpad
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2011-2013 Steve Sprang
//

#import <UIKit/UIKit.h>

@class WDDrawing;
@class GiViewHelper;

@interface WDSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView    *table_;
    NSArray                 *configuration_;
    GiViewHelper            *hlp_;
}

@end

//  GiCanvasView.h
//
//  Created by Zhang Yungui on 14-10-14.
//  Copyright (c) 2014 https://github.com/rhcad
//

#import "GiPaintViewXIB.h"

@interface GiCanvasView : UIView<GiPaintViewDelegate, UIPopoverControllerDelegate>

@property(nonatomic, strong)    GiPaintViewXIB  *paintView;
@property(nonatomic, readonly)  GiViewHelper    *helper;
@property(nonatomic, assign)    NSInteger       flags;      // GIViewFlags
@property(nonatomic, assign)    NSString        *command;

- (void)showSettingsMenu:(id)sender;

@end

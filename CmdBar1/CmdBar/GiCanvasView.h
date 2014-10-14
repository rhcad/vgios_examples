//  GiCanvasView.h
//
//  Created by Zhang Yungui on 14-10-11.
//  Copyright (c) 2014 https://github.com/touchvg
//

#import "GiPaintViewXIB.h"

@interface GiCanvasView : UIView<GiPaintViewDelegate, UIPopoverControllerDelegate>

@property(nonatomic, strong)    GiPaintViewXIB  *paintView;
@property(nonatomic, readonly)  GiViewHelper    *helper;
@property(nonatomic, assign)    NSInteger       flags;      // GIViewFlags
@property(nonatomic, assign)    NSString        *command;

@property(nonatomic, strong)    NSArray         *tools;
@property(nonatomic, weak)      NSDictionary    *activeTool;

- (void)setActiveTool:(NSDictionary *)tool from:(id)sender;
- (void)showSettingsMenu:(id)sender;

@end

// notifications
extern NSString *WDActiveToolDidChange;
extern NSString *WDCanvasBeganTrackingTouches;

//  GiCanvasView.h
//
//  Created by Zhang Yungui on 14-10-11.
//  Copyright (c) 2014 https://github.com/touchvg
//

#import "GiPaintViewXIB.h"

@interface GiCanvasView : GiPaintViewXIB

@property(nonatomic, strong)    NSArray         *tools;
@property(nonatomic, weak)      NSDictionary    *activeTool;

@end

// notifications
extern NSString *WDActiveToolDidChange;
extern NSString *WDCanvasBeganTrackingTouches;

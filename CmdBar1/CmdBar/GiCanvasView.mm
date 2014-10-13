//  GiCanvasView.mm
//
//  Created by Zhang Yungui on 14-10-11.
//  Copyright (c) 2014 https://github.com/touchvg
//

#import "GiCanvasView.h"
#import "WDPalette.h"
#import "WDToolView.h"
#import "WDToolButton.h"
#import "GiViewHelper.h"

NSString *WDActiveToolDidChange = @"WDActiveToolDidChange";
NSString *WDCanvasBeganTrackingTouches = @"WDCanvasBeganTrackingTouches";

@interface GiCanvasView () {
    WDPalette               *toolPalette_;
}

@end

@implementation GiCanvasView

@synthesize paintView, helper;
@synthesize flags, command;
@synthesize tools = tools_;
@synthesize activeTool;

- (NSInteger)flags { return self.helper.view.flags; }
- (void)setFlags:(NSInteger)f { self.helper.view.flags = f; }
- (NSString *)command { return self.helper.command; }
- (void)setCommand:(NSString *)c { self.helper.command = c; }

- (GiViewHelper *)helper {
    if (!self.paintView) {
        self.paintView = [[GiPaintViewXIB alloc]initWithFrame:self.bounds];
        self.paintView.autoresizingMask = 0xFF;
        [self addSubview:self.paintView];
        [self.paintView addDelegate:self];
    }
    return self.paintView.helper;
}

- (void)setTools:(NSArray *)value {
    if (tools_ != value) {
        tools_ = value;
        [self showTools];
    }
}

- (void) showTools {
    if (toolPalette_ || !tools_) {
        toolPalette_.hidden = NO;
        return;
    }
    
    WDToolView *toolsView = [[WDToolView alloc] initWithTools:self.tools andCanvas:self];
    
    // create a base view for all the palette elements
    UIView *paletteView = [[UIView alloc] initWithFrame:toolsView.frame];
    [paletteView addSubview:toolsView];
    
    toolPalette_ = [WDPalette paletteWithBaseView:paletteView defaultsName:@"tools palette"];
    [self addSubview:toolPalette_];
    
    [toolPalette_ bringOnScreen];
}

- (NSDictionary *)activeTool {
    NSString *cmd = self.helper.command;
    
    for (id tool in tools_) {
        if ([tool isKindOfClass:[NSArray class]]) {
            for (NSDictionary *subtool in tool) {
                if ([cmd isEqualToString:[subtool objectForKey:@"name"]]) {
                    return subtool;
                }
            }
        } else if ([cmd isEqualToString:[tool objectForKey:@"name"]]) {
            return tool;
        }
    }
    return nil;
}

- (void)setActiveTool:(NSDictionary *)tool {
    self.helper.command = [tool objectForKey:@"name"];
}

- (void)onCommandChanged:(id)view {
    NSDictionary *tool = self.activeTool;
    if (tool) {
        NSDictionary *userInfo = @{@"tool": tool};
        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:WDActiveToolDidChange
                                       object:self userInfo:userInfo]];
    }
}

@end

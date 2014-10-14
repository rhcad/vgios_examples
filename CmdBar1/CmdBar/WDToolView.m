//
//  WDToolView.m
//  Inkpad
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2011-2013 Steve Sprang
//

#import "WDToolButton.h"
#import "WDToolView.h"
#import "WDEtchedLine.h"
#import "GiCanvasView.h"

@implementation WDToolView

@synthesize tools = tools_;
@synthesize owner, canvas;

- (id) initWithTools:(NSArray *)tools andCanvas:(GiCanvasView *)view
{
    int h = 0;
    
    for (id tool in tools) {
        if ([tool isKindOfClass:[NSDictionary class]]
            && ![((NSDictionary *)tool) objectForKey:@"image"]) {
            h += 3;
        } else {
            h += [WDToolButton dimension];
        }
    }
    
    self = [super initWithFrame:CGRectMake(0, 0, [WDToolButton dimension], h)];
    
    if (!self) {
        return nil;
    }
    
    self.opaque = NO;
    self.backgroundColor = nil;
    
    self.canvas = view;
    self.tools = tools;
            
    return self;
}

- (void) chooseTool:(id)sender
{
    if (self.owner) {
        [self.owner didChooseTool:self];
    }
    
    [self.canvas setActiveTool:((WDToolButton *)sender).tool from:sender];
}

- (void) setTools:(NSArray *)tools
{
    tools_ = tools;

    // build tool buttons
    CGRect buttonRect = CGRectMake(0, 0, [WDToolButton dimension], [WDToolButton dimension]);
    NSDictionary *activeTool = self.canvas.activeTool;
    
    for (id tool in tools_) {
        if ([tool isKindOfClass:[NSDictionary class]]
            && ![((NSDictionary *)tool) objectForKey:@"image"]) {   // separator
            CGRect rect = CGRectMake(2, CGRectGetMinY(buttonRect) + 1, buttonRect.size.width - 4, 2);
            WDEtchedLine *line = [[WDEtchedLine alloc] initWithFrame:rect];
            [self addSubview:line];
            buttonRect = CGRectOffset(buttonRect, 0, 3);
            continue;
        }
        
        WDToolButton *button = [WDToolButton buttonWithType:UIButtonTypeCustom];
        
        if ([tool isKindOfClass:[NSArray class]]) {
            button.canvas = self.canvas;
            button.tools = tool;
        } else {
            button.tool = tool;
        }
        
        button.frame = buttonRect;
        [button addTarget:self action:@selector(chooseTool:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if (tool == activeTool) {
            button.selected = YES;
        }
        
        buttonRect = CGRectOffset(buttonRect, 0, [WDToolButton dimension]);
    }
}

@end

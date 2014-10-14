//  GiCanvasView.mm
//
//  Created by Zhang Yungui on 14-10-11.
//  Copyright (c) 2014 https://github.com/touchvg
//

#import "GiCanvasView.h"
#import "WDPalette.h"
#import "WDToolView.h"
#import "WDToolButton.h"
#import "WDSettingsController.h"
#import "GiViewHelper.h"

NSString *WDActiveToolDidChange = @"WDActiveToolDidChange";
NSString *WDCanvasBeganTrackingTouches = @"WDCanvasBeganTrackingTouches";

@interface GiCanvasView () {
    WDPalette               *toolPalette_;
    UIPopoverController     *popoverController_;
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

- (UIViewController *)viewController {
    if ([self.nextResponder isKindOfClass:[UIViewController class]])
        return (UIViewController *)self.nextResponder;
    if ([self.superview.nextResponder isKindOfClass:[UIViewController class]])
        return (UIViewController *)self.superview.nextResponder;
    return nil;
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

- (void)setActiveTool:(NSDictionary *)tool from:(id)sender {
    NSString *cmd = [tool objectForKey:@"name"];
    
    if ([cmd isEqualToString:@"*settings"]) {
        [self showSettingsMenu:sender];
    } else {
        self.helper.command = cmd;
    }
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

#pragma mark -
#pragma mark popoverController

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == popoverController_) {
        popoverController_ = nil;
    }
}

- (void) hidePopovers
{
    if (popoverController_) {
        [popoverController_ dismissPopoverAnimated:NO];
        popoverController_ = nil;
        //visibleMenu_ = nil;
    }
}

- (UIPopoverController *) runPopoverWithController:(UIViewController *)controller from:(id)sender
{
    [self hidePopovers];
    
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:controller];
	popoverController_.delegate = self;
    
    UIView *button = sender;
    CGRect rect = [button.superview convertRect:button.frame toView:self];
    [popoverController_ presentPopoverFromRect:rect inView:self
                      permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    return popoverController_;
}

#pragma mark -
#pragma mark Settings

- (BOOL) shouldDismissPopoverForClassController:(Class)controllerClass insideNavController:(BOOL)insideNav
{
    if (!popoverController_) {
        return NO;
    }
    
    if (insideNav && [popoverController_.contentViewController isKindOfClass:[UINavigationController class]]) {
        NSArray *viewControllers = [(UINavigationController *)popoverController_.contentViewController viewControllers];
        
        for (UIViewController *viewController in viewControllers) {
            if ([viewController isKindOfClass:controllerClass]) {
                return YES;
            }
        }
    } else if ([popoverController_.contentViewController isKindOfClass:controllerClass]) {
        return YES;
    }
    
    return NO;
}

- (void)showSettingsMenu:(id)sender
{
    if ([self shouldDismissPopoverForClassController:[WDSettingsController class] insideNavController:YES]) {
        [self hidePopovers];
        return;
    }
    
    WDSettingsController *settings = [[WDSettingsController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settings];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[self viewController] presentViewController:navController animated:YES completion:nil];
    } else {
        [self runPopoverWithController:navController from:sender];
    }
}

@end

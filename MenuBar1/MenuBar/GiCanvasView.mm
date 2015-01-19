//  GiCanvasView.mm
//
//  Created by Zhang Yungui on 14-10-14.
//  Copyright (c) 2014 https://github.com/rhcad
//

#import "GiCanvasView.h"
#import "GiViewHelper.h"
#import "WDSettingsController.h"

@interface GiCanvasView () {
    UIPopoverController *popoverController_;
}

@end

@implementation GiCanvasView

@synthesize paintView, helper;
@synthesize flags, command;

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
    [popoverController_ presentPopoverFromRect:button.frame inView:self
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

//
//  ViewController.mm
//  MenuBar
//
//  Created by Zhang Yungui on 14-10-14.
//  Copyright (c) 2014 https://github.com/rhcad
//

#import "ViewController.h"
#import "GiCanvasView.h"

@interface ViewController () {
    __weak IBOutlet GiCanvasView *canvas_;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onSettings:(id)sender {
    [canvas_ showSettingsMenu:sender];
}

@end

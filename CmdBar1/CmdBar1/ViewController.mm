//
//  ViewController.mm
//  CmdBar1
//
//  Created by Zhang Yungui on 14-10-11.
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
    
    canvas_.tools = @[ @{@"image" : @"select.png", @"name" : @"select"},
                       @{@"image" : @"brush.png", @"name" : @"splines"},
                       @{@"image" : @"line.png", @"name" : @"line"},
                       @{@"image" : @"rect.png", @"name" : @"rect"},
                       @{@"image" : @"ellipse.png", @"name" : @"ellipse"},
                       @{@"image" : @"eraser.png", @"name" : @"erase"},
                       @{@"name" : @"-"},
                       @{@"image" : @"gear.png", @"name" : @"*settings"}];
}

@end

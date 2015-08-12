//
//  ViewController.mm
//  SplinesEraser
//
//  Created by Zhang Yungui on 15-8-11.
//  Copyright (c) 2014 https://github.com/rhcad
//

#import "ViewController.h"
#import "GiViewHelper+Layer.h"
#include <mgview.h>
#include <mgdrawsplines.h>
#include <mgsplines.h>

class CmdDrawSplinesEraser : public MgCmdDrawSplines
{
public:
    static const char* Name() { return "spline_eraser"; }
    static MgCommand* Create() { return new CmdDrawSplinesEraser; }
    __weak UIImageView *imageView;
    
private:
    CmdDrawSplinesEraser() : MgCmdDrawSplines(Name()) {}
    
    virtual bool gatherShapes(const MgMotion*, MgShapes*) { return false; }
    virtual bool touchEnded(const MgMotion* sender);
};

@interface ViewController () {
    __weak IBOutlet UIImageView *imageView_;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GiViewHelper *hlp = [GiViewHelper sharedInstance];
    
    mgRegisterCommand<CmdDrawSplinesEraser>(hlp.cmdView);
    hlp.command = @"spline_eraser";
    
    ((CmdDrawSplinesEraser*)hlp.cmdView->getCommand())->imageView = imageView_;
}

@end

bool CmdDrawSplinesEraser::touchEnded(const MgMotion* sender)
{
    MgSplines *lines = (MgSplines*)dynshape()->shape();
    
    if (!lines->isClosed()) {
        lines->setClosed(true);
    }
    
    NSArray *paths = [[GiViewHelper sharedInstance] exportPathsForShape: dynshape()->toHandle()];
    UIBezierPath *path = paths[0];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.path = path.CGPath;
    [imageView.layer setMask:shapeLayer];
    
    lines->clear();
    return true;
}

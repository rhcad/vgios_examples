//
//  ViewController.mm
//  StoryBoard1
//
//  Created by Zhang Yungui on 14-9-25.
//  Copyright (c) 2014 https://github.com/touchvg
//

#import "ViewController.h"
#import "GiViewHelper.h"
#import "GiPaintViewDelegate.h"

@interface ViewController ()<GiPaintViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GiViewHelper *hlp = [GiViewHelper sharedInstance];

    [hlp startUndoRecord:[LIBRARY_FOLDER stringByAppendingString:@"undo"]];
    [hlp addDelegate:self];
    [self onContentChanged:hlp.view];
}

- (void)onContentChanged:(id)view {
    GiViewHelper *hlp = [GiViewHelper sharedInstance];
    
    NSString *name = [hlp canUndo] ? @"undo2.png" : @"undo1.png";
    [self.undoButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    
    name = [hlp canRedo] ? @"redo2.png" : @"redo1.png";
    [self.redoButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
}

- (IBAction)undo:(id)sender {
    [[GiViewHelper sharedInstance]undo];
}

- (IBAction)redo:(id)sender {
    [[GiViewHelper sharedInstance]redo];
}

@end

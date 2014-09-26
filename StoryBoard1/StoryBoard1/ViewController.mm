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
    
    [self.undoButton setImage:[UIImage imageNamed:@"undo1.png"] forState:UIControlStateDisabled];
    [self.undoButton setImage:[UIImage imageNamed:@"undo2.png"] forState:UIControlStateNormal];
    [self.redoButton setImage:[UIImage imageNamed:@"redo1.png"] forState:UIControlStateDisabled];
    [self.redoButton setImage:[UIImage imageNamed:@"redo2.png"] forState:UIControlStateNormal];
    
    GiViewHelper *hlp = [GiViewHelper sharedInstance];

    [hlp startUndoRecord:[LIBRARY_FOLDER stringByAppendingString:@"undo"]];
    [hlp addDelegate:self];
    [self onContentChanged:hlp.view];
}

- (void)onContentChanged:(id)view {
    GiViewHelper *hlp = [GiViewHelper sharedInstance];
    
    self.undoButton.enabled = [hlp canUndo];
    self.redoButton.enabled = [hlp canRedo];
}

- (IBAction)undo:(id)sender {
    [[GiViewHelper sharedInstance]undo];
}

- (IBAction)redo:(id)sender {
    [[GiViewHelper sharedInstance]redo];
}

@end

//
//  ViewController.mm
//  StoryBoard1
//
//  Created by Zhang Yungui on 14-9-25.
//  Copyright (c) 2014 https://github.com/touchvg
//

#import "ViewController.h"
#import "GiViewHelper.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [LIBRARY_FOLDER stringByAppendingString:@"undo"];
    [[GiViewHelper sharedInstance]startUndoRecord:path];
}

- (IBAction)undo:(id)sender {
    [[GiViewHelper sharedInstance]undo];
}

- (IBAction)redo:(id)sender {
    [[GiViewHelper sharedInstance]redo];
}

@end

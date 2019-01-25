//
//  ViewController.m
//  Navigation
//
//  Created by Admin on 20.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.path);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    NSLog(@"VC deallocated!");
}

- (IBAction)okAction:(id)sender
{
    NSString* folderName = self.NameField.text;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.path stringByAppendingPathComponent:folderName]
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.parentController folderAdded:folderName];
    }];
}
@end

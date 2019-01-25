//
//  ViewController.h
//  Navigation
//
//  Created by Admin on 20.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagerTableViewController.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) NSString* path;
@property (weak, nonatomic) IBOutlet UITextField *NameField;
@property (strong, nonatomic) ManagerTableViewController* parentController;

- (IBAction)okAction:(id)sender;

@end

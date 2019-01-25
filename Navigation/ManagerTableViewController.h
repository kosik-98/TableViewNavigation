//
//  ManagerTableViewController.h
//  Navigation
//
//  Created by Admin on 19.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManagerTableViewController : UITableViewController

-(void)folderAdded:(NSString*)folderName;

- (IBAction)actionEdit:(UIBarButtonItem *)sender;

@end

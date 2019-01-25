//
//  ManagerTableViewController.m
//  Navigation
//
//  Created by Admin on 19.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "ManagerTableViewController.h"
#import "FileTableViewCell.h"
#import "ViewController.h"

@interface ManagerTableViewController ()

@property (strong, nonatomic) NSArray* content;
@property (strong, nonatomic) NSString* path;
@property (strong, nonatomic) NSMutableArray* foldersArray;
@property (strong, nonatomic) NSMutableArray* filesArray;

@end

@implementation ManagerTableViewController

- (void)setPath:(NSString *)path
{
    _path = path;
    
    self.content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    [self.tableView reloadData];
    self.navigationItem.title = path;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.foldersArray = [NSMutableArray array];
    self.filesArray = [NSMutableArray array];
    
    if(!self.path)
    {
        self.path = @"/Users/admin/Desktop/Navigation";
    }
    
    for(NSString* obj in self.content)
    {
        BOOL isDirectory = NO;
        
        [[NSFileManager defaultManager] fileExistsAtPath:[self.path stringByAppendingPathComponent:obj] isDirectory:&isDirectory];
        
        if(isDirectory)
        {
            [self.foldersArray addObject:obj];
        }
        else
        {
            if(![self isFileHidden:obj])
                [self.filesArray addObject:obj];
        }
        
    }
}

-(BOOL)isFileHidden:(NSString*)filename
{
    NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.path stringByAppendingPathComponent:filename] error:nil];
    
    return [attributes fileExtensionHidden];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)folderAdded:(NSString*)folderName
{
    [self.foldersArray insertObject:folderName atIndex:0];
    
    [self.tableView beginUpdates];
    
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.tableView endUpdates];
}

-(NSInteger)folderSize:(NSString*)folderPath
{
    NSInteger size = 0;
    NSArray* contentsOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    if([contentsOfFolder count] > 0)
    {
        for(NSString* obj in contentsOfFolder)
        {
            BOOL isDirectory = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:[folderPath stringByAppendingPathComponent:obj] isDirectory:&isDirectory];
            if(isDirectory)
            {
                size += [self folderSize:[folderPath stringByAppendingPathComponent:obj]];
            }
            else
            {
                NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:obj] error:nil];
                size += [attributes fileSize];
            }
        }
    }
    
    return size;
}

#pragma mark - Actions

- (IBAction)actionEdit:(UIBarButtonItem *)sender
{
    BOOL isEditing = [self.tableView isEditing];

    [self.tableView setEditing:!isEditing animated:YES];
}

#pragma mark - Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ViewController* vc = segue.destinationViewController;
    vc.path = self.path;
    vc.parentController = segue.sourceViewController;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return [self.foldersArray count] + 1;
    else
        return [self.filesArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        if([self.foldersArray count] > 0)
            return @"Folders";
        else
            return @"No folders";
    }
    else
    {
        if([self.filesArray count] > 0)
            return @"Files";
        else
            return @"No files";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"Add directory";
        cell.textLabel.textColor = [UIColor blueColor];
        return cell;
    }
    else
    {
        static NSString* folderIdentifier = @"Folder";
        static NSString* fileIdentifier = @"File";
        
        if(indexPath.section == 0)
        {
            NSString* folderName = [self.foldersArray objectAtIndex:indexPath.row - 1];
            NSInteger folderSize = [self folderSize:[self.path stringByAppendingPathComponent:folderName]];
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier forIndexPath:indexPath];
            cell.textLabel.text = folderName;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Bytes", folderSize];
            
            return cell;
        }
        else
        {
            NSString* filename = [self.filesArray objectAtIndex:indexPath.row];
            
            NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.path stringByAppendingPathComponent:filename] error:nil];
            
            FileTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier forIndexPath:indexPath];
            
            cell.nameLabel.text = filename;
            cell.sizeLabel.text = [NSString stringWithFormat:@"%llu Bytes",[attributes fileSize]];
            cell.dateLabel.text = [NSString stringWithFormat:@"%@",[attributes fileModificationDate]];
            
            return cell;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString* itemForDelete;
        
        if(indexPath.section == 0)
        {
            itemForDelete = [self.foldersArray objectAtIndex:indexPath.row - 1];
            [self.foldersArray removeObject:itemForDelete];
        }
        else
        {
            itemForDelete = [self.filesArray objectAtIndex:indexPath.row];
            [self.filesArray removeObject:itemForDelete];
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:[self.path stringByAppendingPathComponent:itemForDelete] error:nil];
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        [self.tableView endUpdates];
    }
}


#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0 && indexPath.row == 0) ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        [self performSegueWithIdentifier:@"ViewController" sender:nil];
        self.content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:nil];
        
        [self.tableView reloadData];
    }
    else if(indexPath.section == 0)
    {
        NSString* folderName = [self.foldersArray objectAtIndex:indexPath.row - 1];
        ManagerTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ManagerTableViewController"];
        vc.path = [self.path stringByAppendingPathComponent:folderName];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 44;
    }
    else
    {
        return 94;
    }
}

@end

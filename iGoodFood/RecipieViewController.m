//
//  RecipieViewController.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "RecipieViewController.h"
#import "AddRecipieViewController.h"

@interface RecipieViewController ()

@end

@implementation RecipieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.currentCategory.name;
    
    UIBarButtonItem *addRecipieButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRecipieButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = addRecipieButton;
}

-(IBAction)addRecipieButtonPressed
{
    [self performSegueWithIdentifier:@"toAddRecipieView" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AddRecipieViewController *destination = (AddRecipieViewController *)segue.destinationViewController;
    
    destination.currentCategory = self.currentCategory;
    destination.currentUser = self.currentUser;
}


#warning must implement collection view


@end

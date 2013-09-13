//
//  AddRecipieViewController.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "AddRecipieViewController.h"

@interface AddRecipieViewController ()

@end

@implementation AddRecipieViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"New Recipie";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (IBAction)addButtonPressed
{
    
}


@end

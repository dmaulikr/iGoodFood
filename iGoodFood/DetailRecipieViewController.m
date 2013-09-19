//
//  DetailRecipieViewController.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/16/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "DetailRecipieViewController.h"
#import "AddRecipieViewController.h"

@interface DetailRecipieViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *ingredientsField;
@property (weak, nonatomic) IBOutlet UITextView *howToField;
@property (weak, nonatomic) IBOutlet UILabel *cookingTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)editButtonPressed;

@end

@implementation DetailRecipieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.tintColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
    
    self.ingredientsField.layer.cornerRadius = 3;
    self.howToField.layer.cornerRadius = 3;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.nameField.text = self.currentRecipie.name;
    self.ingredientsField.text = self.currentRecipie.ingredients;
    self.howToField.text = self.currentRecipie.howToCook;
    self.cookingTimeLabel.text = [NSString stringWithFormat:@"Cooks in %d minutes.", [self.currentRecipie.cookingTime integerValue]];
    self.imageView.image = [UIImage imageWithData:[self.currentRecipie image]];
}

- (IBAction)editButtonPressed
{
    [self performSegueWithIdentifier:@"toEdit" sender:self];
}

- (IBAction)segmentValueChanged:(id)sender
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        self.ingredientsField.hidden = YES;
        self.howToField.hidden = YES;
        
        
        self.cookingTimeLabel.hidden = NO;
        self.imageView.hidden = NO;
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        self.ingredientsField.hidden = NO;
        
        self.howToField.hidden = YES;
        
        self.cookingTimeLabel.hidden = YES;
        self.imageView.hidden = YES;
    }
    else
    {
        self.ingredientsField.hidden = YES;
        self.howToField.hidden = NO;
        
        
        self.cookingTimeLabel.hidden = YES;
        self.imageView.hidden = YES;
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AddRecipieViewController *destination = (AddRecipieViewController *)segue.destinationViewController;
    
    destination.recipieToEdit = self.currentRecipie;
}
@end

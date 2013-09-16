//
//  AddRecipieViewController.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "AddRecipieViewController.h"
#import "DataModel.h"
#import "TextAnalyzer.h"

@interface AddRecipieViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentIndicator;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *ingredientsField;
@property (weak, nonatomic) IBOutlet UITextView *howToField;

- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end

@implementation AddRecipieViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nameField.delegate = self;
    self.descriptionField.delegate = self;
    self.timeField.delegate = self;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView addGestureRecognizer:tapRecognizer];
    
    if (self.recipieToEdit != nil)
    {
        self.nameField.text = self.recipieToEdit.name;
        self.descriptionField.text = self.recipieToEdit.recipieDescription;
        self.timeField.text = [NSString stringWithFormat:@"%d", [self.recipieToEdit.cookingTime integerValue]];
        self.imageView.image = [UIImage imageWithData:self.recipieToEdit.image];
        self.ingredientsField.text = self.recipieToEdit.ingredients;
        self.howToField.text = self.recipieToEdit.howToCook;
    }
    
}

#pragma mark - IBAction Methods

- (IBAction)imageTapped:(UIGestureRecognizer *) recognizer
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Add image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a picture" otherButtonTitles:@"Pick from library", nil];
    [sheet showInView:self.view];
}

- (IBAction)segmentValueChanged:(id)sender
{
    if (self.segmentIndicator.selectedSegmentIndex == 0)
    {
        self.ingredientsField.hidden = YES;
        self.howToField.hidden = YES;
        
        [self.ingredientsField resignFirstResponder];
        [self.howToField resignFirstResponder];
        
        self.nameField.hidden = NO;
        self.descriptionField.hidden = NO;
        self.timeField.hidden = NO;
        self.timeLabel.hidden = NO;
        self.imageView.hidden = NO;
    }
    else if (self.segmentIndicator.selectedSegmentIndex == 1)
    {
        self.ingredientsField.hidden = NO;
        [self.ingredientsField becomeFirstResponder];
        
        self.howToField.hidden = YES;
        
        self.nameField.hidden = YES;
        self.descriptionField.hidden = YES;
        self.timeField.hidden = YES;
        self.timeLabel.hidden = YES;
        self.imageView.hidden = YES;
    }
    else
    {
        self.ingredientsField.hidden = YES;
        self.howToField.hidden = NO;
        [self.howToField becomeFirstResponder];
        
        self.nameField.hidden = YES;
        self.descriptionField.hidden = YES;
        self.timeField.hidden = YES;
        self.timeLabel.hidden = YES;
        self.imageView.hidden = YES;

    }
        
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender
{
    if (self.recipieToEdit != nil && ![self.nameField.text isEqualToString:@""])
    {
        self.recipieToEdit.name = self.nameField.text;
        self.recipieToEdit.recipieDescription = self.descriptionField.text;
        self.recipieToEdit.cookingTime = [NSNumber numberWithInteger:[self.timeField.text integerValue]];
        self.recipieToEdit.image = UIImagePNGRepresentation(self.imageView.image);
        self.recipieToEdit.ingredients = self.ingredientsField.text;
        self.recipieToEdit.howToCook = self.howToField.text;
        
        [DataModel saveContext];
        
        [TextAnalyzer analyzeText:[NSString stringWithFormat:@"%@ %@", self.howToField.text, self.ingredientsField.text] withCompletion:^(NSMutableArray *tags) {
            NSLog(@"%@", tags);
            
            [DataModel addTagsFromArray:tags forRecipe:[DataModel getRecipieForName:self.nameField.text]];
        }];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if ([DataModel createRecipieWithName:self.nameField.text
                                 description:self.descriptionField.text
                                 cookingTime:[self.timeField.text integerValue]
                                       image:self.imageView.image
                                 ingredients:self.ingredientsField.text
                                   howToCook:self.howToField.text
                                     forUser:self.currentUser
                                 andCategory:self.currentCategory] && ![self.nameField.text isEqualToString:@""])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Recipie added!" message:@"Your recipie was added successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            [TextAnalyzer analyzeText:[NSString stringWithFormat:@"%@ %@", self.howToField.text, self.ingredientsField.text] withCompletion:^(NSMutableArray *tags) {
                NSLog(@"%@", tags);
                
                [DataModel addTagsFromArray:tags forRecipe:[DataModel getRecipieForName:self.nameField.text]];
            }];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Could not add recipie." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
    
}

#pragma mark - Keyboard Dismiss

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Action Sheet Delegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.navigationBarHidden = YES;
        picker.toolbarHidden = YES;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if (buttonIndex == 1)
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePicker delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


@end

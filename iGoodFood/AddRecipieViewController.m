//
//  AddRecipieViewController.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "AddRecipieViewController.h"
#import "DataModel.h"

@interface AddRecipieViewController ()
{
    BOOL changedImage;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentIndicator;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
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
    
    changedImage = NO;
    
    self.nameField.delegate = self;
    self.timeField.delegate = self;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView addGestureRecognizer:tapRecognizer];
    
    if (self.recipieToEdit != nil)
    {
        self.nameField.text = self.recipieToEdit.name;
        self.timeField.text = [NSString stringWithFormat:@"%d", [self.recipieToEdit.cookingTime integerValue]];
        self.imageView.image = [UIImage imageWithData:self.recipieToEdit.image];
        self.ingredientsField.text = self.recipieToEdit.ingredients;
        self.howToField.text = self.recipieToEdit.howToCook;
    }
    
    self.ingredientsField.layer.cornerRadius = 3;
    self.howToField.layer.cornerRadius = 3;
    
    self.view.tintColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
    
    self.ingredientsField.tintColor = [UIColor whiteColor];
    self.howToField.tintColor = [UIColor whiteColor];
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
        self.timeField.hidden = NO;
        self.timeLabel.hidden = NO;
        self.imageView.hidden = NO;
    }
    else if (self.segmentIndicator.selectedSegmentIndex == 1)
    {
        self.ingredientsField.hidden = NO;
        
        self.howToField.hidden = YES;
        
        self.nameField.hidden = YES;
        self.timeField.hidden = YES;
        self.timeLabel.hidden = YES;
        self.imageView.hidden = YES;
        
        [self.ingredientsField becomeFirstResponder];
    }
    else
    {
        self.ingredientsField.hidden = YES;
        self.howToField.hidden = NO;
        
        self.nameField.hidden = YES;
        self.timeField.hidden = YES;
        self.timeLabel.hidden = YES;
        self.imageView.hidden = YES;
        
        [self.howToField becomeFirstResponder];

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
        self.recipieToEdit.cookingTime = [NSNumber numberWithInteger:[self.timeField.text integerValue]];
        self.recipieToEdit.image = UIImagePNGRepresentation(self.imageView.image);
        self.recipieToEdit.ingredients = self.ingredientsField.text;
        self.recipieToEdit.howToCook = self.howToField.text;
        
        [DataModel saveContext];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if ([DataModel createRecipieWithName:self.nameField.text
                                 description:@""
                                 cookingTime:[self.timeField.text integerValue]
                                       image:(changedImage ? self.imageView.image : [UIImage imageNamed:@"recipie.png"])
                                 ingredients:self.ingredientsField.text
                                   howToCook:self.howToField.text
                                     forUser:self.currentUser
                                 andCategory:self.currentCategory] && ![self.nameField.text isEqualToString:@""])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Recipe added!" message:@"Your recipe was added successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Could not add recipe." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
    
    changedImage = YES;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


@end

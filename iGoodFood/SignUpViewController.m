//
//  SignUpViewController.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "SignUpViewController.h"
#import "DataModel.h"
#import "NSString+Encrypt.h"

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Sign Up";
    
    UIBarButtonItem *signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(signUpButtonPressed)];
    self.navigationItem.rightBarButtonItem = signUpButton;
    
    
    for (UITextField *textField in self.textFields)
    {
        textField.delegate = self;
    }

    self.view.tintColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.usernameTextField becomeFirstResponder];
}

- (IBAction)signUpButtonPressed
{
    for (UITextField *textField in self.textFields)
    {
        if ([textField.text isEqualToString:@""] || [textField.text length] < 6)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Some field is short or empty!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            
            return;
        }
    }
    
    if ([self.passwordTextField.text isEqualToString:self.repeatPasswordTextField.text])
    {
        [[DataModel sharedModel] createUserWithName:self.fullNameTextField.text
                                           username:self.usernameTextField.text
                                        andPassword:[self.passwordTextField.text encrypt]
                                         completion:^(BOOL userCreated) {
                                             if (userCreated)
                                             {
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                                                 message:@"You have successfully signed up!"
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles: nil];
                                                 
                                                 [alert show];
                                                 [self.navigationController popToRootViewControllerAnimated:YES];
                                             }
                                             else
                                             {
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                                                 message:@"User already exists!"
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles: nil];
                                                 
                                                 [alert show];
                                             }
                                         }];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                        message:@"Passwords don't match!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
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

@end

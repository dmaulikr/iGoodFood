//
//  LoginViewController.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "LoginViewController.h"
#import "DataModel.h"
#import "User.h"
#import "CategoryViewController.h"
#import "NSString+Encrypt.h"

@interface LoginViewController ()
{
    User *user;
}

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

- (IBAction)loginButtonPressed:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIBarButtonItem *signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(signUpButtonPressed)];
    self.navigationItem.rightBarButtonItem = signUpButton;
    
    self.userNameTextField.delegate = self;
    self.passTextField.delegate = self;    

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.view.tintColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:@"rememberMe"] boolValue])
    {
        [[DataModel sharedModel] getUserForUsername:[defaults objectForKey:@"username"] andPassword:[defaults objectForKey:@"password"] completion:^(User *newUser) {
            if ((user = newUser))
            {
                [self performSegueWithIdentifier:@"toCategoryView" sender:self];
            }
        }];
    }
}

#pragma mark - IBAction Methods

- (IBAction)signUpButtonPressed
{
    [self performSegueWithIdentifier:@"toSignUp" sender:self];
}


- (IBAction)loginButtonPressed:(id)sender
{
    [[DataModel sharedModel] getUserForUsername:self.userNameTextField.text andPassword:[self.passTextField.text encrypt] completion:^(User *newUser) {
        if ((user = newUser))
        {
            [self performSegueWithIdentifier:@"toCategoryView" sender:self];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Invalid username or password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CategoryViewController class]])
    {
        CategoryViewController *destination = (CategoryViewController *)segue.destinationViewController;
        
        destination.currentUser = user;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:user.username forKey:@"username"];
        [defaults setObject:user.password forKey:@"password"];
        [defaults setObject:[NSNumber numberWithBool:self.rememberMeSwitch.isOn] forKey:@"rememberMe"];
        
        [defaults synchronize];
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

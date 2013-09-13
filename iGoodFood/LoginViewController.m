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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:@"rememberMe"] boolValue])
    {
        if ((user = [DataModel getUserForUsername:[defaults objectForKey:@"username"] andPassword:[defaults objectForKey:@"password"]]) != nil)
        {
            [self performSegueWithIdentifier:@"toCategoryView" sender:self];
        }
    }
}

- (IBAction)signUpButtonPressed
{
    [self performSegueWithIdentifier:@"toSignUp" sender:self];
}


- (IBAction)loginButtonPressed:(id)sender
{
    if ((user = [DataModel getUserForUsername:self.userNameTextField.text andPassword:[self.passTextField.text encrypt]]) != nil)
    {
        [self performSegueWithIdentifier:@"toCategoryView" sender:self];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Invalid username or password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

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
@end

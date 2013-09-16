//
//  CategoryViewController.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "CategoryViewController.h"
#import "DataModel.h"
#import "CategoryCell.h"
#import "RecipieCategory.h"
#import "RecipieViewController.h"
#import "Recipie.h"

@interface CategoryViewController ()
{
    NSMutableArray *categories;
    RecipieCategory *selectedCategory;
}

@end

@implementation CategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOutButtonPressed)];
    self.navigationItem.leftBarButtonItem = logOutButton;
    
    UIBarButtonItem *addCategoryButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCategoryButtonPressed)];
    self.navigationItem.rightBarButtonItem = addCategoryButton;
    
    self.title = @"Categories";
    
    [self loadCategories];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    
    [self loadCategories];
}

- (void)loadCategories
{
    categories = [NSMutableArray arrayWithArray:[DataModel getCategoriesForUser:self.currentUser]];
    [self.collectionView reloadData];
}

- (IBAction)logOutButtonPressed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"password"];
    [defaults removeObjectForKey:@"rememberMe"];
    
    [defaults synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)addCategoryButtonPressed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Category" message:@"Enter category name:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)categoryLongPressed:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"What do you want?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
        [sheet showInView:recognizer.view];
        
        CategoryCell *cell = (CategoryCell *)recognizer.view;
        
        selectedCategory = [DataModel getCategoryForName:cell.categoryNameLabel.text];
    }
}

#pragma mark - Alert View Delegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSString *categoryName = [alertView textFieldAtIndex:0].text;
        
        if ([categoryName isEqualToString:@""] || categoryName == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Can't create category with blank name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            if ([DataModel createCategoryWithName:categoryName forUser:self.currentUser])
            {
                NSLog(@"Category added");
                [self loadCategories];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Category with this name already exists!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

#pragma mark - Collection View Delegate & DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [categories count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"categoryCell";
    
    CategoryCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.categoryNameLabel.text = [(RecipieCategory *)categories[indexPath.row] name];
    
    if ([[(RecipieCategory *)categories[indexPath.row] recipies] count] > 0)
    {
        RecipieCategory *category = (RecipieCategory *)categories[indexPath.row];
        Recipie *recipie = (Recipie *)[[category.recipies allObjects] objectAtIndex:0];
        
        NSData *imageData = recipie.image;
        
        cell.categoryImage.image = [UIImage imageWithData:imageData];
    }
    else
    {
        cell.categoryImage.image = [UIImage imageNamed:@"recipie.png"];
        cell.categoryImage.contentMode = UIViewContentModeScaleAspectFit;
    }

    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(categoryLongPressed:)];
    [cell addGestureRecognizer:longPressRecognizer];
    
    cell.categoryImage.layer.cornerRadius = 15;
    cell.categoryImage.clipsToBounds = YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCategory = categories[indexPath.row];
    [self performSegueWithIdentifier:@"toRecipieView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RecipieViewController *destination = (RecipieViewController *)segue.destinationViewController;
    
    destination.currentUser = self.currentUser;
    destination.currentCategory = selectedCategory;
}

#pragma mark - Action Sheet Delegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [DataModel deleteCategory:selectedCategory];
        [self loadCategories];
    }
}

@end

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
#import "DetailRecipieViewController.h"

@interface CategoryViewController ()
{
    NSMutableArray *categories;
    RecipieCategory *selectedCategory;
    NSMutableArray *allRecipes;
    Recipie *selectedRecipe;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation CategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logOutButtonPressed)];
    self.navigationItem.leftBarButtonItem = logOutButton;
    
    UIBarButtonItem *addCategoryButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                       target:self
                                                                                       action:@selector(addCategoryButtonPressed)];
    self.navigationItem.rightBarButtonItem = addCategoryButton;
    
    self.title = @"Categories";
    
    self.searchDisplayController.delegate = self;
    
    self.view.tintColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
    self.searchBar.barTintColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
    self.searchBar.tintColor = [UIColor whiteColor];
    
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

#pragma mark - IBAction Methods

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Category name:"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Cancel", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

- (void)categoryLongPressed:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"What do you want?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Delete"
                                                  otherButtonTitles: nil];
        
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Can't create category with blank name."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            if ([DataModel createCategoryWithName:categoryName forUser:self.currentUser])
            {
                [self loadCategories];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:@"Category with this name already exists!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                
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
    RecipieCategory *category = (RecipieCategory *)categories[indexPath.row];
    
    cell.categoryNameLabel.text = category.name;
    
    if (category.recipies.count > 0)
    {
        Recipie *recipie = (Recipie *)[[category.recipies allObjects] objectAtIndex:0];
        
        cell.categoryImage.image = [UIImage imageWithData:recipie.image];
    }
    else
    {
        cell.categoryImage.image = [UIImage imageNamed:@"recipie.png"];
        cell.categoryImage.contentMode = UIViewContentModeScaleAspectFit;
    }

    cell.categoryNameLabel.textColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(categoryLongPressed:)];
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

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[RecipieViewController class]])
    {
        RecipieViewController *destination = (RecipieViewController *)segue.destinationViewController;
        
        destination.currentUser = self.currentUser;
        destination.currentCategory = selectedCategory;
    }
    else if([segue.destinationViewController isKindOfClass:[DetailRecipieViewController class]])
    {
        DetailRecipieViewController *destination = (DetailRecipieViewController *)segue.destinationViewController;
        
        destination.currentRecipie = selectedRecipe;
    }
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

#pragma mark - UISearchBar Delegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

#pragma mark - UITableView Data Source & Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allRecipes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    Recipie *cellRecipie = (Recipie *) allRecipes[indexPath.row];
    
    cell.textLabel.text = cellRecipie.name;
    cell.imageView.image = [UIImage imageWithData:cellRecipie.image];
    cell.detailTextLabel.text = [(RecipieCategory *)cellRecipie.category name];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRecipe = (Recipie *)allRecipes[indexPath.row];
    [self performSegueWithIdentifier:@"toDetail" sender:self];
}

#pragma mark - Search Display Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    allRecipes = [NSMutableArray arrayWithArray:[DataModel getRecipesForUser:self.currentUser withSearchString:searchString]];

    return YES;
}

@end

//
//  CategoryViewController.h
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "CategoryCell.h"

@interface CategoryViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) User *currentUser;

@end

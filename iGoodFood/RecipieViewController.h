//
//  RecipieViewController.h
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "RecipieCategory.h"

@interface RecipieViewController : UICollectionViewController <UIActionSheetDelegate>

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) RecipieCategory *currentCategory;

@end

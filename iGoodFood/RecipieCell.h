//
//  RecipieCell.h
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipie.h"

@interface RecipieCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *recipieImage;
@property (weak, nonatomic) IBOutlet UILabel *recipieLabel;

- (void)configureCellwithRecipe:(Recipie *)recipe;

@end

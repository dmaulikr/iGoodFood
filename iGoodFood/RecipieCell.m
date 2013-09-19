//
//  RecipieCell.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "RecipieCell.h"

@implementation RecipieCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureCellwithRecipe:(Recipie *)recipe
{
    self.recipieLabel.text = recipe.name;
    self.recipieLabel.textColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
    
    self.recipieImage.image = [UIImage imageWithData:recipe.image];
    self.recipieImage.contentMode = UIViewContentModeScaleAspectFit;
 
    self.recipieImage.layer.cornerRadius = 5;
    self.recipieImage.clipsToBounds = YES;
}

@end

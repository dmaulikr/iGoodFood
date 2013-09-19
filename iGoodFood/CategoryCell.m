//
//  CategoryCell.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "CategoryCell.h"
#import "RecipieCategory.h"
#import "Recipie.h"

@implementation CategoryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureCellWithCategory:(RecipieCategory *)category
{
    self.categoryNameLabel.text = category.name;
    
    if (category.recipies.count > 0)
    {
        Recipie *recipie = (Recipie *)[[category.recipies allObjects] objectAtIndex:0];
        
        self.categoryImage.image = [UIImage imageWithData:recipie.image];
    }
    else
    {
        self.categoryImage.image = [UIImage imageNamed:@"recipie.png"];
        self.categoryImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    self.categoryNameLabel.textColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
    
    self.categoryImage.layer.cornerRadius = 3;
    self.categoryImage.clipsToBounds = YES;
}


@end

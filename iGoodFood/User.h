//
//  User.h
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/16/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipie, RecipieCategory;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *recipies;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(RecipieCategory *)value;
- (void)removeCategoriesObject:(RecipieCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addRecipiesObject:(Recipie *)value;
- (void)removeRecipiesObject:(Recipie *)value;
- (void)addRecipies:(NSSet *)values;
- (void)removeRecipies:(NSSet *)values;

@end

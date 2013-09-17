//
//  DataModel.h
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface DataModel : NSObject

+ (BOOL)createUserWithName:(NSString *)fullName username:(NSString *)username andPassword:(NSString *)password;
+ (User *)getUserForUsername:(NSString *)username andPassword:(NSString *)password;
+ (BOOL)createCategoryWithName:(NSString *)categoryName forUser:(User *)user;
+ (NSArray *)getCategoriesForUser:(User *)user;
+ (BOOL)createRecipieWithName:(NSString *)recipieName description:(NSString *)description cookingTime:(NSInteger)cookingTime image:(UIImage *) image ingredients:(NSString *)ingredients howToCook:(NSString *)howToCook forUser:(User *)user andCategory:(RecipieCategory *)category;
+ (NSArray *)getRecipiesForCategory:(RecipieCategory *)category;
+ (Recipie *)getRecipieForName:(NSString *)name;
+ (void)deleteRecipie:(Recipie *)recipie;
+ (RecipieCategory *)getCategoryForName:(NSString *)name;
+ (void)deleteCategory:(RecipieCategory *)category;
+ (void)saveContext;
+ (NSArray *)getRecipesForUser:(User *)user withSearchString:(NSString *)searchString;

@end

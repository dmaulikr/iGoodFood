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

+ (DataModel *)sharedModel;

- (void)createUserWithName:(NSString *)fullName username:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL userCreated, NSError *error))completion;
- (void)getUserForUsername:(NSString *)username andPassword:(NSString *)password completion:(void (^)(User *newUser, NSError *error))completion;

- (void)createCategoryWithName:(NSString *)categoryName forUser:(User *)user completion:(void (^)(BOOL isCategoryCreated, NSError *error))completion;
- (void)getCategoriesForUser:(User *)user completion:(void (^)(NSArray *allCategories, NSError *error))completion;
- (void)getCategoryForName:(NSString *)name completion:(void (^)(RecipieCategory *newCategory, NSError *error))completion;
- (void)deleteCategory:(RecipieCategory *)category completion:(void (^)())completion;

- (void)createRecipieWithInfoDictionary:(NSDictionary *)infoDictionary forUser:(User *)user andCategory:(RecipieCategory *)category completion:(void (^)(BOOL isRecipeCreated, NSError *error))completion;
- (void)getRecipiesForCategory:(RecipieCategory *)category completion:(void (^)(NSArray *recipes, NSError *error))completion;
- (void)getRecipieForName:(NSString *)name completion:(void (^)(Recipie *requestedRecipe, NSError *error))completion;
- (void)deleteRecipie:(Recipie *)recipie completion:(void (^)())completion;
- (void)getRecipesForUser:(User *)user withSearchString:(NSString *)searchString completion:(void (^)(NSArray *recipes, NSError *error))completion;
- (void)updateRecipe:(Recipie *)oldRecipe withDataDictionary:(NSDictionary *)infoDictionary;

@end

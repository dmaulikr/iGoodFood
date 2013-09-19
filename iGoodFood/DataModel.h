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


#warning Good practice is to have NSError* error parameter in the completion block. 
#warning Many of the these methods have too much arguments -> could be combined in a dictionary

- (void)createUserWithName:(NSString *)fullName username:(NSString *)username andPassword:(NSString *)password completion:(void (^)(BOOL userCreated))completion;
- (void)getUserForUsername:(NSString *)username andPassword:(NSString *)password completion:(void (^)(User *newUser))completion;

- (void)createCategoryWithName:(NSString *)categoryName forUser:(User *)user completion:(void (^)(BOOL isCategoryCreated))completion;
- (void)getCategoriesForUser:(User *)user completion:(void (^)(NSArray *allCategories))completion;
- (void)getCategoryForName:(NSString *)name completion:(void (^)(RecipieCategory *newCategory))completion;
- (void)deleteCategory:(RecipieCategory *)category completion:(void (^)())completion;

- (void)createRecipieWithInfoDictionary:(NSDictionary *)infoDictionary forUser:(User *)user andCategory:(RecipieCategory *)category completion:(void (^)(BOOL isRecipeCreated))completion;
- (void)getRecipiesForCategory:(RecipieCategory *)category completion:(void (^)(NSArray *recipes))completion;
- (void)getRecipieForName:(NSString *)name completion:(void (^)(Recipie *requestedRecipe))completion;
- (void)deleteRecipie:(Recipie *)recipie completion:(void (^)())completion;
- (void)getRecipesForUser:(User *)user withSearchString:(NSString *)searchString completion:(void (^)(NSArray *recipes))completion;

- (void)saveContext;

@end

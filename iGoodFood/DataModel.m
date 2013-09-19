//
//  DataModel.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "DataModel.h"
#import "User.h"
#import "RecipieCategory.h"
#import "Recipie.h"

@implementation DataModel

static NSManagedObjectContext *_managedObjectContext;
static NSManagedObjectModel *_managedObjectModel;
static NSPersistentStoreCoordinator *_persistentStoreCoordinator;
static dispatch_queue_t q;

+ (DataModel *)sharedModel
{
    static DataModel *_sharedModel = nil;
    q = dispatch_queue_create("Data Model Worker Queue", NULL);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    
    return _sharedModel;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - User Managing Methods

- (void)createUserWithName:(NSString *)fullName username:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL userCreated, NSError *error))completion;
{
    if (!completion)
    {
        return;
    }
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"username == %@", username];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;

        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] == 0)
        {
            User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                       inManagedObjectContext:[self managedObjectContext]];
            user.fullName = fullName;
            user.username = username;
            user.password = password;
            
            [self saveContext];
            
            dispatch_async(currentQueue, ^{
                    completion(YES, error);
                });
        }
        else
        {
            dispatch_async(currentQueue, ^{
                    completion(NO, error);
                });
        }
    });
}

- (void)getUserForUsername:(NSString *)username andPassword:(NSString *)password completion:(void (^)(User *newUser, NSError *error))completion
{
    if (!completion)
    {
        return;
    }
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"username == %@ && password == %@", username, password];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;

        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];

        if ([fetchedObjects count] > 0) {
            dispatch_async(currentQueue, ^{
                    completion(fetchedObjects[0], error);
                });
        }
        else
        {
            dispatch_async(currentQueue, ^{
                    completion(nil, error);
                });
        }
    });
}

#pragma mark - Category Managing Methods

- (void)deleteCategory:(RecipieCategory *)category completion:(void (^)())completion
{
    if (!completion)
    {
        return;
    }
    dispatch_async(q, ^{
        [[self managedObjectContext] deleteObject:category];
        [self saveContext];
        
        dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
    });
}

- (void)getCategoryForName:(NSString *)name completion:(void (^)(RecipieCategory *newCategory, NSError *error))completion
{
    if (!completion)
    {
        return;
    }
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecipieCategory"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"name == %@", name];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;

        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] > 0)
        {
            dispatch_async(currentQueue, ^{
                    completion(fetchedObjects[0], error);
                });
        }
        else
        {
            dispatch_async(currentQueue, ^{
                    completion(nil, error);
                });
        }

    });
}

- (void)createCategoryWithName:(NSString *)categoryName forUser:(User *)user completion:(void (^)(BOOL isCategoryCreated, NSError *error))completion
{
    if (!completion)
    {
        return;
    }
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecipieCategory"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"name == %@", categoryName];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;

        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] == 0)
        {
            RecipieCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"RecipieCategory"
                                                                      inManagedObjectContext:[self managedObjectContext]];
            category.name = categoryName;
            category.user = user;
            
            [user addCategoriesObject:category];
            
            [self saveContext];
            
            dispatch_async(currentQueue, ^{
                    completion(YES, error);
                });
        }
        else
        {
            dispatch_async(currentQueue, ^{
                    completion(NO, error);
                });
        }
    });
}

- (void)getCategoriesForUser:(User *)user completion:(void (^)(NSArray *allCategories, NSError *error))completion
{
    if (!completion)
    {
        return;
    }
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecipieCategory"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"user == %@", user];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;

        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        dispatch_async(currentQueue, ^{
                    completion(fetchedObjects, error);
                });
    });
}

#pragma mark - Recipe Managing Method

- (void)updateRecipe:(Recipie *)oldRecipe withDataDictionary:(NSDictionary *)infoDictionary
{
    dispatch_async(q, ^{
        oldRecipe.name = infoDictionary[@"name"];
        oldRecipe.cookingTime = infoDictionary[@"cookingTime"];
        oldRecipe.image = UIImagePNGRepresentation(infoDictionary[@"image"]);
        oldRecipe.ingredients = infoDictionary[@"ingredients"];
        oldRecipe.howToCook = infoDictionary[@"howToCook"];
        
        [self saveContext];
    });
}

- (void)deleteRecipie:(Recipie *)recipie completion:(void (^)())completion
{
    if (!completion)
    {
        return;
    }
    dispatch_async(q, ^{
        [[self managedObjectContext] deleteObject:recipie];
        [self saveContext];
        
        dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
    });
}

- (void)getRecipieForName:(NSString *)name completion:(void (^)(Recipie *requestedRecipe, NSError *error))completion
{
    if (!completion)
    {
        return;
    }
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipie"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"name == %@", name];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] > 0)
        {
            dispatch_async(currentQueue, ^{
                    completion(fetchedObjects[0], error);
                });
        }
        else
        {
            dispatch_async(currentQueue, ^{
                    completion(nil, error);
                });
        }
    });
}

- (void)createRecipieWithInfoDictionary:(NSDictionary *)infoDictionary forUser:(User *)user andCategory:(RecipieCategory *)category completion:(void (^)(BOOL isRecipeCreated, NSError *error))completion
{
    if (!completion)
    {
        return;
    }
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipie"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"name == %@", infoDictionary[@"name"]];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;

        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] == 0)
        {
            Recipie *recipie = [NSEntityDescription insertNewObjectForEntityForName:@"Recipie"
                                                             inManagedObjectContext:[self managedObjectContext]];
            recipie.name = infoDictionary[@"name"];
            recipie.cookingTime = infoDictionary[@"cookingTime"];
            recipie.image = UIImagePNGRepresentation(infoDictionary[@"image"]);
            recipie.ingredients = infoDictionary[@"ingredients"];
            recipie.howToCook = infoDictionary[@"howToCook"];
            
            recipie.user = user;
            recipie.category = category;

            [user addRecipiesObject:recipie];
            
            [category addRecipiesObject:recipie];
            
            [self saveContext];
            
            dispatch_async(currentQueue, ^{
                    completion(YES, error);
                });
        }
        else
        {
            dispatch_async(currentQueue, ^{
                completion(NO, error);
            });
        }
    });
}

- (void)getRecipesForUser:(User *)user withSearchString:(NSString *)searchString completion:(void (^)(NSArray *recipes, NSError *error))completion
{
    if (!completion)
    {
        return;
    }
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipie"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"user == %@ AND (name CONTAINS[c] %@ OR ingredients CONTAINS[c] %@ OR howToCook CONTAINS[c] %@)", user, searchString, searchString, searchString];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;

        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        dispatch_async(currentQueue, ^{
                    completion(fetchedObjects, error);
                });
    });
}

- (void)getRecipiesForCategory:(RecipieCategory *)category completion:(void (^)(NSArray *recipes, NSError *error))completion
{
    if (!completion)
    {
        return;
    }
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipie"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"category == %@", category];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;

        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] > 0)
        {
            dispatch_async(currentQueue, ^{
                    completion(fetchedObjects, error);
                });
        }
        else
        {
            dispatch_async(currentQueue, ^{
                    completion(nil, error);
                });
        }
    });
}


#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iGoodFood" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iGoodFood.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end

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

- (void)createUserWithName:(NSString *)fullName username:(NSString *)username andPassword:(NSString *)password completion:(void (^)(BOOL userCreated))completion
{
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        NSError *error;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"username == %@", username];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] == 0)
        {
            User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                       inManagedObjectContext:[self managedObjectContext]];
            user.fullName = fullName;
            user.username = username;
            user.password = password;
            
            [self saveContext];
            
            if (completion) {
                dispatch_async(currentQueue, ^{
                    completion(YES);
                });
            }
        }
        else
        {
            if(completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(NO);
                });
            }
        }
    });
}

- (void)getUserForUsername:(NSString *)username andPassword:(NSString *)password completion:(void (^)(User *newUser))completion
{
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
#warning Declare variable as close as it's possible to their first usage
        NSError *error;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"username == %@ && password == %@", username, password];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
#warning Pass the error Obj to the completion
        
        if ([fetchedObjects count] > 0) {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(fetchedObjects[0]);
                });
            }
        }
        else
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(nil);
                });
            }
        }
    });
}

#pragma mark - Category Managing Methods

- (void)deleteCategory:(RecipieCategory *)category completion:(void (^)())completion
{
    dispatch_async(q, ^{
        [[self managedObjectContext] deleteObject:category];
        [self saveContext];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)getCategoryForName:(NSString *)name completion:(void (^)(RecipieCategory *newCategory))completion
{
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        NSError *error;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecipieCategory"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"name == %@", name];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] > 0)
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(fetchedObjects[0]);
                });
            }
        }
        else
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(nil);
                });
            }
        }

    });
}

- (void)createCategoryWithName:(NSString *)categoryName forUser:(User *)user completion:(void (^)(BOOL isCategoryCreated))completion
{
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        NSError *error;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecipieCategory"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"name == %@", categoryName];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] == 0)
        {
            RecipieCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"RecipieCategory"
                                                                      inManagedObjectContext:[self managedObjectContext]];
            category.name = categoryName;
            category.user = user;
            
            NSMutableArray *userCategories = [NSMutableArray arrayWithArray:[user.categories allObjects]];
            [userCategories addObject:category];
            [user.categories setByAddingObjectsFromArray:userCategories];
            
            [self saveContext];
            
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(YES);
                });
            }
        }
        else
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(NO);
                });
            }
        }
    });
}

- (void)getCategoriesForUser:(User *)user completion:(void (^)(NSArray *allCategories))completion
{
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSError *error;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecipieCategory"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"user == %@", user];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] > 0)
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(fetchedObjects);
                });
            }
        }
        else
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(nil);
                });
            }
        }
    });
}

#pragma mark - Recipe Managing Method

- (void)deleteRecipie:(Recipie *)recipie completion:(void (^)())completion
{
    dispatch_async(q, ^{
        [[self managedObjectContext] deleteObject:recipie];
        [self saveContext];
        
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)getRecipieForName:(NSString *)name completion:(void (^)(Recipie *requestedRecipe))completion
{
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        NSError *error;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipie"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"name == %@", name];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] > 0)
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(fetchedObjects[0]);
                });
            }
        }
        else
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(nil);
                });
            }
        }
    });
}

- (void)createRecipieWithInfoDictionary:(NSDictionary *)infoDictionary forUser:(User *)user andCategory:(RecipieCategory *)category completion:(void (^)(BOOL isRecipeCreated))completion
{
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        
        NSError *error;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipie"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"name == %@", infoDictionary[@"name"]];
        
        [fetchRequest setPredicate:predicate];
        
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
            
            NSMutableArray *userRecipies = [NSMutableArray arrayWithArray:[user.recipies allObjects]];
            [userRecipies addObject:recipie];
            [user.recipies setByAddingObjectsFromArray:userRecipies];
            
            NSMutableArray *categoryRecipies = [NSMutableArray arrayWithArray:[category.recipies allObjects]];
            [categoryRecipies addObject:recipie];
            [category.recipies setByAddingObjectsFromArray:categoryRecipies];
            
            [self saveContext];
            
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(YES);
                });
            }
        }
        else
        {
            if (completion)
            {
                completion(NO);
            }
        }
    });
}

- (void)getRecipesForUser:(User *)user withSearchString:(NSString *)searchString completion:(void (^)(NSArray *recipes))completion
{
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        NSError *error;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipie"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"user == %@ AND (name CONTAINS[c] %@ OR ingredients CONTAINS[c] %@ OR howToCook CONTAINS[c] %@)", user, searchString, searchString, searchString];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] > 0)
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(fetchedObjects);
                });
            }
        }
        else
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(nil);
                });
            }
        }
    });
}

- (void)getRecipiesForCategory:(RecipieCategory *)category completion:(void (^)(NSArray *recipes))completion
{
    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(q, ^{
        NSError *error;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipie"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"category == %@", category];
        
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] > 0)
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(fetchedObjects);
                });
            }
        }
        else
        {
            if (completion)
            {
                dispatch_async(currentQueue, ^{
                    completion(nil);
                });
            }
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

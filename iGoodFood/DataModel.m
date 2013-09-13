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

@implementation DataModel

static NSManagedObjectContext *_managedObjectContext;
static NSManagedObjectModel *_managedObjectModel;
static NSPersistentStoreCoordinator *_persistentStoreCoordinator;


+ (void)saveContext
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

+ (BOOL)createUserWithName:(NSString *)fullName username:(NSString *)username andPassword:(NSString *)password
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"username == %@", username];
    
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedObjects count] == 0) {
        User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                   inManagedObjectContext:[self managedObjectContext]];
        user.fullName = fullName;
        user.username = username;
        user.password = password;
        
        [self saveContext];
        
        return YES;
    }
    
    return NO;
}

+ (User *)getUserForUsername:(NSString *)username andPassword:(NSString *)password
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"username == %@ && password == %@", username, password];

    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedObjects count] > 0) {
        return fetchedObjects[0];
    }
    
    return nil;
}

+ (BOOL)createCategoryWithName:(NSString *)categoryName forUser:(User *)user
{
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
        
        [self saveContext];
        
        return YES;
    }
    
    return NO;
}

+ (NSArray *)getCategoriesForUser:(User *)user
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RecipieCategory"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"user == %@", user];
    
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedObjects count] > 0) {
        return fetchedObjects;
    }
    
    return nil;
}

#pragma mark - Core Data stack

+ (NSManagedObjectContext *)managedObjectContext
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

+ (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iGoodFood" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
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

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end

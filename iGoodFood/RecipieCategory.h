//
//  RecipieCategory.h
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/17/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipie, User;

@interface RecipieCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *recipies;
@property (nonatomic, retain) User *user;
@end

@interface RecipieCategory (CoreDataGeneratedAccessors)

- (void)addRecipiesObject:(Recipie *)value;
- (void)removeRecipiesObject:(Recipie *)value;
- (void)addRecipies:(NSSet *)values;
- (void)removeRecipies:(NSSet *)values;

@end

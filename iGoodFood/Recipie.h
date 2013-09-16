//
//  Recipie.h
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/16/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RecipieCategory, User;

@interface Recipie : NSManagedObject

@property (nonatomic, retain) NSNumber * cookingTime;
@property (nonatomic, retain) NSString * howToCook;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * ingredients;
@property (nonatomic, retain) NSString * recipieDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) RecipieCategory *category;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Recipie (CoreDataGeneratedAccessors)

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end

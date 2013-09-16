//
//  Tag.h
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/16/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipie;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) Recipie *recipe;

@end

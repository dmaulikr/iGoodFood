//
//  TextAnalyzer.h
//  TextAnalyzer
//
//  Created by Ivelin Ivanov on 9/4/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextAnalyzer : NSObject

+(void)analyzeText:(NSString *)text withCompletion:(void (^)(NSMutableArray *))block;

@end

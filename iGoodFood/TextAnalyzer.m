//
//  TextAnalyzer.m
//  TextAnalyzer
//
//  Created by Ivelin Ivanov on 9/4/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "TextAnalyzer.h"

@implementation TextAnalyzer

+(NSUInteger)numberOfWordsInString:(NSString *)str {
    __block NSUInteger count = 0;
    [str enumerateSubstringsInRange:NSMakeRange(0, [str length])
                            options:NSStringEnumerationByWords|NSStringEnumerationSubstringNotRequired
                         usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                             count++;
                         }];
    return count;
}


+(void)analyzeText:(NSString *)text withCompletion:(void (^)(NSMutableArray *))block
{
    NSMutableArray *tags = [[NSMutableArray alloc] initWithCapacity:20];
    
    NSString *question = text;
    
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    
    tagger.string = question;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void)
                   {
                       
                       NSUInteger wordCount = [self numberOfWordsInString:text];
                       
                       [tagger enumerateTagsInRange:NSMakeRange(0, [question length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                           
                           static int invocationCounter = 0;
                           
                           @synchronized(tags)
                           {
                               invocationCounter++;
                               
                               if ([tag isEqualToString:@"Noun"] || [tag isEqualToString:@"Verb"]) {
                                   [tags addObject:[question substringWithRange:tokenRange]];
                               }
                               
                               if (invocationCounter >= wordCount)
                               {
                                   *stop = YES;
                                   dispatch_async(dispatch_get_main_queue(),^(void)
                                                  {
                                                      block(tags);
                                                  });
                                   invocationCounter = 0;
                               }
                           }
                       }];
                   });
}


@end

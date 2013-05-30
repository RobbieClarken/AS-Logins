//
//  CodeHelper.h
//  AS Logins
//
//  Created by Robbie Clarken on 30/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeHelper : NSObject

+ (NSString *)securedCode;
+ (BOOL)setSecuredCodeFromCodeHash:(NSUInteger)codeHash;
+ (BOOL)securedCodeMatchesCodeHash:(NSUInteger)codeHash;

@end

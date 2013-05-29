//
//  KeychainHelper.h
//  AS Logins
//
//  Created by Robbie Clarken on 30/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainHelper : NSObject

- (id)initWithServiceName:(NSString *)serviceName;
- (NSString *)stringMatchingIdentifier:(NSString *)identifier;
- (BOOL)createValue:(NSString *)value forIdentifier:(NSString *)identifier;
- (BOOL)updateValue:(NSString *)value forIdentifier:(NSString *)identifier;
- (void)deleteItemWithIdentifier:(NSString *)identifier;

@end

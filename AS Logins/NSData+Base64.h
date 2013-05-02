//
//  NSData+Base64.h
//  AS Logins
//
//  Created by Robbie Clarken on 2/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

+ (NSString *)encodeBase64WithData:(NSData *)objData;
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;

@end

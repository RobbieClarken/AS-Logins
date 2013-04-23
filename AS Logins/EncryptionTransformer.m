//
//  EncryptionTransformer.m
//  AS Logins
//
//  Created by Robbie Clarken on 21/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "EncryptionTransformer.h"
#import "NSData+AES256.h"

@implementation EncryptionTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (NSString *)key {
    // TODO: Import this from a header file not in git
    return @"secret key";
}

- (id)transformedValue:(NSString *)value {
    NSData *dataForEncryption = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [dataForEncryption AES256EncryptWithKey:[self key]];
}

- (id)reverseTransformedValue:(NSData *)value {
    NSData *decryptedData = [value AES256DecryptWithKey:[self key]];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

@end

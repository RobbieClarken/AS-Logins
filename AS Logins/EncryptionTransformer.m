//
//  EncryptionTransformer.m
//  AS Logins
//
//  Created by Robbie Clarken on 21/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "EncryptionTransformer.h"
#import "NSData+AES256.h"
#import "NSData+Base64.h"
#import "NSData+Random.h"
#import "SiteSettings.h"

@implementation EncryptionTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (NSString *)key {
    return kSecretKey;
}

- (id)transformedValue:(NSString *)value {
    NSData *salt = [NSData randomDataOfLength:32];
    NSData *dataForEncryption = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [dataForEncryption AES256EncryptWithKey:[self key] andSalt:salt];
    NSMutableData *mutableEncryptedData = [NSMutableData dataWithData:salt];
    [mutableEncryptedData appendData:encryptedData];
    return mutableEncryptedData;
}

- (id)reverseTransformedValue:(NSData *)data {
    NSData *salt = [data subdataWithRange:NSMakeRange(0, 32)];
    NSData *encrypedData = [data subdataWithRange:NSMakeRange(32, [data length] - [salt length])];
    NSData *decryptedData = [encrypedData AES256DecryptWithKey:[self key] andSalt:salt];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

@end

//
//  CodeHelper.m
//  AS Logins
//
//  Created by Robbie Clarken on 30/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "CodeHelper.h"
#import "KeychainHelper.h"
#import "SiteSettings.h"
#import <CommonCrypto/CommonHMAC.h>

static NSString *CodeKeychainIdentifier = @"SecuredCode";
static NSString *Salt = @"9365e4387665a34897b65199934c5ef74e6a5b3949c8f80e52a8edf4e0a514e1";

@implementation CodeHelper

+ (NSString *)securedCode {
    KeychainHelper *keychainHelper = [[KeychainHelper alloc] initWithServiceName:kKeychainServiceName];
    return [keychainHelper stringMatchingIdentifier:CodeKeychainIdentifier];
}

+ (BOOL)setSecuredCodeFromCodeHash:(NSUInteger)codeHash {
    // TODO: Perhaps use
    KeychainHelper *keychainHelper = [[KeychainHelper alloc] initWithServiceName:kKeychainServiceName];
    NSString *securedCode = [self securedCodeFromCodeHash:codeHash];
    return [keychainHelper setValue:securedCode forIdentifier:CodeKeychainIdentifier];
}

+ (NSString *)securedCodeFromCodeHash:(NSUInteger)codeHash {
    NSString *saltedHashString = [NSString stringWithFormat:@"%i%@", codeHash, Salt];
    NSString *securedCode = [self computeSHA256DigestForString:saltedHashString];
    return securedCode;
}

+ (BOOL)securedCodeMatchesCodeHash:(NSUInteger)codeHash {
    NSString *savedSecuredCode = [self securedCode];
    NSString *inputSecuredCode = [self securedCodeFromCodeHash:codeHash];
    return [inputSecuredCode isEqualToString:savedSecuredCode];
}

+ (NSString*)computeSHA256DigestForString:(NSString *)input {
    // Borrowed from http://www.raywenderlich.com/6475/basic-security-in-ios-5-tutorial-part-1
    
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, data.length, digest);
    
    // Setup our Objective-C output.
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}


@end

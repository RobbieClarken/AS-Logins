//
//  Login+Encryption.m
//  AS Logins
//
//  Created by Robbie Clarken on 12/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Login+Encryption.h"
#import "EncryptionTransformer.h"
#import "NSData+Base64.h"

@implementation Login (Encryption)

- (NSString *)decryptedUsername {
    return [self decryptString:self.username];
}

- (NSString *)decryptedPassword {
    return [self decryptString:self.password];
}

- (void)setUsernameFromUnencryptedString:(NSString *)unencryptedUsername {
    self.username = [self encryptString:unencryptedUsername];
}

- (void)setPasswordFromUnencryptedString:(NSString *)unencryptedPassword{
    self.password = [self encryptString:unencryptedPassword];
}

- (NSString *)encryptString:(NSString *)string {
    EncryptionTransformer *encryptionTransformer = [[EncryptionTransformer alloc] init];
    return [NSData encodeBase64WithData:[encryptionTransformer transformedValue:string]];
}

- (NSString *)decryptString:(NSString *)string {
    EncryptionTransformer *encryptionTransformer = [[EncryptionTransformer alloc] init];
    return (NSString *)[encryptionTransformer reverseTransformedValue:[NSData decodeBase64WithString:string]];
}

@end

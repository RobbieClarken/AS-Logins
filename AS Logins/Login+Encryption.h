//
//  Login+Encryption.h
//  AS Logins
//
//  Created by Robbie Clarken on 12/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Login.h"

@interface Login (Encryption)

- (NSString *)decryptedUsername;
- (NSString *)decryptedPassword;
- (void)setUsernameFromUnencryptedString:(NSString *)unencryptedUsername;
- (void)setPasswordFromUnencryptedString:(NSString *)unencryptedPassword;

@end

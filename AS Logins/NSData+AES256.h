//
//  NSData+AES256.h
//  AS Logins
//
//  http://pastie.org/426530
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)

+ (NSData *)randomDataOfLength:(NSUInteger)length;
- (NSData *)AES256EncryptWithKey:(NSString *)key andSalt:(NSData *)salt;
- (NSData *)AES256DecryptWithKey:(NSString *)key andSalt:(NSData *)salt;

@end

// NSKeyedArchiver+butWithNSError.h semver:1.0b2
//   Copyright (c) 2014 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/NSKeyedArchiver-butWithNSError

#import <Foundation/Foundation.h>

@interface NSKeyedArchiver (butWithNSError)
+ (NSData*)jr_archivedDataWithRootObject:(id)rootObject
                    requiresSecureCoding:(BOOL)requiresSecureCoding
                                   error:(NSError**)error;
@end

//--

@interface NSKeyedUnarchiver (butWithNSError)
+ (id)jr_unarchiveData:(NSData*)data
  requiresSecureCoding:(BOOL)requiresSecureCoding
             whitelist:(NSArray*)customClassWhitelist
                 error:(NSError**)error;
@end
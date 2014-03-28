//  Copyright (c) 2014 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import <Foundation/Foundation.h>

@interface NSKeyedArchiver (butWithNSError)
+ (id)jr_archivedDataWithRootObject:(id)rootObject
               requiresSecureCoding:(BOOL)requiresSecureCoding
                              error:(NSError**)error;
@end

//--

@interface NSKeyedUnarchiver (butWithNSError)
+ (id)jr_unarchiveData:(NSData*)data
  requiresSecureCoding:(BOOL)secure
             whitelist:(NSArray*)customClassWhitelist
                 error:(NSError**)error;
@end
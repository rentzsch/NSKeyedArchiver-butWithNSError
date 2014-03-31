// NSKeyedArchiver+butWithNSError.m semver:1.0b1
//   Copyright (c) 2014 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/NSKeyedArchiver-butWithNSError

#import "NSKeyedArchiver+butWithNSError.h"

@implementation NSKeyedArchiver (butWithNSError)

+ (NSData*)jr_archivedDataWithRootObject:(id)rootObject
                    requiresSecureCoding:(BOOL)requiresSecureCoding
                                   error:(NSError**)error
{
    NSMutableData *result = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:result];
#if !__has_feature(objc_arc)
    [archiver autorelease];
#endif
    if (requiresSecureCoding) {
        archiver.requiresSecureCoding = YES;
    }
    @try {
        [archiver encodeObject:rootObject forKey:NSKeyedArchiveRootObjectKey];
        [archiver finishEncoding];
        return result;
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:NSInvalidArchiveOperationException
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: exception.name,
                                                NSLocalizedFailureReasonErrorKey: exception.reason}];
        }
        return nil;
    }
}
@end

@implementation NSKeyedUnarchiver (butWithNSError)

+ (id)jr_unarchiveData:(NSData*)data
  requiresSecureCoding:(BOOL)requiresSecureCoding
             whitelist:(NSArray*)customClassWhitelist
                 error:(NSError**)error
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
#if !__has_feature(objc_arc)
    [unarchiver autorelease];
#endif
    if (requiresSecureCoding) {
        unarchiver.requiresSecureCoding = YES;
    }
    
    @try {
        NSMutableSet *classWhitelist = [NSMutableSet setWithArray:@[[NSArray class],
                                                                    [NSDictionary class],
                                                                    [NSSet class],
                                                                    [NSOrderedSet class],
                                                                    [NSString class],
                                                                    [NSNumber class],
                                                                    [NSValue class],
                                                                    [NSDate class],
                                                                    [NSData class],
                                                                    [NSNull class],
                                                                    [NSURL class],
                                                                    [NSUUID class],
                                                                    [NSError class],
                                                                    [NSTimeZone class],
                                                                    ]];
        if (customClassWhitelist) {
            [classWhitelist addObjectsFromArray:customClassWhitelist];
        }
        id result = [unarchiver decodeObjectOfClasses:classWhitelist
                                               forKey:NSKeyedArchiveRootObjectKey];
        [unarchiver finishDecoding];
        return result;
    } @catch(NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:NSInvalidUnarchiveOperationException
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: exception.name,
                                                NSLocalizedFailureReasonErrorKey: exception.reason}];
        }
        return nil;
    }
}

@end
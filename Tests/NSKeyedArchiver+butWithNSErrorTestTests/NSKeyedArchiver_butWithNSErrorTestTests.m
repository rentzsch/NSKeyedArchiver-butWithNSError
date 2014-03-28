#import <XCTest/XCTest.h>
#import "NSKeyedArchiver+butWithNSError.h"

@interface MyClassConformingToNSCoding : NSObject <NSCoding>
@property(nonatomic, strong)  NSString  *payload;
@end

@interface MyClassConformingToNSSecureCoding : NSObject <NSSecureCoding>
@property(nonatomic, strong)  NSString  *payload;
@end

typedef void (^SecureEncodeDecodeBlock)(BOOL secureEncode, BOOL secureDecode);
static void testEverySecureEncodeDecodeCombination(SecureEncodeDecodeBlock block) {
    NSArray *secureEncodeDecodeTruthTable = @[
                                              @[@NO,   @NO],
                                              @[@YES,  @NO],
                                              @[@NO,   @YES],
                                              @[@YES,  @YES],
                                              ];
    for (NSArray *secureEncodeCode in secureEncodeDecodeTruthTable) {
        BOOL secureEncode = [secureEncodeCode[0] boolValue];
        BOOL secureDecode = [secureEncodeCode[1] boolValue];
        block(secureEncode, secureDecode);
    }
}

@interface NSKeyedArchiver_butWithNSErrorTestTests : XCTestCase
@end

@implementation NSKeyedArchiver_butWithNSErrorTestTests

- (void)testPlist {
    testEverySecureEncodeDecodeCombination(^(BOOL secureEncode, BOOL secureDecode) {
        NSData *data;
        {{
            NSDictionary *originalObject = @{@"payload": @"fred"};
            NSError *error = nil;
            data = [NSKeyedArchiver jr_archivedDataWithRootObject:originalObject
                                             requiresSecureCoding:secureEncode
                                                            error:&error];
            XCTAssertNotNil(data, @"");
            XCTAssertNotEqual([data length], 0, @"");
            XCTAssertNil(error, @"");
        }}
        {{
            NSError *error = nil;
            NSDictionary *decodedObject = [NSKeyedUnarchiver jr_unarchiveData:data
                                                         requiresSecureCoding:secureDecode
                                                                    whitelist:nil
                                                                        error:&error];
            XCTAssertNotNil(decodedObject, @"");
            XCTAssertNil(error, @"");
            XCTAssert([decodedObject isKindOfClass:[NSDictionary class]], @"");
            XCTAssertEqualObjects(decodedObject[@"payload"], @"fred", @"");
        }}
    });
}

- (void)testNSCodingInsecureWorks {
    NSData *data;
    {{
        MyClassConformingToNSCoding *originalObject = [MyClassConformingToNSCoding new];
        originalObject.payload = @"fred";
        
        NSError *error = nil;
        data = [NSKeyedArchiver jr_archivedDataWithRootObject:originalObject
                                         requiresSecureCoding:NO
                                                        error:&error];
        XCTAssertNotNil(data, @"");
        XCTAssertNotEqual([data length], 0, @"");
        XCTAssertNil(error, @"");
    }}
    {{
        NSError *error = nil;
        MyClassConformingToNSCoding *decodedObject = [NSKeyedUnarchiver jr_unarchiveData:data
                                                                    requiresSecureCoding:NO
                                                                               whitelist:nil
                                                                                   error:&error];
        XCTAssertNotNil(decodedObject, @"");
        XCTAssertNil(error, @"");
        XCTAssert([decodedObject isKindOfClass:[MyClassConformingToNSCoding class]], @"");
        XCTAssertEqualObjects(decodedObject.payload, @"fred", @"");
    }}
}

- (void)testNSCodingSecureFails {
    MyClassConformingToNSCoding *originalObject = [MyClassConformingToNSCoding new];
    originalObject.payload = @"fred";
    
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver jr_archivedDataWithRootObject:originalObject
                                             requiresSecureCoding:YES
                                                            error:&error];
    XCTAssertNil(data, @"");
    XCTAssertNotNil(error, @"");
    XCTAssertEqualObjects(error.domain, NSInvalidArchiveOperationException, @"");
}

- (void)XtestNSSecureCoding {
    testEverySecureEncodeDecodeCombination(^(BOOL secureEncode, BOOL secureDecode) {
        NSData *data;
        {{
            MyClassConformingToNSSecureCoding *originalObject = [MyClassConformingToNSSecureCoding new];
            originalObject.payload = @"fred";
            
            NSError *error = nil;
            data = [NSKeyedArchiver jr_archivedDataWithRootObject:originalObject
                                             requiresSecureCoding:secureEncode
                                                            error:&error];
            XCTAssertNotNil(data, @"");
            XCTAssertNotEqual([data length], 0, @"");
            XCTAssertNil(error, @"");
        }}
        
        if (secureDecode) {
            {{
                // Ensure decoding fails if we don't whitelist our custom class.
                NSError *error = nil;
                MyClassConformingToNSSecureCoding *decodedObject = [NSKeyedUnarchiver jr_unarchiveData:data
                                                                                  requiresSecureCoding:secureDecode
                                                                                             whitelist:nil
                                                                                                 error:&error];
                XCTAssertNil(decodedObject, @"");
                XCTAssertNotNil(error, @"");
                XCTAssertEqualObjects(error.domain, NSInvalidUnarchiveOperationException, @"");
            }}
            {{
                // Ensure decoding succeeds if we whitelist our custom class.
                NSError *error = nil;
                MyClassConformingToNSSecureCoding *decodedObject = [NSKeyedUnarchiver jr_unarchiveData:data
                                                                                  requiresSecureCoding:secureDecode
                                                                                             whitelist:@[[MyClassConformingToNSSecureCoding class]]
                                                                                                 error:&error];
                XCTAssertNotNil(decodedObject, @"");
                XCTAssertNil(error, @"");
                XCTAssert([decodedObject isKindOfClass:[MyClassConformingToNSSecureCoding class]], @"");
                XCTAssertEqualObjects(decodedObject.payload, @"fred", @"");
            }}
        } else {
            NSError *error = nil;
            MyClassConformingToNSSecureCoding *decodedObject = [NSKeyedUnarchiver jr_unarchiveData:data
                                                                              requiresSecureCoding:secureDecode
                                                                                         whitelist:nil
                                                                                             error:&error];
            XCTAssertNotNil(decodedObject, @"");
            XCTAssertNil(error, @"");
            XCTAssert([decodedObject isKindOfClass:[MyClassConformingToNSSecureCoding class]], @"");
            XCTAssertEqualObjects(decodedObject.payload, @"fred", @"");
        }
    });
}

@end

@implementation MyClassConformingToNSCoding

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if (self) {
        _payload = [decoder decodeObjectForKey:@"payload"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:self.payload forKey:@"payload"];
}

@end

@implementation MyClassConformingToNSSecureCoding

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if (self) {
        _payload = [decoder decodeObjectOfClass:[NSString class]
                                         forKey:@"payload"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:self.payload forKey:@"payload"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
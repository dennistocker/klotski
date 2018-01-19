//
//  comparable.h
//

#import <Foundation/Foundation.h>


//NOTE: Class must check to make sure it is the same class as whatever is passed in
@protocol Comparable

- (int)compareTo:(id<Comparable, NSObject>)object;
- (BOOL)isEqual:(id<Comparable, NSObject>)object;

@end

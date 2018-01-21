//
//  PriorityQueue.h
//

#import <Foundation/Foundation.h>
#import "Comparable.h"

//Implements a priority queue. All objects in queue must implement the comparable protocol and must be all of the same type. The queue can be explicity typed at initialization, otherwise the type of the first object entered will be the type of the queue
@interface PriorityQueue : NSObject{
    NSMutableArray *queue;
    Class type;
}

- (id)init;
- (id)initWithObjects:(NSSet *)objects;
- (id)initWithCapacity:(int)capacity;
- (id)initWithCapacity:(int)capacity andType:(Class)oType; //Queue will reject objects not of that type

#pragma mark - Useful information
- (BOOL)isEmpty;
- (BOOL)contains:(id<Comparable, NSObject>)object;
- (Class)typeOfAllowedObjects; //Returns the type of objects allowed to be stored in the queue
- (NSUInteger) size;

#pragma mark - Mutation
- (void)clear;
- (BOOL)add:(id<Comparable, NSObject>)object;
- (void)remove:(id<Comparable, NSObject>)object;

#pragma mark - Getting things out
- (id)peek;
- (id)poll;
- (id)objectMatchingObject:(id<Comparable, NSObject>)object;
- (NSArray *)toArray;

#pragma mark -
- (void)print;

@end

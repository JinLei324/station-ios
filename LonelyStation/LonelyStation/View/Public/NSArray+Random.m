//
//  NSArray+Random.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/5/1.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "NSArray+Random.h"

@implementation NSArray(NSArray_Random)

- (NSArray *)randomSelectionWithCount:(NSUInteger)count {
    if ([self count] < count) {
        return nil;
    } else if ([self count] == count) {
        return self;
    }
    NSMutableSet* selection = [[NSMutableSet alloc] init];
    while ([selection count] < count) {
        id randomObject = [self objectAtIndex: arc4random() % [self count]];
        [selection addObject:randomObject]; }
    return [selection allObjects];
}


@end

//
//  EMObject.m
//  emeNew
//
//  Created by zk on 15/12/14.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "EMObject.h"

@implementation EMObject

- (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { return [self yy_modelInitWithCoder:aDecoder]; }

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    return YES;
}



@end

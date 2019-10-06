//
//  SetDeviceToken.m
//  iMoojigae
//
//  Created by dykim on 06/10/2019.
//  Copyright © 2019 dykim. All rights reserved.
//

#import "SetTokenStorage.h"
#import "env.h"

@implementation SetTokenStorage

@synthesize token;

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:token forKey:@"token"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.token = [aDecoder decodeObjectForKey:@"token"];
    return self;
}

- (void)dealloc
{
    self.token = nil;
}
@end

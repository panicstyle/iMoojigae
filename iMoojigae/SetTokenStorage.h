//
//  SetDeviceToken.h
//  iMoojigae
//
//  Created by dykim on 06/10/2019.
//  Copyright © 2019 dykim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetTokenStorage : NSObject <NSCoding> {
    NSString *token;
}

@property (nonatomic, copy) NSString *token;

@end

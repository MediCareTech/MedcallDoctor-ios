//
//  LocaltyResponseModel.h
//  SmartRx
//
//  Created by Gowtham on 15/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocaltyResponseModel : NSObject

@property(nonatomic,strong) NSString *localityName;
@property(nonatomic,strong) NSString *localityId;
@property(nonatomic,strong) NSString *zoneName;
@property(nonatomic,strong) NSString *zoneId;

@end

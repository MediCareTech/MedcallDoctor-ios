//
//  LocationDetailsResponseModel.h
//  smartRxDoctor
//
//  Created by Gowtham on 11/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationDetailsResponseModel : NSObject
@property(nonatomic,strong) NSString *cityName;
@property(nonatomic,strong) NSString *cityId;
@property(nonatomic,strong) NSString *localityName;
@property(nonatomic,strong) NSString *localityId;
@property(nonatomic,strong) NSString *addressType;
@property(nonatomic,strong) NSString *zipcode;
@property(nonatomic,strong) NSString *address;
@property(nonatomic,strong) NSString *locationId;
@property(nonatomic,strong) NSString *zoneName;
@property(nonatomic,strong) NSString *zoneId;

@end

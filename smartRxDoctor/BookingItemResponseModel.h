//
//  BookingItemResponseModel.h
//  smartRxDoctor
//
//  Created by Gowtham on 27/09/17.
//  Copyright © 2017 Anil Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookingItemResponseModel : NSObject
@property(nonatomic,strong) NSString *bookingTime;
@property(nonatomic,strong) NSString *bookingDate;
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *userMobileNum;
@property(nonatomic,strong) NSString *locationId;
@property(nonatomic,strong) NSString *userAge;
@property(nonatomic,strong) NSString *bookingConId;
@property(nonatomic,strong) NSString *bookingType;
@property(nonatomic,strong) NSString *userGender;
@property(nonatomic,strong) NSString *userImageUrl;
@property(nonatomic,strong) NSString *bookingStatus;
@property(nonatomic,strong) NSString *bookingAppType;
@property(nonatomic,strong) NSString *reason;
@property(nonatomic,strong) NSString *symptom;
@property(nonatomic,strong) NSString *suggestion;


@end

//
//  ResponseParser.h
//  smartRxDoctor
//
//  Created by Gowtham on 27/09/17.
//  Copyright © 2017 Anil Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookingResponseModel.h"
#import "BookingItemResponseModel.h"
#import "LocationsModel.h"
#import "ScheduleDatesResponseModel.h"
@interface ResponseParser : NSObject

+(NSArray *)getBookingItems:(NSDictionary *)tempDict;
+(NSArray *)getLocation:(NSArray *)array;
+(NSString *)getUserGender:(NSString *)gender;
+(NSString *)getDayFromNumber:(NSString *)dayId;
+(NSArray *)getScheduleDatesList:(NSArray *)array;
@end

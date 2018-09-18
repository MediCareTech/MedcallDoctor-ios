//
//  ResponseParser.m
//  smartRxDoctor
//
//  Created by Gowtham on 27/09/17.
//  Copyright © 2017 Anil Kumar. All rights reserved.
//

#import "ResponseParser.h"

@implementation ResponseParser
+(NSArray *)getBookingItems:(NSDictionary *)tempDict{
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    NSArray *keysArr = [tempDict allKeys];
    for (NSString *key in keysArr) {
        BookingResponseModel *model = [[BookingResponseModel alloc] init];
        model.date = key;
        model.filterDate = [self stringToDateConvertor:key];
        NSArray *bookingArr = tempDict[key];
        NSMutableArray *itemsTempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in bookingArr) {
            BookingItemResponseModel *itemModel = [[BookingItemResponseModel alloc] init];
           // NSLog(@"user name:%@",dict[@"name"]);
            if ([dict[@"name"] isKindOfClass:[NSString class]]) {
                itemModel.userName = dict[@"name"];

            }
            itemModel.bookingTime = [self timeConvertor:dict[@"apptime"]];
            itemModel.locationId = dict[@"locid"];
            itemModel.userAge = dict[@"age"];
            itemModel.reason = dict[@"reason"];
            itemModel.bookingConId = dict[@"conid"];
            itemModel.bookingType = [self getBookingType:dict[@"apptype"]];
            itemModel.suggestion = dict[@"suggestion"];
            itemModel.userMobileNum = dict[@"primaryphone"];
            itemModel.symptom = dict[@"symptom"];
            itemModel.bookingDate = key;
            itemModel.userGender = [self getUserGender:dict[@"gender"] ];
            itemModel.userImageUrl = dict[@"profile_pic"];
            itemModel.bookingStatus = dict[@"status"];
            //itemModel.bookingStatus = [self getBookingStatus:dict[@"status"]];
            itemModel.bookingAppType = [self getAppointmentAppType:dict[@"app_method"]];
            [itemsTempArr addObject:itemModel];
        }
        model.bookingItems = [itemsTempArr copy];
        
        [tempArr addObject:model];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"filterDate" ascending:NO];
    [tempArr sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return [tempArr copy];
}
+(NSArray *)getLocation:(NSArray *)array{
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in array) {
        LocationsModel *model = [[LocationsModel alloc]init];
        model.locationId = dict[@"id"];
        if ([dict[@"city"] isKindOfClass:[NSDictionary class]]) {
            model.cityName = dict[@"city"][@"name"];

        }
        model.type = dict[@"type"];

        [tempArr addObject:model];
    }
    return [tempArr copy];
}
+(NSArray *)getScheduleDatesList:(NSArray *)array{
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in array) {
        ScheduleDatesResponseModel *model = [[ScheduleDatesResponseModel alloc]init];
        model.date = [self getDateFromTimeStamp:[dict[@"date"] doubleValue]];
        model.morningTime = dict[@"morning"];
        model.afternoonTime = dict[@"afternoon"];
        [tempArr addObject:model];
    }
    return [tempArr copy];
}
+(NSString *)getAppointmentAppType:(NSString *)appType{
    NSString *typeStr;
    NSInteger typeInt = [appType integerValue];
    switch (typeInt) {
        case 1:
            typeStr = @"Video Conference";
            break;
        case 2:
            typeStr = @"Phone Call";
            break;
        
            
    }
    return typeStr;
}
+(NSString *)getBookingStatus:(NSString *)status{
    NSString *typeStr;
    NSInteger typeInt = [status integerValue];
    switch (typeInt) {
        case 1:
            typeStr = @"Pending";
            break;
        case  2:
            typeStr = @"Confirmed";
            break;
        case 3:
            typeStr = @"Completed";
            break;
        case 4:
            typeStr = @"Cancelled";
            break;
            
    }
    return typeStr;
}
+(NSString *)getUserGender:(NSString *)gender{
   NSString *typeStr;
    if ([gender isKindOfClass:[NSString class]]) {
        
    NSInteger typeInt = [gender integerValue];
    switch (typeInt) {
        case 0:
            typeStr = @"";
            break;
        case  1:
            typeStr = @"Male";
            break;
        case 2:
            typeStr = @"Female";
            break;
            
    }
    }else{
        typeStr = @"";
    }
    return typeStr;
}
+(NSString *)getBookingType:(NSString *)type{
    NSString *typeStr;
    NSInteger typeInt = [type integerValue];
    switch (typeInt) {
        case 1:
            typeStr = @"Appointment";
            break;
        case 2:
            typeStr = @"E-Consult";
            break;
        case 3:
            typeStr = @"Second Opinion";
            break;
     
       
    }
    return typeStr;
}
+(NSString *)dateConvertor:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-mm-dd"];
    NSDate *date = [format dateFromString:dateStr];
    [format setDateFormat:@"dd-MMM-yyyy"];
    return [format stringFromDate:date];

}
+(NSDate *)stringToDateConvertor:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [format dateFromString:dateStr];
    return date;
}
+(NSString *)timeConvertor:(NSString *)timeStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:timeStr];
    
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}
+(NSDate *)getDateFromTimeStamp:(double)intVal{
    NSDate * myDate = [NSDate dateWithTimeIntervalSince1970:intVal];
    NSDate *dateFromUnixStamp = myDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *date = [dateFormatter dateFromString:[dateFormatter stringFromDate:dateFromUnixStamp]];
    return date;
}
+(NSString *)getDayFromNumber:(NSString *)dayId{
    NSString *dayStr;
    int dayCount = [dayId intValue];
    switch (dayCount) {
        case 1:
            dayStr = @"Sun";
            break;
        case 2:
            dayStr = @"Mon";
            break;
        case 3:
            dayStr = @"Tues";
            break;
        case 4:
            dayStr = @"Wed";
            break;
        case 5:
            dayStr = @"Thur";
            break;
        case 6:
            dayStr = @"Fri";
            break;
        case 7:
            dayStr = @"Sat";
            break;
            
            
    }
    return dayStr;
}

@end

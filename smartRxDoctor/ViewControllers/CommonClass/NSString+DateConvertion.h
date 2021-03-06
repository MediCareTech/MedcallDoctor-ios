//
//  NSString+DateConvertion.h
//  SmartRx
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateConvertion)
+(NSString *)convertStringToDate:(NSString *)strDate;
+(NSDate *)stringToDate:(NSString *)dateStr;
+(NSString *)timeFormating:(NSString *)dateStr funcName:(NSString *)functionName;
+(void)comparingTwoDates:(NSString *)date tim:(NSString *)time;
@end

//
//  BookingResponseModel.h
//  smartRxDoctor
//
//  Created by Gowtham on 27/09/17.
//  Copyright © 2017 Anil Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookingResponseModel : NSObject
@property(nonatomic,strong) NSString *date;
@property(nonatomic,strong) NSArray *bookingItems;
@property(nonatomic,strong) NSDate *filterDate;

@end

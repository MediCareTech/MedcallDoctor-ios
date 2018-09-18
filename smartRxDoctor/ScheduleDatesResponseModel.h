//
//  ScheduleDatesResponseModel.h
//  RaphaelDoctor
//
//  Created by Gowtham on 14/11/17.
//  Copyright © 2017 Anil Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleDatesResponseModel : NSObject
@property(nonatomic,strong) NSDate *date;
@property(nonatomic,strong) NSString *morningTime;
@property(nonatomic,strong) NSString *afternoonTime;

@end

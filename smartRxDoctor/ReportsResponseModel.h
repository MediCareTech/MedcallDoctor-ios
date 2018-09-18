//
//  ReportsResponseModel.h
//  smartRxDoctor
//
//  Created by Gowtham on 19/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportsResponseModel : NSObject
@property(nonatomic,strong) NSString *date;
@property(nonatomic,strong) NSString *reportDescrption;
@property(nonatomic,strong) NSString *imagePath;
@property(nonatomic,strong) NSString *uploadedBy;
@end

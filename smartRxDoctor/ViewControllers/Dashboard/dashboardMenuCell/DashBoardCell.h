//
//  DashBoardCell.h
//  smartRxDoctor
//
//  Created by Gowtham on 28/09/17.
//  Copyright © 2017 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookingResponseModel.h"
#import "BookingItemResponseModel.h"

@interface DashBoardCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UIImageView *userImage;
@property(nonatomic,weak) IBOutlet UILabel *userName;
@property(nonatomic,weak) IBOutlet UILabel *userAge;
@property(nonatomic,weak) IBOutlet UILabel *appointmentType;
@property(nonatomic,weak) IBOutlet UILabel *time;
@property(nonatomic,weak) IBOutlet UILabel *status;


-(void)setCellData:(BookingItemResponseModel *)model;
@end

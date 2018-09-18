//
//  DashBoardAppointmentCell.m
//  smartRxDoctor
//
//  Created by Gowtham on 28/09/17.
//  Copyright © 2017 Anil Kumar. All rights reserved.
//

#import "DashBoardAppointmentCell.h"
#import "UIImageView+WebCache.h"

@implementation DashBoardAppointmentCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setCellData:(BookingItemResponseModel *)model{
    self.userName.text = model.userName;
    [self.userName sizeToFit];
    NSString *ageStr = model.userGender;
    if (![model.userAge isEqualToString:@"0"]) {
        ageStr = [ageStr stringByAppendingString:[NSString stringWithFormat:@",%@",model.userAge]];
    }
    self.userAge.text = ageStr;
    //self.userAge.text = [NSString stringWithFormat:@"%@,%@",model.userGender,model.userAge];
    self.userAge.frame = CGRectMake(self.userName.frame.origin.x+self.userName.frame.size.width+4, self.userAge.frame.origin.y, self.userAge.frame.size.width, self.userAge.frame.size.height);
    [self.userAge sizeToFit];
    if ([model.bookingType isEqualToString:@"Second Opinion"]) {
        self.appointmentType.text = [NSString stringWithFormat:@"%@ Appointment",model.bookingType];

    }else {
        self.appointmentType.text = model.bookingType;
    }
    self.time.text = model.bookingTime;
    self.status.text = [self getBookingStatus:model.bookingStatus];;
    if ([self.status.text isEqualToString:@"Pending"] || [self.status.text isEqualToString:@"Cancelled"] ) {
        self.status.textColor = [UIColor redColor];
    } else if([self.status.text isEqualToString:@"Confirmed"] || [model.bookingStatus isEqualToString:@"Completed"]) {
        self.status.textColor = [UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
        
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGE_URL_TEST,model.userImageUrl];

    [self.userImage  sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"img_placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        if (!error)
        {
        }
        else
        {
            NSLog(@"Image Error : %@", error);
        }
    }];
    if (model.reason.length>1) {
        self.deviderView.hidden = NO;
        self.reasonLbl.hidden = NO;
        self.reasonLbl.text = model.reason;
        self.reasonLbl.numberOfLines = 100;
    } else {
        self.deviderView.hidden = YES;
        self.reasonLbl.hidden = YES;

    }
    //img_placeholder@2x.png
}
-(NSString *)getBookingStatus:(NSString *)status{
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
+(NSString *)dateConvertor:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-mm-dd"];
    NSDate *date = [format dateFromString:dateStr];
    [format setDateFormat:@"dd-MMM-yyyy"];
    return [format stringFromDate:date];
    
}

@end

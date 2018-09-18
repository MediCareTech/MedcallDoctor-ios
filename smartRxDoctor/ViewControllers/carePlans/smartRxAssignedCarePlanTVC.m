//
//  smartRxAssignedCarePlanTVC.m
//  smartRxDoctor
//
//  Created by Manju Basha on 10/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "smartRxAssignedCarePlanTVC.h"
#import "NSString+DateConvertion.h"

@implementation smartRxAssignedCarePlanTVC

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCellData:(NSArray *)arrData :(NSInteger)index
{
    self.lblCarePlanTitle.text=[[arrData objectAtIndex:index]objectForKey:@"rehabname"];
    NSString *modifiedDate=[NSString stringWithFormat:@"%@",[[arrData objectAtIndex:index]objectForKey:@"date_assigned"]];
    self.lblCarePlanTime.text = [NSString timeFormating:modifiedDate funcName:@"details"];
}
@end

//
//  smartRxAssignedCarePlanTVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 10/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxAssignedCarePlanTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblCarePlanTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCarePlanTime;
- (void)setCellData:(NSArray *)arrData :(NSInteger)index;
@end

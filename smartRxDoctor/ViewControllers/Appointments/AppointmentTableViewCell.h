//
//  AppointmentTableViewCell.h
//  SmartRx
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppointmentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblDoctorName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblStauts;
@property (weak, nonatomic) IBOutlet UILabel *lblReason;
@property (weak, nonatomic) IBOutlet UIImageView *cellImagView;
@property (weak, nonatomic) IBOutlet UILabel *txtMobile;
-(void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex;
- (IBAction)callBtnClicked:(id)sender;
@end

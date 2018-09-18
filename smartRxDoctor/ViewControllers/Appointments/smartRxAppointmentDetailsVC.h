//
//  smartRxAppointmentDetailsVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxAppointmentDetailsVC : UIViewController<UITableViewDataSource, UITableViewDelegate,MBProgressHUDDelegate>
@property(nonatomic, retain) NSMutableArray *appointmentDetails;
@property (weak, nonatomic) IBOutlet UITableView *tblAppointments;
@property (retain, nonatomic) IBOutlet UIScrollView *aptScroll;
@end

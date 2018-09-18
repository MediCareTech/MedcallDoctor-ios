//
//  smartRxAssignedCarePlanVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 10/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxAssignedCarePlanVC : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
@property (strong, nonatomic) NSArray *arrCarePlans;
@property (weak, nonatomic) IBOutlet UITableView *tblCarePlans;
@property (weak, nonatomic) IBOutlet UILabel *lblNoQes;
@property (strong, nonatomic) NSString *patientID;
@property (retain, nonatomic) NSString *patName;
@property (assign, nonatomic) NSString *strTitle;
@end

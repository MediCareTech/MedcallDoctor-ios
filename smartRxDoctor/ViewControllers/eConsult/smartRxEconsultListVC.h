//
//  smartRxEconsultListVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxEconsultListVC : UIViewController <UITableViewDataSource, UITableViewDelegate,MBProgressHUDDelegate>
@property(nonatomic, retain) NSMutableArray *econsultDetails;
@property (weak, nonatomic) IBOutlet UITableView *tbleConsults;

@end

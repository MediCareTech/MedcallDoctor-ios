//
//  ReportsVc.h
//  smartRxDoctor
//
//  Created by Gowtham on 19/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportsCell.h"
@interface ReportsVc : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,CellDelegate>
@property(nonatomic,strong) NSString *patientId;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noApsLbl;
@property (nonatomic, strong) NSString *pdfPath;

@end

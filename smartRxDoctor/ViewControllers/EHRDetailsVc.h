//
//  EHRDetailsVc.h
//  smartRxDoctor
//
//  Created by Gowtham on 23/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EhrModel.h"

@interface EHRDetailsVc : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSString *patientId;
@property(nonatomic,strong) EhrModel *selectedEhrModel;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;

@property(nonatomic,strong) NSArray *ehrDetailsArr;
@property(nonatomic,strong) NSString *titleStr;
@end

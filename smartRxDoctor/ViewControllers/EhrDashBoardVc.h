//
//  EhrDashBoardVc.h
//  smartRxDoctor
//
//  Created by Gowtham on 23/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EhrDashBoardVc : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate>

@property(nonatomic,strong) NSString *patientId;

@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSArray *ehrArray;
@property (nonatomic, retain) NSArray *ehrDetailsArray;

@end

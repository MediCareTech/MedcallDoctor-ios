//
//  PersonalHealthDataVc.h
//  smartRxDoctor
//
//  Created by Gowtham on 19/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalHealthDataVc : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,weak) IBOutlet UITableView *phrListTable;
@property (nonatomic, retain) NSArray *healthMeasures;

@end

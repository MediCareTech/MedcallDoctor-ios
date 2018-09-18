//
//  smartRxPatientLookUp.h
//  smartRxDoctor
//
//  Created by Manju Basha on 09/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxPatientLookUp : UIViewController<MBProgressHUDDelegate, loginDelegate, UIScrollViewDelegate>
@property (weak, nonatomic)IBOutlet UITextField *searchField;
@property (weak, nonatomic)IBOutlet UILabel *noMatchLabel;
@property (weak, nonatomic) IBOutlet UITableView *patientTableView;
@property (retain, nonatomic) IBOutlet UIScrollView *patientTableScroll;
@end

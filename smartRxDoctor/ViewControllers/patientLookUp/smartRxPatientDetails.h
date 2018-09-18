//
//  smartRxPatientDetails.h
//  smartRxDoctor
//
//  Created by Manju Basha on 09/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxPatientDetails : UIViewController<UIScrollViewDelegate>
@property(nonatomic, strong) NSMutableDictionary *userDetailsDict;
@property (weak, nonatomic) IBOutlet UIImageView *userDp;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMobile;
@property (weak, nonatomic) IBOutlet UIButton *callUser;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)qaClicked:(id)sender;
- (IBAction)assignBtnClicked:(id)sender;
- (IBAction)carePlanAssignedBtnClicked:(id)sender;
- (IBAction)callBtnClicked:(id)sender;

@end

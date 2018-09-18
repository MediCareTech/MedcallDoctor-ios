//
//  smartRxLoginVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxLoginVC : UIViewController<MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtMobile;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) UITextField *currentTextField;
- (IBAction)signInBtnClicked:(id)sender;
- (IBAction)registerClicked:(id)sender;
- (IBAction)forgotPwdClicked:(id)sender;

@end

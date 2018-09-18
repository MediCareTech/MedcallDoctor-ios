//
//  smartRxRegisterVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxRegisterVC : UIViewController<UITextFieldDelegate,UIAlertViewDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtCode;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *currentBtn;
- (IBAction)validateBtnClicked:(id)sender;
@end

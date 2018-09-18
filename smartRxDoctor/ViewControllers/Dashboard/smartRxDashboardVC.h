//
//  smartRxDashboardVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 05/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxDashboardVC : UIViewController<MBProgressHUDDelegate, loginDelegate, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *futureBookingsLbl;
@property (weak, nonatomic) IBOutlet UIImageView *doctorImg;
@property (weak, nonatomic) IBOutlet UILabel *doctorName;
@property (weak, nonatomic) IBOutlet UILabel *doctorDesignation;
@property (weak, nonatomic) IBOutlet UITableView *doctorDashMenu;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;
@property (weak, nonatomic) IBOutlet UIView *viwMenu;
@property (weak, nonatomic) IBOutlet UIView *viewReset;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *retypePassword;
@property (weak, nonatomic) IBOutlet UIButton *resetPwdButton;
@property (assign, nonatomic) NSString *strTitle;
@property (weak, nonatomic) IBOutlet UIView *noApsView;

@property (strong, nonatomic) NSArray *arrMenu;

- (IBAction)docProfileClicked:(id)sender;
- (IBAction)hideMenuBtnClicked:(id)sender;
- (IBAction)resetPwdClicked:(id)sender;
- (IBAction)resetPwdCancelClicked:(id)sender;

@end

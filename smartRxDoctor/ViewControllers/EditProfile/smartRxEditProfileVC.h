//
//  smartRxEditProfileVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 05/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxEditProfileVC : UIViewController<MBProgressHUDDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,loginDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *doctorImg;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *detailsViewContainer;
@property (weak, nonatomic) IBOutlet UITextField *docName;
@property (weak, nonatomic) IBOutlet UITextView *docEducation;
@property (weak, nonatomic) IBOutlet UILabel *docEducationPlaceHolder;
@property (weak, nonatomic) IBOutlet UITextField *docExp;
@property (weak, nonatomic) IBOutlet UITextView *docDesignation;
@property (weak, nonatomic) IBOutlet UILabel *docDesignationPlaceHolder;
@property (weak, nonatomic) IBOutlet UITextView *docExpertise;
@property (weak, nonatomic) IBOutlet UILabel *docExpertisePlaceHolder;
@property (weak, nonatomic) IBOutlet UITextView *docDepartment;
@property (weak, nonatomic) IBOutlet UILabel *docDepartmentPlaceHolder;
@property (weak, nonatomic) IBOutlet UITextView *docRecNo;
@property (weak, nonatomic) IBOutlet UILabel *docRecNoPlaceHolder;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
- (IBAction)updateBtnClicked:(id)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)imgaePickerBtnClicked:(id)sender;
@end

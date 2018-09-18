//
//  smartRxAssignNewCarePlan.h
//  smartRxDoctor
//
//  Created by Manju Basha on 11/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxAssignNewCarePlan : UIViewController<UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, MBProgressHUDDelegate, loginDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *serviceTypeView;
@property (weak, nonatomic) IBOutlet UIView *otherTxtContainer;
@property (weak, nonatomic) IBOutlet UIView *multiSelectTableContainer;
@property (weak, nonatomic) IBOutlet UITextField *txtServiceType;
@property (weak, nonatomic) IBOutlet UITextField *txtConsultPack;
@property (weak, nonatomic) IBOutlet UITextField *txtSpec;
@property (weak, nonatomic) IBOutlet UITextField *txtCarePlan;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (retain, nonatomic) UIPickerView *serviceTypePicker;
@property (retain, nonatomic) UIPickerView *consultPackPicker;
@property (retain, nonatomic) UIPickerView *specPicker;
@property (retain, nonatomic) UIPickerView *carePlanPicker;
@property (retain, nonatomic) UIDatePicker *datePicker;
@property (retain, nonatomic) UIButton *currentButton;
@property (weak, nonatomic) IBOutlet UIButton *serviceTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *consultPackBtn;
@property (weak, nonatomic) IBOutlet UIButton *specBtn;
@property (weak, nonatomic) IBOutlet UIButton *carePlanBtn;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UITableView *carePlanTable;
@property (weak, nonatomic) IBOutlet UIButton *doneTableBtn;
@property (strong, nonatomic) UIView *actionSheet;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (strong, nonatomic) NSString *patientID;
@property (retain, nonatomic) NSString *patName;
@property (assign, nonatomic) NSString *strTitle;
- (IBAction)serviceTypeBtnClicked:(id)sender;
- (IBAction)consultPackBtnClicked:(id)sender;
- (IBAction)specBtnClicked:(id)sender;
- (IBAction)carePlanBtnClicked:(id)sender;
- (IBAction)dateBtnClicked:(id)sender;
- (IBAction)assignBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)doneTableBtnClicked:(id)sender;
@end

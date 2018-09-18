//
//  SmartRxeConsultModify.h
//  smartRxDoctor
//
//  Created by Manju Basha on 01/09/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCalendarView.h"
@interface SmartRxeConsultModify : UIViewController <CKCalendarDelegate, MBProgressHUDDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSString *scheduleType;

@property (weak, nonatomic)IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic)IBOutlet UIView *calendarContainer;
@property(nonatomic, retain) NSMutableArray *econsultDetails;
@property (assign, nonatomic) NSString *strTitle;
@property (weak, nonatomic) IBOutlet UITableView *tbleConsults;
@property (nonatomic, weak)IBOutlet CKCalendarView *calendar;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) IBOutlet UILabel *reasonPlaceHolder;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, strong) NSArray *disabledDates;
@property(nonatomic, strong) NSMutableArray *selectedDates;
@property(nonatomic, strong) NSMutableArray *appointmentDetails;
@property (strong, nonatomic) UIView *actionSheet;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (strong, nonatomic) NSMutableDictionary *dictResponse;

@property (retain, nonatomic) UIPickerView *timePicker;
@property (retain, nonatomic) UIPickerView *eConsultMethodPicker;
@property (retain, nonatomic) UIPickerView *eConsultStatusPicker;
@property (weak, nonatomic) IBOutlet UITextView *reasonTxtView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *eConsultMethodBtn;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) UIButton *currentButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *eConsultMethodLbl;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;

- (IBAction)dateButtonClicked:(id)sender;
- (IBAction)timeButtonClicked:(id)sender;
- (IBAction)eConsultMethodBtnClicked:(id)sender;
- (IBAction)statusBtnClicked:(id)sender;
- (IBAction)updateBtnClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;

@end



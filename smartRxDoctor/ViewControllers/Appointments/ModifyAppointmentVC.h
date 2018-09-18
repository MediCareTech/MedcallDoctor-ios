//
//  ModifyAppointmentVC.h
//  smartRxDoctor
//
//  Created by Gowtham on 05/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCalendarView.h"
#import "LocationsModel.h"

@interface ModifyAppointmentVC : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,UIPickerViewDataSource,UIPickerViewDelegate,CKCalendarDelegate>
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) LocationsModel *selectedLocation;
@property (strong, nonatomic) NSString *scheduleType;

@property (strong, nonatomic) NSMutableDictionary *dictResponse;
@property(nonatomic,weak) IBOutlet UILabel *locationeBtn;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIView *locationView;
@property(nonatomic,weak) IBOutlet UITextField *locationTF;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic)IBOutlet UIView *calendarContainer;
@property (weak, nonatomic)IBOutlet UIView *reasonView;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet UITextView *reasonTxtView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property(nonatomic, strong) IBOutlet UILabel *reasonPlaceHolder;
@property(nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, weak)IBOutlet CKCalendarView *calendar;
@property (weak, nonatomic) UIButton *currentButton;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, strong) NSArray *disabledDates;
@property(nonatomic, strong) NSMutableArray *selectedDates;
@property (strong, nonatomic) UIView *actionSheet;
@property (retain, nonatomic) UIPickerView *timePicker;
@property (retain, nonatomic) UIPickerView *eConsultStatusPicker;
@property(nonatomic, retain) NSMutableArray *econsultDetails;
@property(nonatomic, strong) NSMutableArray *appointmentDetails;

@end

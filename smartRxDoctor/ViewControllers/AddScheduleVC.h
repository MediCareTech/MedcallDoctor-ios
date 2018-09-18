//
//  AddScheduleVC.h
//  smartRxDoctor
//
//  Created by Gowtham on 10/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationsModel.h"
#import "CKCalendarView.h"

@interface AddScheduleVC : UIViewController<CKCalendarDelegate,MBProgressHUDDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, weak)IBOutlet CKCalendarView *calendar;
@property (weak, nonatomic)IBOutlet UIView *calendarContainer;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic,weak) IBOutlet UILabel *practiceLbl;
@property(nonatomic,weak) IBOutlet UILabel *dateLbl;
@property(nonatomic,weak) IBOutlet UILabel *morningTimings;
@property(nonatomic,weak) IBOutlet UILabel *afternoonTimings;
@property(nonatomic,weak) IBOutlet UIImageView *availableImageVw;
@property(nonatomic,weak) IBOutlet UIImageView *notAvailableImageVw;
@property(nonatomic,weak) IBOutlet UIView *detailSubView;
@property(nonatomic,weak) IBOutlet UIView *scheduleUpdateView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic,weak) IBOutlet UIView *addPracticeView;

@property(nonatomic, strong) NSMutableArray *selectedDates;
@property(nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSArray *disabledDates;
@property (strong, nonatomic) UIView *actionSheet;
@property (retain, nonatomic) UIPickerView *locationPicker;


@end

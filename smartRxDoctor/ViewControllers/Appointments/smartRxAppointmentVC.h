//
//  smartRxAppointmentVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCalendarView.h"
@interface smartRxAppointmentVC : UIViewController <CKCalendarDelegate, MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic)IBOutlet UIView *calendarContainer;
@property (nonatomic, weak)IBOutlet CKCalendarView *calendar;
@property (nonatomic, weak)IBOutlet UILabel *noAptLbl;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, strong) NSArray *disabledDates;
@property(nonatomic, strong) NSMutableArray *selectedDates;
@property(nonatomic, strong) NSMutableArray *appointmentDetails;

@end

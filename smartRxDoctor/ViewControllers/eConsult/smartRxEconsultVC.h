//
//  smartRxEconsultVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCalendarView.h"
@interface smartRxEconsultVC : UIViewController <CKCalendarDelegate, MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic)IBOutlet UIView *calendarContainer;
@property (weak, nonatomic)IBOutlet UILabel *eConsultEmptyLbl;
@property(nonatomic, retain) NSMutableArray *econsultDetails;
@property (weak, nonatomic) IBOutlet UITableView *tbleConsults;
@property (nonatomic, weak)IBOutlet CKCalendarView *calendar;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, strong) NSArray *disabledDates;
@property(nonatomic, strong) NSMutableArray *selectedDates;
@property(nonatomic, strong) NSMutableArray *appointmentDetails;
@end

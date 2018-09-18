//
//  SendAlertVc.h
//  smartRxDoctor
//
//  Created by Gowtham on 17/01/18.
//  Copyright © 2018 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendAlertVc : UIViewController<MBProgressHUDDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property(nonatomic,weak) IBOutlet UILabel *alertTypeLbl;
@property(nonatomic,weak) IBOutlet UITextView *alertMsgTV;
@property(nonatomic,weak) IBOutlet UILabel *doctorNameLbl;

@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (strong, nonatomic) UIView *actionSheet;
@property (retain, nonatomic) UIPickerView *alertTypePicker;

@end

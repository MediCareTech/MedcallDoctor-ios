//
//  ChatHistoryResponseModel.h
//  SmartRx
//
//  Created by SmartRx-iOS on 22/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatHistoryResponseModel : NSObject
@property(nonatomic,strong) NSString *patientName;
@property(nonatomic,strong) NSString *patientId;
@property(nonatomic,strong) NSString *patientProfilePic;
@property(nonatomic,strong) NSString *roomId;
@property(nonatomic,strong) NSString *lastMessageTime;
@property(nonatomic,strong) NSString *status;

@end

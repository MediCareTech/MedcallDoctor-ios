//
//  SmartRxCommonClass.h
//  SmartRx
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "appConstants.h"
@protocol loginDelegate <NSObject>

-(void)sectionIdGenerated:(id)sender;
-(void)errorSectionId:(id)sender;
-(void)logOutId:(id)sender;
@end

@protocol ImageSelected <NSObject>

-(void)imageSelected:(UIImage *)image;

@end


@interface SmartRxCommonClass : NSObject<UIImagePickerControllerDelegate, UIAlertViewDelegate>


#define kBundleID "in.smartrx.doctor"

@property (strong,nonatomic) id loginDelegate;
@property (assign, nonatomic) id < ImageSelected > imageDelegate;
-(void)openGallary:(UIViewController *)controller;
+ (id)sharedManager;
-(void)postOrGetData:(NSString *)UrlString postPar:(id )postParaDict method:(NSString *)methodType setHeader:(BOOL)header  successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler;

-(void)postingImageWithText:(NSString *)urlString postData:(id)postParaDict camImg:(UIImage *)img successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler;


-(void)makeLoginRequest;

-(void)setNavigationTitle:(NSString *)title controler:(UIViewController *)controller;
@end

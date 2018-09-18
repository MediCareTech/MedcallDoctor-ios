//
//  appConstants.h
//  smartRxDoctor
//
//  Created by Manju Basha on 04/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#ifndef smartRxDoctor_appConstants_h
#define smartRxDoctor_appConstants_h

#define BASE_WB_URL_PRODUCTION  @"https://health.medcall.in/api/"
#define BASE_WB_URL_TESTING     @"https://dev.medcall.in/api/"
//#define ENABLE_LIVE_SERVER      @"1"
#ifdef ENABLE_LIVE_SERVER
#define WB_BASEURL              BASE_WB_URL_PRODUCTION
#define IMAGE_URL_TEST  @"https://health.medcall.in/admin/"
#define IMAGE_URL       @"https://health.medcall.in/"
#define CHAT_URL        @"https://chat.medcall.in:8100"
#define NO_IMAGE        @"https://health.medcall.in/images/noimage.png"

#else
#define WB_BASEURL              BASE_WB_URL_TESTING
#define IMAGE_URL_TEST  @"https://dev.medcall.in/admin/"
#define IMAGE_URL       @"https://dev.medcall.in/"
#define CHAT_URL        @"https://chat.medcall.in:8100"
#define NO_IMAGE        @"https://dev.medcall.in/images/noimage.png"
#endif


#endif

//
//  config.h
//  EVCompany
//
//  Created by GridScape on 10/29/15.
//  Copyright (c) 2015 Srishti. All rights reserved.
//

#ifndef EVCompany_config_h
#define EVCompany_config_h

//--------------------------------------------------------------------------------------------------
//For UserDefaults
//--------------------------------------------------------------------------------------------------
#define kCOMPLETE_REGISTRATION @"COMPLETE_REGISTRATION"

#define kEMAIL @"EMAIL"

#define kPASSWORD @"PASSWORD"

#define kREMEMBER_ME @"REMEMBER_ME"

#define kUSER_ROLE @"USER_ROLE"

#define kNAV_TITLE @"RCS"
//#define kNAV_TITLE @"Testing"


//--------------------------------------------------------------------------------------------------
// For Background Colour
//--------------------------------------------------------------------------------------------------
#define kBackgroundQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

#define kMainQueue dispatch_get_main_queue()


//--------------------------------------------------------------------------------------------------
// Services
//--------------------------------------------------------------------------------------------------
#define kURLDemo [NSString stringWithFormat:@"https://ocpp.grid-scape.com/"]
//#define kURLDemo [NSString stringWithFormat:@"http://demo.grid-scape.com/"]
//#define kURLDemo [NSString stringWithFormat:@"http://10.2.29.164:8080/ocppserver/"]

//#define kCutomerId @"1" //Gridscape
//#define kCutomerId @"13" //RCS DEMO
#define kCutomerId @"8" //production rcs
//#define kCutomerId @"12" //production Gridscape fleet

#endif

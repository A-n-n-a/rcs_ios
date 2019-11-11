//
//  EVUser.m
//  EVCompany
//
//  Created by Srishti on 25/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import "EVUser.h"
#import "NSMutableData+PostDataAdditions.h"
#import "EVWebService.h"
static EVUser *currentUser;

@implementation EVUser
-(id)initWithUserDetails:(NSDictionary *)userDetails{
    self = [super init];
    
    if (self) {
        
        [self setValueInObject:userDetails];
        
    }
    return self;
}
-(void)setValueInObject:(NSDictionary *)dictionary
{
    self.userId = dictionary[@"userId"];
    self.firstname = dictionary[@"first_name"];
    self.lastName = dictionary[@"email"];
    self.email = dictionary[@"email"];
    self.lastName = dictionary[@"last_name"];
    self.imageName = dictionary[@"image"];
    self.phoneNumber = dictionary[@"phone_number"];
    self.memberSincedate = dictionary[@"date"];
    self.aboutMe = dictionary[@"aboutme"];
    self.carModel = dictionary[@"car_model"];
    self.carType = dictionary[@"type"];
    self.carYear = dictionary[@"year"];
    self.milesWhenFull = dictionary[@"MilesWhenFull"];
    self.tagId = dictionary[@"tagId"];
/*
    self.NotifTime = @"10";
    self.NotifDist = @"10";
    self.NearByDist = @"10";
    self.tagId = @"";
 */   
}
+(EVUser*)currentUser{
    @synchronized([EVUser class]) {
        
        static dispatch_once_t once;
        static EVUser *currentUser;
        dispatch_once(&once, ^{
            currentUser = [[self alloc] init];
            
            NSDictionary *user = [[NSUserDefaults standardUserDefaults]objectForKey:@"LogInUserKey"];
            if (user)
                [currentUser setValueInObject:user];
        });
        return currentUser;
        
    }
    return nil;
}

+(EVUser*)userWithDetails:(NSDictionary *) userDetails{
    @synchronized([EVUser class]) {
        [[NSUserDefaults standardUserDefaults] setObject:userDetails forKey:@"LogInUserKey"];
        [[NSUserDefaults standardUserDefaults]synchronize];

        [[self currentUser]setValueInObject:userDetails];;
        return currentUser;
        
    }
    return nil;
}

//+(void)loginWithEmail:(NSString *)email password:(NSString *)password withCompletionBlock:(void (^)(BOOL, EVUser *, NSError*))completionBlock{
+(void)loginWithEmail:(NSString *)email password:(NSString *)password withCompletionBlock:(void (^)(BOOL, id, NSError*))completionBlock{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:email forKey:@"email"];
    [body addValue:password forKey:@"Password"];
    
    [EVWebService fetchDataFromService:@"login.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
 /* a       success ? [result[@"result"] isEqualToString:@"Success"] ? completionBlock(YES,[self userWithDetails:result[@"User_details"]],nil) : completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Error"]}]) : completionBlock(NO,nil,error);
 a */
         if (success) {
             if ([result[@"result"] isEqualToString:@"Success"]) {
                 
             //    completionBlock(YES,[self userWithDetails:result[@"User_details"]],nil);
                 completionBlock(YES,result,nil);
                 NSLog(@"login responce result : %@",result);
                 
             }
             else{
                 completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Error"]}]);
             }
         }
         else{
             
             completionBlock(NO,nil,error);
             
         }
         
     }];
    
}
-(void)signUpwithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock{
    [EVWebService fetchDataFromService:@"signup.php" withParameters:[self getPropertiesAsData] withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if (success) {
             if ([result[@"result"] isEqualToString:@"Success"]) {
                 
                 //[self setValueInObject:result[@"User_details"]];
         //a        currentUser = [EVUser userWithDetails:result[@"User_details"]];
         //a        completionBlock(YES,@"",nil);
                 completionBlock(YES,result,nil);
                 
             }
             else{
                 if([result[@"Error"] isEqualToString:@"Username Exisit"])
                   completionBlock(NO,@"User Exist",result[@"Error"]);
                 currentUser = nil;
             }
         }
         else{
             
             completionBlock(NO,@"",error);
             currentUser = nil;
             
         }
     }];
    
}
-(void)editProfilewithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.firstname forKey:@"first_name"];
    [body addValue:self.lastName forKey:@"last_name"];
    [body addValue:self.aboutMe forKey:@"aboutme"];
    [body addValue:self.phoneNumber forKey:@"phone_number"];
    [body addValue:self.email forKey:@"Email"];
    [body addValue:self.userId forKey:@"userId"];
    self.imageName = [self makeFileName];
    [body addValue:UIImageJPEGRepresentation(_profilePic, 0.7f) forKey:@"image" withFileName:_imageName];
   
    [EVWebService fetchDataFromService:@"edit_profile.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if (success) {
             if ([result[@"result"] isEqualToString:@"success"]) {
            //a     NSLog(@"edit profile user setting = %@",result);
            //a     currentUser = [EVUser userWithDetails:result[@"User_details"]];
            //a     completionBlock(YES,result[@"warning"],nil);
                 completionBlock(YES,result,nil);
             }
             else{
                 
                 completionBlock(NO,nil,result[@"Error"]);
                 currentUser = nil;
                 
             }
         }
         else{
             
             completionBlock(NO,nil,error);
             currentUser = nil;
             
         }

     }];

}
-(void)fetchProfilewithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.userId forKey:@"userId"];
    self.imageName = [self makeFileName];
    [body addValue:UIImageJPEGRepresentation(_profilePic, 0.7f) forKey:@"image" withFileName:_imageName];
    
    [EVWebService fetchDataFromService:@"profile.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if (success) {
           //a      currentUser = [EVUser userWithDetails:result[@"User_details"]];
           //a      completionBlock(YES,nil,nil);
             completionBlock(YES,result,nil);
            }
         else{
             
             completionBlock(NO,nil,error);
             currentUser = nil;
             
         }
         
     }];
    
}

-(void)changePassworwithCompletionBlock:(void (^)(BOOL, id ,NSError*))completionBlock{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.email forKey:@"mail"];
    [EVWebService fetchDataFromService:@"change_password.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if (success) {
             if ([result[@"result"] isEqualToString:@"Success"]) {
             completionBlock(YES,result[@"output"],error);
             }else{
               completionBlock(NO,result[@"Error"],error);
             }
         }else{
            completionBlock(NO,nil,error);
         }
     }];

}
-(void)forgotPasswordwithCompletionBlock:(void (^)(BOOL, id ,NSError*))completionBlock{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.email forKey:@"mail"];
    [EVWebService fetchDataFromService:@"forgotpassword.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if (success) {
             if ([result[@"result"] isEqualToString:@"Success"]) {
                 completionBlock(YES,result[@"output"],error);
             }else{
                 completionBlock(NO,result[@"Error"],error);
             }
         }else{
             completionBlock(NO,nil,error);
         }
     }];
    
}

-(void)changeCarDetailsWithCompletionBlock:(void (^)(BOOL,id ,NSError*))completionBlock{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.userId forKey:@"userId"];
    [body addValue:self.carModel forKey:@"car_model"];
    [body addValue:self.carType forKey:@"type"];
    [body addValue:self.carYear forKey:@"year"];
    [body addValue:self.milesWhenFull forKey:@"MilesWhenFull"];
    NSLog(@"Change car details request parameters : %@",self.milesWhenFull);

    [EVWebService fetchDataFromService:@"user_more_det_new.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if (success) {
             if ([result[@"result"] isEqualToString:@"success"]) {
                 completionBlock(YES,result,error);
                 NSLog(@"Change car details responce result : %@",result);
              //a   currentUser = [EVUser userWithDetails:result[@"user_det"]];
             }else{
                 completionBlock(NO,result[@"Error"],error);
             }
         }else{
             completionBlock(NO,nil,error);
         }
     }];

}
-(NSData *)getPropertiesAsData{
    NSMutableData *body = [NSMutableData postData];
    _imageName = [self makeFileName];
//    [body addValue:UIImageJPEGRepresentation(self.profilePic, 0.7f) forKey:@"image" withFileName:_imageName];
    [body addValue:self.firstname  forKey:@"first_name"];
    [body addValue:self.lastName forKey:@"last_name"];
    [body addValue:self.password  forKey:@"password"];
    [body addValue:self.email  forKey:@"Email"];
    
    return body;
}

-(NSString *)makeFileName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMddHHmmssSSS"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    int randomValue = arc4random() % 1000;
    
    NSString *fileName = [NSString stringWithFormat:@"%@%d.jpg",dateString,randomValue];
    
    return fileName;
}




/*----------------- OCPP METHODS ----------------*/

@end

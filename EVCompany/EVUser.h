//
//  EVUser.h
//  EVCompany
//
//  Created by Srishti on 25/03/14.
//  Copyright (c) 2014 Srishti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVUser : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *memberSincedate;
@property (nonatomic, strong) NSString *aboutMe;
@property (nonatomic, strong) UIImage *profilePic;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *carModel;
@property (nonatomic, strong) NSString *carType;
@property (nonatomic, strong) NSString *carYear;
@property (nonatomic, strong) NSString *milesWhenFull;
@property (nonatomic, strong) NSString *NotifTime;
@property (nonatomic, strong) NSString *NotifDist;
@property (nonatomic, strong) NSString *NearByDist;
@property (nonatomic, strong) NSString *tagId;

+ (EVUser *)currentUser;
+(EVUser*)userWithDetails:(NSDictionary *) userDetails;
-(void)signUpwithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;
//+(void)loginWithEmail:(NSString *)email password:(NSString *)password withCompletionBlock:(void (^)(BOOL, EVUser *, NSError*))completionBlock;
+(void)loginWithEmail:(NSString *)email password:(NSString *)password withCompletionBlock:(void (^)(BOOL, id, NSError*))completionBlock;
-(void)editProfilewithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;
-(void)changePassworwithCompletionBlock:(void (^)(BOOL, id ,NSError*))completionBlock;
-(void)changeCarDetailsWithCompletionBlock:(void (^)(BOOL,id ,NSError*))completionBlock;
-(void)fetchProfilewithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;
-(void)forgotPasswordwithCompletionBlock:(void (^)(BOOL, id ,NSError*))completionBlock;
@end

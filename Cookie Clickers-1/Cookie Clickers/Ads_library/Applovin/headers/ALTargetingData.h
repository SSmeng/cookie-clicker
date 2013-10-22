//
//  ALTargetingData.h
//  sdk
//
//  Created by Basil on 9/18/12.
//
//

#import <Foundation/Foundation.h>

@interface ALTargetingData : NSObject

#define kALGenderMale        'm'
#define kALGenderFemale      'f'

#define kALEducationNone              @"none";
#define kALEducationHighSchool        @"high_school";
#define kALEducationCollege           @"college";
#define kALEducationInCollege         @"in_college";
#define kALEducationBachelors         @"bachelors";
#define kALEducationMasters           @"masters";
#define kALEducationDoctoral          @"doctoral";
#define kALEducationOther             @"other";

#define kALEthnicityNone             @"none";
#define kALEthnicityMixed            @"mixed";
#define kALEthnicityAsian            @"asian";
#define kALEthnicityBlack            @"black";
#define kALEthnicityHispanic         @"hispanic";
#define kALEthnicityNativeAmerican   @"native_american";
#define kALEthnicityWhite            @"white";
#define kALEthnicityOther            @"other";

#define kALMaritalStatusNone        @"none";
#define kALMaritalStatusSingle      @"single";
#define kALMaritalStatusMarried     @"married";
#define kALMaritalStatusDivorced    @"divorced";
#define kALMaritalStatusWidowed     @"widowed";


/**
 * Set carrier current device is on.
 */
@property(strong, nonatomic) NSString * carrier;

/**
 * Set a two-character ISO 3166-1 country code of the device.
 */
@property(strong, nonatomic) NSString * country;
/**
 * API Depricated
 */
@property(strong, nonatomic) NSString * phoneNumber;

/**
 * API Depricated
 */
@property(strong, nonatomic) NSString * email;

/**
 * API Depricated
 */
@property(strong, nonatomic) NSArray * emails;

/**
 * API Depricated
 */
@property(strong, nonatomic) NSString * hashedPhoneNumber;

/**
 * API Depricated
 */
@property(strong, nonatomic) NSString * hashedEmail;

/**
 * API Depricated
 */
@property(strong, nonatomic) NSArray * hashedEmails;

/**
 * API Depricated
 */
@property(strong, nonatomic) NSString * firstName;

/**
 * Set the year of birth of current user.
 */
@property(assign, nonatomic) UInt16 birthYear;

/**
 * Gender of the  current user. 
 * <p>
 * Following constants contain supported values: <code>kALGenderMale</code> and
 * <code>kALGenderFemale</code>.
 */
@property(assign, nonatomic) char gender;

/**
 * The language of the current user. Language is expressed as two-character
 * ISO 639-1 language code.
 */
@property(strong, nonatomic) NSString * language;

/**
 * Income of the current user. Income format is could be as follows:
 * <ul>
 *      <li> An exact number like 100000 or 100K
 *      <li> A range like 10K-30K
 *      <li> A range like <100K
 * </ul>
 */
@property(strong, nonatomic) NSString * income;

/**
 * Highest level of education of the current user. 
 * <p>
 * Following constants contain supported values: <code>kALEducationNone, 
 * kALEducationHighSchool, kALEducationCollege, kALEducationInCollege, kALEducationBachelors,
 * kALEducationMasters, kALEducationDoctoral</code> and <code>kALEducationOther</code>.
 */
@property(strong, nonatomic) NSString * education;

/**
 * Highest level of education of the current user. 
 * <p>
 * Following constants contain supported values: kALEthnicityNone, kALEthnicityMixed,
 * kALEthnicityAsian, kALEthnicityBlack, kALEthnicityHispanic, kALEthnicityNativeAmerican, 
 * kALEthnicityWhite</code> and <code>kALEthnicityOther</code>.
 */
@property(strong, nonatomic) NSString * ethnicity;


/**
 * Martical status of the current user. 
 * <p>
 * Following constants contain supported values: <code>kALMaritalStatusNone,
 * kALMaritalStatusSingle, kALMaritalStatusMarried, kALMaritalStatusDivorced</code>
 * and <code>kALMaritalStatusWidowed</code>.
 */
@property(strong, nonatomic) NSString * maritalStatus;


/**
 * Keywords for the application.
 */
@property(strong, nonatomic) NSArray * keywords;

/**
 * Interests for the user.
 */
@property(strong, nonatomic) NSArray * interests;

/**
 * Set the location of current user. The location represented as
 * longiture and latitude
 */
-(void) setLocationWithLatitude: (double) latitude longitude: (double)longitude;

/**
 * Put an extra targeting parameter
 *
 * @param key Key of the parameter. Must not be null.
 * @param value Parameter value.
 */
-(void) setExtraValue: (NSString *) value forKey: (NSString *)key;

/**
 * Clear all saved targeting data
 */
-(void) clearAll;

@end

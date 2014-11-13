//
//  SignUpViewController.h
//  AirCash
//
//  Created by Younes Nouri Soltan on 26/12/2012.
//
//

#import "SuperViewController.h"
//#import "KKPasscodeViewController.h"
//#import "KeychainItemWrapper.h"
#import "User.h"

@class User;

@interface SignUpViewController : SuperViewController <UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDelegate>

@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property(strong, nonatomic) IBOutlet UIView *firstView;
@property(strong, nonatomic) IBOutlet UIView *secondView;
@property(strong, nonatomic) IBOutlet UIView *thirdView;
@property(strong, nonatomic) IBOutlet UIView *fourthView;

@property(strong, nonatomic) IBOutlet UIView *verifyView;


@property(strong, nonatomic)IBOutlet UITextField *emailTextField;
@property(strong, nonatomic)IBOutlet UITextField *mobileNoTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordConfirmTextField;


@property(strong, nonatomic)IBOutlet UITextField *fullNameTextField;
@property(strong, nonatomic)IBOutlet UITextField *DOBTextField;


@property(strong, nonatomic)IBOutlet UITextField *houseNoTextField;
@property(strong, nonatomic)IBOutlet UITextField *flatNoTextField;
@property(strong, nonatomic)IBOutlet UITextField *postCodeTextField;

@property(strong, nonatomic)IBOutlet UILabel *emailLabel;
@property(strong, nonatomic)IBOutlet UILabel *mobileLabel;

@property(strong, nonatomic)IBOutlet UITextField *codeEmailTextField;
@property(strong, nonatomic)IBOutlet UITextField *codeMobileTextField;


@property(strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property(strong, nonatomic) User *userDetails;

-(IBAction)Next:(id)sender;

-(IBAction)NextSecond:(id)sender;
-(IBAction)PreviousSecond:(id)sender;

-(IBAction)NextThird:(id)sender;
-(IBAction)PreviousThird:(id)sender;

-(IBAction)Done:(id)sender;
-(IBAction)PreviousFourth:(id)sender;

-(IBAction)Verify:(id)sender;
-(IBAction)PreviousFifth:(id)sender;

@end

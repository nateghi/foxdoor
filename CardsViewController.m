//
//  AddCardViewController.m
//  AirCash
//
//  Created by Spargonet on 29/10/2013.
//  Copyright (c) 2013 Younes Nouri Soltan. All rights reserved.
//

#import "CardsViewController.h"
#import "KeychainItemWrapper.h"
#import "NSData+Base64.h"
//#import "RadioButton.h"
//#import "SGSelectViewController.h"
#import "AppDelegate.h"


@interface CardsViewController ()

@property(strong, nonatomic) UITextField *cardNumberTextField1;
@property(strong, nonatomic) UITextField *cardNumberTextField2;
@property(strong, nonatomic) UITextField *cardNumberTextField3;
@property(strong, nonatomic) UITextField *cardNumberTextField4;

@property(strong, nonatomic) UITextField *expiryDateTextField;
@property(strong, nonatomic) UITextField *CVNCodeTextField;

@property(strong, nonatomic) UITextField *cardHolderNameTextField;
@property(strong, nonatomic) UITextField *houseNumberTextField;
@property(strong, nonatomic) UITextField *postCodeTextField;

@property(strong, nonatomic) UIPickerView *monthPicker;


@property (weak, nonatomic) IBOutlet UILabel *buttonTappedLabel;


@end

@implementation CardsViewController

@synthesize monthPicker = _monthPicker;
@synthesize view1, view2, card, btnSelect;


KeychainItemWrapper *cardsWrapper;

NSMutableArray *arrayMonth;
NSMutableArray *arrayYear;
UIView *blurView;

- (IBAction)selectClicked:(id)sender {
    
    [self.cardNumberTextField1 resignFirstResponder];
    [self.cardNumberTextField2 resignFirstResponder];
    [self.cardNumberTextField3 resignFirstResponder];
    [self.cardNumberTextField4 resignFirstResponder];
    
    
    [self.expiryDateTextField resignFirstResponder];
    [self.CVNCodeTextField resignFirstResponder];
    
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"Visa Card", @"Master Card", @"American Express",nil];
    NSArray * arrImage = [[NSArray alloc] init];
    arrImage = [NSArray arrayWithObjects:[UIImage imageNamed:@"VisaCard.jpeg"], [UIImage imageNamed:@"MasterCard33.png"], [UIImage imageNamed:@"American-Express4.png"], nil];
    if(dropDown == nil) {
        CGFloat f = 200;
        dropDown = [[NIDropDown alloc] showDropDown:sender buttonHeight:&f textArr:arr imageArr:arrImage point:@"down"];
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        [self rel];
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    [self rel];
    
    NIDropDown *button = (NIDropDown*)sender;
    
    int index = button.tag;
    self.card.cardType = @"";
    
	
    switch (index) {
            
        case 0:
        {
            
            self.card.cardType = @"VISA";
        }
            break;
        case 1:
        {
            self.card.cardType = @"MC";
        }
            break;
            
        case 2:
        {
            self.card.cardType = @"AX";
        }
            break;
            
        case 4:
        {
            self.card.cardType = @"JCB";
            
        }
            break;
            
        default:
            break;
    }
    
}

-(void)rel{
    //    [dropDown release];
    dropDown = nil;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	//    [self btn];
    
    
    AppDelegate *appDelegate;
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.selectBtn = self.selectBtn;
    
    btnSelect.layer.borderWidth = 1;
    btnSelect.layer.borderColor = [[UIColor blackColor] CGColor];
    btnSelect.layer.cornerRadius = 5;
	
    
}



-(void)viewDidAppear:(BOOL)animated{
    
    cardsWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"cardsTest" accessGroup:nil];
    //[cardsWrapper resetKeychainItem];
    NSString *decodedString = [cardsWrapper objectForKey:(__bridge id)(kSecValueData)];
    NSData *decodedData;
    
    decodedData= [NSData dataWithBase64EncodedString:decodedString];
    self.cards = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    if (!self.cards) {
        self.cards = [[NSMutableArray alloc]init];
    }
}


-(IBAction)closeView:(id)sender{
    
    UIButton *button = sender;
    [button.superview removeFromSuperview];
    [blurView removeFromSuperview];
    self.view1 = nil;
    self.view2 = nil;
    
}

-(IBAction)nextPage:(id)sender{
    
    self.card.cardNumber = self.cardNumberTextField1.text;
    self.card.cardNumber = [self.card.cardNumber stringByAppendingString:self.cardNumberTextField2.text];
    self.card.cardNumber = [self.card.cardNumber stringByAppendingString:self.cardNumberTextField3.text];
    self.card.cardNumber = [self.card.cardNumber stringByAppendingString:self.cardNumberTextField4.text];
    
	//    self.card.exirpyDate = self.expiryDateTextField.text;
    if (self.card.exirpyDate.length == 9) {
        NSString *expirayRefine = [self.card.exirpyDate substringToIndex:2];
        expirayRefine = [expirayRefine stringByAppendingString:[self.card.exirpyDate substringFromIndex:7]];
		//        self.card.exirpyDate = expirayRefine;
    }
    
    
    self.card.cvc = self.CVNCodeTextField.text;
	
    if (self.card.cardNumber.length > 11 && self.card.cardType.length > 1 && self.card.exirpyDate.length == 4 && self.card.cvc.length >2) {
        
        self.view2.layer.cornerRadius = 4;
        self.view2.layer.borderWidth = 3;
        self.view2.layer.borderColor = [UIColor blackColor].CGColor;
        
        [UIView transitionFromView:self.view1 toView:self.view2 duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
        
        self.view2.hidden = NO;
        
    } else {
        
        NSString *message = @"";
        
        if (self.card.cardNumber.length <= 11) {
            message = @"The card number is not valid";
        } else if (self.card.cardType.length ==0){
            message = @"Card type must be chosen";
            
        } else if (self.card.exirpyDate.length < 4){
            
            message = @"The expiray date is not set";
        } else {
            
            message = @"Security number is not valid";
        }
        
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Empty Field"
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [messageAlert show];
		//        self.cardNumberTextField1.backgroundColor = [UIColor redColor];
    }
    
}

-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    
    self.card.cardType = @"";
    
    
    switch (index) {
            
        case 0:
        {
            
            self.card.cardType = @"VISA";
            
        }
            break;
        case 1:
        {
            self.card.cardType = @"MC";
        }
            break;
            
        case 2:
        {
            self.card.cardType = @"AMEX";
            
        }
            break;
            
        case 3:
        {
            self.card.cardType = @"JCB";
            
        }
            break;
            
        default:
            break;
    }
}

-(IBAction)Done:(id)sender{
    
    
    self.card.nameOnCard = self.cardHolderNameTextField.text;
//    self.card.CardRegisterationAddress = self.houseNumberTextField.text;
    self.card.issueNumber = self.postCodeTextField.text;
//	
//    if (![self.card.nameOnCard isEqualToString:@"" ] && ![self.card.CardRegisterationAddress isEqualToString:@""] && ![self.card.issueNumber isEqualToString:@""]) {
//		
//        
//        NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                           // Object
//										   card.cardNumber, @"cardNumber",
//										   card.expirationYear, @"expirationYear",
//										   card.expirationMonth, @"expirationMonth",
//										   card.nameOnCard, @"cardHolderName",
//										   card.cardType, @"cardType",
//										   card.cvc, @"CVNCode",
//										   card.HouseNumber, @"houseNumber",
//										   card.PostCode, @"postCode",
//										   card.StreetName, @"streetName",
//										   card.issueNumber, @"issueNumber",
//										   card.Token, @"Token",
//                                           nil];
//		
//        
//        [self.cards addObject:dictionary];
//        
//        NSString *encodedString= [[NSKeyedArchiver archivedDataWithRootObject:self.cards] base64EncodedString];
//        [cardsWrapper setObject:encodedString forKey:(__bridge id)(kSecValueData)];
//        
//        
//        //        [self.tableView reloadData];
//        
//        self.cardNumberTextField1.text = @"";
//        self.cardNumberTextField2.text = @"";
//        self.cardNumberTextField3.text = @"";
//        self.cardNumberTextField4.text = @"";
//        
//        self.expiryDateTextField.text = @"";
//        self.CVNCodeTextField.text = @"";
//        self.houseNumberTextField.text = @"";
//        self.postCodeTextField.text = @"";
//        
//        [UIView transitionFromView:self.view2 toView:nil duration:0.5 options:UIViewAnimationOptionTransitionCurlUp completion:nil];
//        
//        [self.view1 removeFromSuperview];
//        [self.view2 removeFromSuperview];
//        [blurView removeFromSuperview];
//        
//        self.view1 = nil;
//        self.view2 = nil;
//        
//    } else {
//        
//        NSString *message;
//        
//        if ([self.card.nameOnCard isEqualToString:@""]) {
//            
//            message = @"The card's holder name can not be empty";
//            
//        } else if ([self.card.CardRegisterationAddress isEqualToString:@""]){
//            
//            message = @"House number or name can not be empty";
//            
//        } else if ([self.card.issueNumber isEqualToString:@""]){
//            
//            message = @"Post Code can not be empty";
//        }
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty Field"
//														message:message
//													   delegate:nil
//											  cancelButtonTitle:@"OK"
//											  otherButtonTitles:nil];
//        [alert show];
//		
//        
//    }
}

-(IBAction)PreviousPage:(id)sender{
    
    [UIView transitionFromView:self.view2 toView:self.view1 duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    //[[self.view1 layer]addAnimation:animation forKey:@""];
    //self.view1.hidden = NO;
    
}



-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    BOOL returnBool;
    
    if (textField == self.expiryDateTextField) {
        self.monthPicker.hidden = NO;
        
        [self.cardNumberTextField1 resignFirstResponder];
        [self.cardNumberTextField2 resignFirstResponder];
        [self.cardNumberTextField3 resignFirstResponder];
        [self.cardNumberTextField4 resignFirstResponder];
        
        
        [self.expiryDateTextField resignFirstResponder];
        [self.CVNCodeTextField resignFirstResponder];
        
        returnBool = NO;
        
    } else{
		
        self.monthPicker.hidden = YES;
        returnBool = YES;
    }
    
    return returnBool;
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == self.cardNumberTextField1 || textField == self.cardNumberTextField2 ||textField == self.cardNumberTextField3 || textField == self.cardNumberTextField4) {
        
        [self autoJump:textField shouldChangeCharactersInRange:range replacementString:string];
        
    } else if(textField == self.cardHolderNameTextField ||textField == self.houseNumberTextField || textField == self.postCodeTextField || textField == self.CVNCodeTextField){
        
        return YES;
    }
	
    //always return no since we are manually changing the text field
    return NO;
}


-(void)autoJump:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    BOOL shouldProcess = NO; //default to reject
    BOOL shouldMoveToNextField = NO; //default to remaining on the current field
    
    int insertStringLength = [string length];
    if(insertStringLength == 0){ //backspace
        shouldProcess = YES; //Process if the backspace character was pressed
    }
    else {
        if([[textField text] length] < 4) {
            shouldProcess = YES; //Process if there is only 1 character right now
        }
    }
    
    //here we deal with the UITextField on our own
    if(shouldProcess){
        //grab a mutable copy of what's currently in the UITextField
        NSMutableString* mstring = [[textField text] mutableCopy];
        if([mstring length] == 3){
            //nothing in the field yet so append the replacement string
            [mstring appendString:string];
            
            shouldMoveToNextField = YES;
        }
        else{
            //adding a char or deleting?
            if(insertStringLength > 0){
                [mstring insertString:string atIndex:range.location];
            }
            else {
                //delete case - the length of replacement string is zero for a delete
                [mstring deleteCharactersInRange:range];
            }
        }
        
        //set the text now
        [textField setText:mstring];
        
        
        if (shouldMoveToNextField) {
            //
            //MOVE TO NEXT INPUT FIELD HERE
            //
            if (self.cardNumberTextField3.text.length == 4) {
                [self.cardNumberTextField4 becomeFirstResponder];
                
            } else if(self.cardNumberTextField2.text.length == 4){
                [self.cardNumberTextField3 becomeFirstResponder];
                
            } else if(self.cardNumberTextField1.text.length == 4){
                [self.cardNumberTextField2 becomeFirstResponder];
                
            }
        }
    }
}

- (void)insetCard{
    self.view1 = [[UIView alloc]initWithFrame:CGRectMake(10, 65, 300, 330)];
    self.view2 = [[UIView alloc]initWithFrame:CGRectMake(10, 65, 300, 330)];
    self.card = [[Card alloc]init];
    
    
    UILabel *cardNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 120, 30)];
    //    cardNumberLabel.tex
    cardNumberLabel.font = [UIFont fontWithName:@"Arial" size:13];
    cardNumberLabel.text =@"Card Number";
    
    _cardNumberTextField1 = [[UITextField alloc]initWithFrame:CGRectMake(10, 30, 45, 30)];
    _cardNumberTextField1.backgroundColor = [UIColor whiteColor];
    _cardNumberTextField1.borderStyle = UITextBorderStyleLine;
    _cardNumberTextField1.keyboardType = UIKeyboardTypeNumberPad;
    //    _cardNumberTextField1.background = [UIImage imageNamed:@"Text-Field-45.png"];
    _cardNumberTextField1.borderStyle = UITextBorderStyleLine;
    _cardNumberTextField1.delegate = self;
    
    _cardNumberTextField2 = [[UITextField alloc]initWithFrame:CGRectMake(60, 30, 45, 30)];
    _cardNumberTextField2.backgroundColor = [UIColor whiteColor];
    _cardNumberTextField2.borderStyle = UITextBorderStyleLine;
    _cardNumberTextField2.keyboardType = UIKeyboardTypeNumberPad;
    //    _cardNumberTextField2.background = [UIImage imageNamed:@"Text-Field-45.png"];
    _cardNumberTextField2.borderStyle = UITextBorderStyleLine;
    _cardNumberTextField2.delegate = self;
    
    _cardNumberTextField3 = [[UITextField alloc]initWithFrame:CGRectMake(110, 30, 45, 30)];
    _cardNumberTextField3.backgroundColor = [UIColor whiteColor];
    _cardNumberTextField3.borderStyle = UITextBorderStyleLine;
    _cardNumberTextField3.keyboardType = UIKeyboardTypeNumberPad;
    //    _cardNumberTextField3.background = [UIImage imageNamed:@"Text-Field-45.png"];
    _cardNumberTextField3.borderStyle = UITextBorderStyleLine;
    _cardNumberTextField3.delegate = self;
    
    _cardNumberTextField4 = [[UITextField alloc]initWithFrame:CGRectMake(160, 30, 45, 30)];
    _cardNumberTextField4.backgroundColor = [UIColor whiteColor];
    _cardNumberTextField4.borderStyle = UITextBorderStyleLine;
    _cardNumberTextField4.keyboardType = UIKeyboardTypeNumberPad;
    //    _cardNumberTextField4.background = [UIImage imageNamed:@"Text-Field-45.png"];
    _cardNumberTextField4.borderStyle = UITextBorderStyleLine;
    _cardNumberTextField4.delegate = self;
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 65, 300, 70)];
    container.backgroundColor = [UIColor clearColor];
	//    [self.view addSubview:container];
    
    UILabel *questionText = [[UILabel alloc] initWithFrame:CGRectMake(10,0,280,20)];
    questionText.backgroundColor = [UIColor clearColor];
    questionText.font = [UIFont fontWithName:@"Arial" size:13];
    questionText.text = @"Card Type";
    [container addSubview:questionText];
	//    [container addSubview:self.btn];
    
    _selectBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
    [_selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal] ;
    [_selectBtn setFrame:CGRectMake(30, 70, 210, 44)];
	//    [_selectBtn setBackgroundImage:[UIImage imageNamed:@"choseBtn.png"] forState:UIControlStateNormal];
    [_selectBtn setTitle:@"Choose Card" forState:UIControlStateNormal];
    _selectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_selectBtn addTarget:self action:@selector(selectClicked:) forControlEvents:UIControlEventTouchUpInside];
	//    [self btn];
    
	//    RadioButton *rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
	//    RadioButton *rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
	//    RadioButton *rb3 = [[RadioButton alloc] initWithGroupId:@"first group" index:2];
	//    RadioButton *rb4 = [[RadioButton alloc] initWithGroupId:@"first group" index:3];
	//    RadioButton *rb5 = [[RadioButton alloc] initWithGroupId:@"first group" index:4];
	//    RadioButton *rb6 = [[RadioButton alloc] initWithGroupId:@"first group" index:5];
	//    RadioButton *rb7 = [[RadioButton alloc] initWithGroupId:@"first group" index:6];
    
	//    rb1.frame = CGRectMake(10,20,20,20);
	//    rb2.frame = CGRectMake(130,20,20,20);
	//    rb3.frame = CGRectMake(10,45,20,20);
	//
	//
	//    rb4.frame = CGRectMake(120,45,20,20);
	//
	//    rb5.frame = CGRectMake(10,45,20,20);
	//    rb6.frame = CGRectMake(85,45,20,20);
	//    rb7.frame = CGRectMake(160,45,20,20);
    
	//    [container addSubview:rb1];
	//    [container addSubview:rb2];
	//    [container addSubview:rb3];
	//    [container addSubview:rb4];
    //    [container addSubview:rb5];
    //    [container addSubview:rb6];
    //    [container addSubview:rb7];
    
    
    
    UILabel *label1 =[[UILabel alloc] initWithFrame:CGRectMake(35, 20, 100, 20)];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"Visa / Delta";
    [container addSubview:label1];
    
    
    UILabel *label2 =[[UILabel alloc] initWithFrame:CGRectMake(155, 20, 80, 20)];
    label2.backgroundColor = [UIColor clearColor];
    label2.text = @"Master";
    [container addSubview:label2];
    
    UILabel *label3 =[[UILabel alloc] initWithFrame:CGRectMake(35, 45, 140, 20)];
    label3.backgroundColor = [UIColor clearColor];
    label3.text = @"American Express";
    [container addSubview:label3];
    
    UILabel *label4 =[[UILabel alloc] initWithFrame:CGRectMake(145, 45, 140, 20)];
    label4.backgroundColor = [UIColor clearColor];
    label4.text = @"American Express";
	//    [container addSubview:label4];
    
    //    UILabel *label5 =[[UILabel alloc] initWithFrame:CGRectMake(32, 45, 50, 20)];
    //    label5.backgroundColor = [UIColor clearColor];
    //    label5.text = @"Red";
    //    [container addSubview:label5];
    //
    //    UILabel *label6 =[[UILabel alloc] initWithFrame:CGRectMake(107, 45, 50, 20)];
    //    label6.backgroundColor = [UIColor clearColor];
    //    label6.text = @"Diners";
    //    [container addSubview:label6];
    //
    //    UILabel *label7 =[[UILabel alloc] initWithFrame:CGRectMake(182, 45, 50, 20)];
    //    label7.backgroundColor = [UIColor clearColor];
    //    label7.text = @"CB";
    //    [container addSubview:label7];
    
	//    [RadioButton addObserverForGroupId:@"first group" observer:self];
    
    
    [self.view1 addSubview:_selectBtn];
	
	//    [self.view1 addSubview:container];
	
    UILabel *expirayDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 130, 85, 30)];
    expirayDateLabel.font = [UIFont fontWithName:@"Arial" size:13];
    expirayDateLabel.text = @"Expiray Date";
    _expiryDateTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 155, 85, 30)];
    //    _expiryDateTextField.background = [UIImage imageNamed:@"Text-Field-85.png"];
    _expiryDateTextField.backgroundColor = [UIColor whiteColor];
    _expiryDateTextField.borderStyle = UITextBorderStyleLine;
    _expiryDateTextField.delegate = self;
    
    UILabel *CVNCodeLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 130, 110, 30)];
    CVNCodeLabel.font = [UIFont fontWithName:@"Arial" size:13];
    CVNCodeLabel.text = @"Securiy Code";
    
    _CVNCodeTextField = [[UITextField alloc]initWithFrame:CGRectMake(100, 155, 60, 30)];
    //    _CVNCodeTextField.background =[UIImage imageNamed:@"Text-Field-60.png"];
    _CVNCodeTextField.borderStyle = UITextBorderStyleLine;
    _CVNCodeTextField.backgroundColor = [UIColor whiteColor];
    _CVNCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _CVNCodeTextField.delegate = self;
    
    _monthPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(4, 170, 140, 100)];
    _monthPicker.delegate = self;
    //    _monthPicker.dataSource = self;
    
    UIButton *buttonNext = [[UIButton alloc]initWithFrame:CGRectMake(220, 160, 60, 30)];
    UIImage *imageNext = [UIImage imageNamed:@"Next.png"];
    [buttonNext setBackgroundImage:imageNext forState:UIControlStateNormal];
    [buttonNext addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonClose1 = [[UIButton alloc]initWithFrame:CGRectMake(270, 10, 20, 20)];
    UIImage *imageClose1 = [UIImage imageNamed:@"Close-Button.png"];
    [buttonClose1 setBackgroundImage:imageClose1 forState:UIControlStateNormal];
    [buttonClose1 addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view1 addSubview:cardNumberLabel];
    [self.view1 addSubview:_cardNumberTextField1];
    [self.view1 addSubview:_cardNumberTextField2];
    [self.view1 addSubview:_cardNumberTextField3];
    [self.view1 addSubview:_cardNumberTextField4];
    
    [self.view1 addSubview:expirayDateLabel];
    [self.view1 addSubview:_expiryDateTextField];
    
    [self.view1 addSubview:CVNCodeLabel];
    [self.view1 addSubview:_CVNCodeTextField];
    
    [self.view1 addSubview:_monthPicker];
    [self.view1 addSubview:buttonNext];
    [self.view1 addSubview:buttonClose1];
    
    UILabel *cardHolderNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 25, 290, 20)];
    cardHolderNameLabel.font = [UIFont fontWithName:@"Arial" size:13];
    cardHolderNameLabel.numberOfLines = 2;
    cardHolderNameLabel.text = @"Card holder's name; as appears on the card";
    
    _cardHolderNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 45, 250, 30)];
    //    _cardHolderNameTextField.background = [UIImage imageNamed:@"Text-Field-120.png"];
    _cardHolderNameTextField.backgroundColor = [UIColor whiteColor];
    _cardHolderNameTextField.borderStyle = UITextBorderStyleLine;
    _cardHolderNameTextField.delegate = self;
    
    UILabel *houneNoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 290, 20)];
    houneNoLabel.font = [UIFont fontWithName:@"Arial" size:13];
    houneNoLabel.numberOfLines = 2;
    houneNoLabel.text = @"House No or Name; where the card is registered";
    
    _houseNumberTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 100, 120, 30)];
    //    _houseNumberTextField.background = [UIImage imageNamed:@"Text-Field-120.png"];
    _houseNumberTextField.backgroundColor = [UIColor whiteColor];
    _houseNumberTextField.borderStyle = UITextBorderStyleLine;
    [_houseNumberTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    _houseNumberTextField.delegate = self;
    
    
    UILabel *postCodeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 135, 120, 20)];
    postCodeLabel.font = [UIFont fontWithName:@"Arial" size:13];
    postCodeLabel.text = @"Post Code";
    
    
    _postCodeTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 155, 120, 30)];
    //    _postCodeTextField.background = [UIImage imageNamed:@"Text-Field-120.png"];
    _postCodeTextField.backgroundColor = [UIColor whiteColor];
    _postCodeTextField.borderStyle = UITextBorderStyleLine;
    [_postCodeTextField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    _postCodeTextField.delegate = self;
    
    UIButton *buttonPrev = [[UIButton alloc]initWithFrame:CGRectMake(150, 160, 60, 30)];
    UIImage *imagePrev = [UIImage imageNamed:@"Prev.png"];
    [buttonPrev setBackgroundImage:imagePrev forState:UIControlStateNormal];
    [buttonPrev addTarget:self action:@selector(PreviousPage:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonDone = [[UIButton alloc]initWithFrame:CGRectMake(220, 160, 60, 30)];
    UIImage *imageDone = [UIImage imageNamed:@"Done.png"];
    [buttonDone setBackgroundImage:imageDone forState:UIControlStateNormal];
    [buttonDone addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonClose2 = [[UIButton alloc]initWithFrame:CGRectMake(270, 10, 20, 20)];
    UIImage *imageClose2 = [UIImage imageNamed:@"Close-Button.png"];
    [buttonClose2 setBackgroundImage:imageClose2 forState:UIControlStateNormal];
    [buttonClose2 addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view2 addSubview:cardHolderNameLabel];
    [self.view2 addSubview:_cardHolderNameTextField];
    
    [self.view2 addSubview:houneNoLabel];
    [self.view2 addSubview:_houseNumberTextField];
    
    [self.view2 addSubview:postCodeLabel];
    [self.view2 addSubview:_postCodeTextField];
    
    [self.view2 addSubview:buttonPrev];
    [self.view2 addSubview:buttonDone];
    [self.view2 addSubview:buttonClose2];
    
    self.view1.hidden =YES;
    self.view2.hidden = YES;
    UIImage *imageView = [UIImage imageNamed:@"Card-Detail-Back5.png"];
    UIColor *colorView = [UIColor colorWithPatternImage:imageView];
    self.view1.backgroundColor = colorView;
    self.view2.backgroundColor = colorView;
    
    
    
    arrayMonth = [[NSMutableArray alloc] init];
    [arrayMonth addObject:@"01"];
    [arrayMonth addObject:@"02"];
    [arrayMonth addObject:@"03"];
    [arrayMonth addObject:@"04"];
    [arrayMonth addObject:@"05"];
    [arrayMonth addObject:@"06"];
    [arrayMonth addObject:@"07"];
    [arrayMonth addObject:@"08"];
    [arrayMonth addObject:@"09"];
    [arrayMonth addObject:@"10"];
    [arrayMonth addObject:@"11"];
    [arrayMonth addObject:@"12"];
    
    arrayYear = [[NSMutableArray alloc] init];
    [arrayYear addObject:@"2013"];
    [arrayYear addObject:@"2014"];
    [arrayYear addObject:@"2015"];
    [arrayYear addObject:@"2016"];
    [arrayYear addObject:@"2017"];
    [arrayYear addObject:@"2018"];
    
    self.cardNumberTextField1.delegate = self;
    self.cardNumberTextField2.delegate = self;
    self.cardNumberTextField3.delegate = self;
    self.cardNumberTextField4.delegate = self;
    
    self.expiryDateTextField.delegate = self;
    self.CVNCodeTextField.delegate = self;
    
    self.monthPicker.hidden = YES;
    
    
    self.view1.layer.cornerRadius = 4;
    self.view1.layer.borderWidth = 2;
    self.view1.hidden = NO;
    
    
    blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 500)];
    blurView.backgroundColor = [UIColor blackColor];
    blurView.alpha = 0.4;
    
    [self.view addSubview:blurView ];
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{[self.view addSubview:self.view1];} completion:nil];
    
}

// ------------------------   PICKER VIEW ----------------------------------

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0) {
        NSString *string = self.expiryDateTextField.text;
        NSString *partFirst;
        NSString *partSecond;
        
        if (string.length == 0) {
            partFirst = [arrayMonth objectAtIndex:row];
            partSecond = @" / YYYY";
            self.expiryDateTextField.text = [partFirst stringByAppendingString:partSecond];
        } else {
            partFirst = [arrayMonth objectAtIndex:row];
            partSecond = [string substringFromIndex:2];
            self.expiryDateTextField.text = [partFirst stringByAppendingString:partSecond];
            
        }
        
        
    } else {
        NSString *string = self.expiryDateTextField.text;
        NSString *partFirst;
        NSString *partSecond;
        
        if (string.length == 0) {
            partFirst = @"MM / ";
            partSecond = [arrayYear objectAtIndex:row];
            self.expiryDateTextField.text = [partFirst stringByAppendingString:partSecond];
        } else {
            partFirst = [string substringToIndex:3];
            partSecond = [arrayYear objectAtIndex:row];
            partSecond = [@"/ " stringByAppendingString: partSecond];
            self.expiryDateTextField.text = [partFirst stringByAppendingString:partSecond];
            
        }
    }
    
	//    self.card.exirpyDate = self.expiryDateTextField.text;
}

-(NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSInteger rows;
    
    if (component == 0) {
        rows = [arrayMonth count];
    } else {
        rows = [arrayYear count];
    }
    return rows;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat height;
    
    if (component == 0) {
        height = 50;
    } else {
        height = 90;
    }
    return height;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *returnStr = @"";
    
    if (component == 0) {
        
        returnStr = [arrayMonth objectAtIndex:row];
        
    } else{
        
        returnStr = [arrayYear objectAtIndex:row];
        
    }
    
    return returnStr;
}

@end

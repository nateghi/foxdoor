//
//  AddCardViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/6/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "AddCardViewController.h"
#import "CardRegisteration.h"
#import "AddCard2ViewController.h"
#import "RadioButton.h"

@interface AddCardViewController ()<CardRegisterationDelegate,UITextFieldDelegate, UIPickerViewDelegate>

//<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
	CardRegisteration * registeration;
	UIView * indicatorView;
	BOOL canSegue;
	UIPickerView *monthPicker;
	NSMutableArray * arrayMonth;
	NSMutableArray * arrayYear;
	NIDropDown * dropDown;
	NSString * cardType;
}
@property (weak, nonatomic) IBOutlet UITextField *NameTextField;
@property (weak, nonatomic) IBOutlet UITextField *CardNumber1;
@property (weak, nonatomic) IBOutlet UITextField *CardNumber2;
@property (weak, nonatomic) IBOutlet UITextField *CardNumber3;
@property (weak, nonatomic) IBOutlet UITextField *CardNumber4;
@property (weak, nonatomic) IBOutlet UITextField *CardNumber5;

@property (weak, nonatomic) IBOutlet UITextField *ExpirationDateField;
@property (weak, nonatomic) IBOutlet UITextField *CVCTextField;
@property (weak, nonatomic) IBOutlet UIButton *NextButton;
@property (weak, nonatomic) IBOutlet UIScrollView *MyScrollView;
@property (weak, nonatomic) IBOutlet UIButton *CardTypeButton;
@property (weak, nonatomic) IBOutlet UITextField *IssueNumber;

@end

@implementation AddCardViewController

@synthesize NameTextField;
@synthesize CardNumber1;
@synthesize CardNumber2;
@synthesize CardNumber3;
@synthesize CardNumber4;
@synthesize CardNumber5;
@synthesize ExpirationDateField;
@synthesize CVCTextField;
@synthesize MyScrollView;
@synthesize CardTypeButton;
@synthesize IssueNumber;


- (void)viewDidLoad
{
    [super viewDidLoad];
	canSegue = NO;
	UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyBoard:)];
    [self.view addGestureRecognizer:tap];
	[MyScrollView setContentSize:CGSizeMake(0, 100)];
	monthPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(ExpirationDateField.frame.origin.x + ExpirationDateField.frame.size.width - 20, CardNumber5.frame.origin.y + CardNumber5.frame.size.height - 10, 140, 100)];
    monthPicker.delegate = self;
	[monthPicker setHidden:YES];
	[self.view addSubview:monthPicker];
	
	[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backToPreviousPage)]];
	
	arrayMonth = [[NSMutableArray alloc] init];
	arrayYear = [NSMutableArray new];
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
    [arrayYear addObject:@"2014"];
    [arrayYear addObject:@"2015"];
    [arrayYear addObject:@"2016"];
    [arrayYear addObject:@"2017"];
    [arrayYear addObject:@"2018"];
    [arrayYear addObject:@"2019"];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 212, 280, 60)];
    container.backgroundColor = [UIColor clearColor];
    [self.view addSubview:container];
    
    RadioButton *rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
    RadioButton *rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
    RadioButton *rb3 = [[RadioButton alloc] initWithGroupId:@"first group" index:2];
    
    rb1.frame = CGRectMake(10,10,22,22);
    rb2.frame = CGRectMake(150,10,22,22);
    rb3.frame = CGRectMake(10,30,22,22);
    
    [container addSubview:rb1];
    [container addSubview:rb2];
    [container addSubview:rb3];
    

    
    [RadioButton addObserverForGroupId:@"first group" observer:self];
}

-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    NSLog(@"changed to %d in %@",index,groupId);
    
    switch (index) {
            
        case 0:
        {
            
			cardType = @"VISA";
            NSLog(@"Visa is chosen");
            
        }
            break;
        case 1:
        {
			cardType = @"MC";
            NSLog(@"Master is chosen");
			
        }
            break;
            
        case 2:
        {
			cardType = @"AX";
            NSLog(@"AX is chosen");
			
            
        }
            break;
            
        case 4:
        {
			//            self.card.cardType = @"JCB";
            
        }
            break;
            
        default:
            break;
    }

}

- (void)viewWillAppear:(BOOL)animated
{
	registeration = [CardRegisteration new];
	[registeration setDelegate:self];

	canSegue = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)backToPreviousPage
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyBoard:(id)sender
{
	[self.view endEditing:NO];
	//	if (dropDown) {
	//		[dropDown hideDropDown:CardTypeButton];
	//	}
}

- (IBAction)tappedNext:(UIButton *)sender
{
	
}

- (void)showIndicator
{
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[indicator startAnimating];
	
	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 320, 100)];
	[label setText:@"Please wait!"];
	[label setTextColor:[UIColor whiteColor]];
	[label setTextAlignment:NSTextAlignmentCenter];
	[label setFont:[UIFont systemFontOfSize:30]];
	
	indicatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	indicatorView.backgroundColor = [UIColor blackColor];
	indicatorView.alpha = 0.8;
	[indicatorView addSubview:indicator];
	[indicatorView addSubview:label];
	[indicator setCenter:indicatorView.center];
	
	[self.view addSubview:indicatorView];
	[self.view bringSubviewToFront:indicatorView];
}

#pragma mark - Navigation

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	NSString * name = [NameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString * cardNumber = [NSString stringWithFormat:@"%@%@%@%@%@", CardNumber1.text,CardNumber2.text, CardNumber3.text, CardNumber4.text,CardNumber5.text];
	NSString * year = ExpirationDateField.text;
	NSString * cvc = CVCTextField.text;
	NSString * validationMessage = @"";
	NSString * issueNumber = [IssueNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (cvc.length < 1) {
		validationMessage = @"CVC couldn't be empty";
	}
	if (year.length < 1) {
		validationMessage = @"Year couldn't be empty";
	}
	if (cardNumber.length < 1) {
		validationMessage = @"Card Number couldn't be empty";
	}
	if (name.length < 1) {
		validationMessage = @"Name couldn't be empty";
	}
	if (cardType.length < 1) {
		validationMessage = @"You have to choose one card type.";
	}
	if (validationMessage.length > 0) {
		[[[UIAlertView alloc] initWithTitle:nil message:validationMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return NO;
	}
	[self showIndicator];
	NSString * expMonth = [arrayMonth objectAtIndex:[monthPicker selectedRowInComponent:0]];
	NSString * expYear = [arrayYear objectAtIndex:[monthPicker selectedRowInComponent:1]];
	[registeration submitWithName:name cardNumber:cardNumber CVC:cvc withExpirationYear:expYear withExpirationMonth:expMonth cardType:cardType issueNumber:issueNumber];
	
	return canSegue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[registeration dissmiss];
	AddCard2ViewController * addCard = (AddCard2ViewController *)segue.destinationViewController;
	[addCard setRegisterationManager:registeration];
}

#pragma mark - Registeration Delegate

- (void)didDuccessfullyGetToken:(NSString *)token
{
	if (!canSegue) {
		[indicatorView removeFromSuperview];
		indicatorView = nil;
		canSegue = YES;
		
		[[[UIAlertView alloc] initWithTitle:@"token" message:token delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		
		[self performSegueWithIdentifier:@"AddController12" sender:self];
	}
}

- (void)didFailToGetTokenWithErrorDescription:(NSString *)error
{
	[indicatorView removeFromSuperview];
	indicatorView = nil;
	[[[UIAlertView alloc] initWithTitle:nil message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)didTimeOutProblem
{
	if (indicatorView) {
		[indicatorView removeFromSuperview];
		indicatorView = nil;
	}
	[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

#pragma mark - UI Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField == CVCTextField || textField == IssueNumber) {
		[UIView animateWithDuration:.5 animations:^{
			[self.view setFrame:CGRectMake(0, -200, self.view.frame.size.width, self.view.frame.size.height)];
		}];
	}
	[textField selectAll:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField == CVCTextField || textField == IssueNumber) {
		[UIView animateWithDuration:.5 animations:^{
			[self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
			
		}];
	}
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    BOOL returnBool;
    
    if (textField == ExpirationDateField) {
        monthPicker.hidden = NO;
        
        [CardNumber1 resignFirstResponder];
        [CardNumber2 resignFirstResponder];
        [CardNumber3 resignFirstResponder];
        [CardNumber4 resignFirstResponder];
        
        
        [ExpirationDateField resignFirstResponder];
        [CVCTextField resignFirstResponder];
        
        returnBool = NO;
        
    } else{
		
        monthPicker.hidden = YES;
        returnBool = YES;
    }
    
    return returnBool;
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == CardNumber1 || textField == CardNumber2 ||textField == CardNumber3 || textField == CardNumber4 || textField == CardNumber5) {
        
        [self autoJump:textField shouldChangeCharactersInRange:range replacementString:string];
        
    } else if(textField == NameTextField || textField == self.CVCTextField){
        return YES;
    }
	if (textField == IssueNumber) {
		return YES;
	}
    //always return no since we are manually changing the text field
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == NameTextField) {
		[NameTextField resignFirstResponder];
		[CardNumber1 becomeFirstResponder];
	}
	return YES;
}


-(void)autoJump:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    BOOL shouldProcess = NO; //default to reject
    BOOL shouldMoveToNextField = NO; //default to remaining on the current field
    
    int insertStringLength = (int)[string length];
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
            //4
			if (CardNumber4.text.length == 4) {
                [CardNumber5 becomeFirstResponder];
			}
			else if (CardNumber3.text.length == 4) {
                [CardNumber4 becomeFirstResponder];
                
            } else if(CardNumber2.text.length == 4){
                [CardNumber3 becomeFirstResponder];
                
            } else if(CardNumber1.text.length == 4){
                [CardNumber2 becomeFirstResponder];
                
            }
        }
    }
}

#pragma mark - Picker View Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0) {
        NSString *string = ExpirationDateField.text;
        NSString *partFirst;
        NSString *partSecond;
        
        if (string.length == 0) {
            partFirst = [arrayMonth objectAtIndex:row];
            partSecond = @" / YYYY";
            ExpirationDateField.text = [partFirst stringByAppendingString:partSecond];
        } else {
            partFirst = [arrayMonth objectAtIndex:row];
            partSecond = [string substringFromIndex:2];
            ExpirationDateField.text = [partFirst stringByAppendingString:partSecond];
            
        }
        
        
    } else {
        NSString *string = ExpirationDateField.text;
        NSString *partFirst;
        NSString *partSecond;
        
        if (string.length == 0) {
            partFirst = @"MM / ";
            partSecond = [arrayYear objectAtIndex:row];
            ExpirationDateField.text = [partFirst stringByAppendingString:partSecond];
        } else {
            partFirst = [string substringToIndex:3];
            partSecond = [arrayYear objectAtIndex:row];
            partSecond = [@"/ " stringByAppendingString: partSecond];
            ExpirationDateField.text = [partFirst stringByAppendingString:partSecond];
            
        }
    }
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

#pragma mark - NI Drop Down

- (IBAction)selectClicked:(id)sender {
    monthPicker.hidden = YES;
	[CardNumber1 resignFirstResponder];
	[CardNumber2 resignFirstResponder];
	[CardNumber3 resignFirstResponder];
	[CardNumber4 resignFirstResponder];
	[CardNumber5 resignFirstResponder];
	[CVCTextField resignFirstResponder];
	[NameTextField resignFirstResponder];
	[ExpirationDateField resignFirstResponder];
	
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
    
    NIDropDown *button = (NIDropDown*)sender;
    
    int index = button.tag;
	//    self.card.cardType = @"";
    
    NSLog(@"the index is %d", index);
	
    switch (index) {
            
        case 0:
        {
            
			//            self.card.cardType = @"VISA";
            NSLog(@"Visa is chosen");
            
        }
            break;
        case 1:
        {
			//            self.card.cardType = @"MC";
            NSLog(@"Master is chosen");
			
        }
            break;
            
        case 2:
        {
			//            self.card.cardType = @"AX";
            NSLog(@"AX is chosen");
			
            
        }
            break;
            
        case 4:
        {
			//            self.card.cardType = @"JCB";
            
        }
            break;
            
        default:
            break;
    }
	[self rel];
}

-(void)rel
{
    dropDown = nil;
}

@end

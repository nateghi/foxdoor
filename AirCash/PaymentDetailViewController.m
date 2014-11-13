//
//  DetailViewController.m
//  AirCash
//
//  Created by Younes Nouri Soltan on 21/12/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaymentDetailViewController.h"
#import "Payment.h"
#import "Card.h"

#import "AppDelegate.h"

#import "KeychainItemWrapper.h"
#import "NSData+Base64.h"
#import "Reachability.h"

#import "CardsViewController.h"
#import "AddCardViewController.h"


@interface PaymentDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property(strong, nonatomic) NSMutableArray *cards;

@property(strong, nonatomic)UIButton *PayButton;
@property(strong, nonatomic)UIButton *NextButton;
@property(strong, nonatomic)UIButton *RejectButton;
@property(strong, nonatomic)UIButton *AddCardButton;
@property(strong, nonatomic)UIButton *ChangeCardButton;
@property(strong, nonatomic)UIView *CardView;

- (void)configureView;
@end

@implementation PaymentDetailViewController

@synthesize payments = _payments;
@synthesize card = _card;
@synthesize pointer = _pointer;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;

NSMutableArray *cards;

UIView *blurView;

KeychainItemWrapper *cardsWrapper;

#pragma mark - Managing the detail item

- (void)setPayments:(NSMutableArray *)payments
{
    if (_payments != payments) {
        _payments = payments;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)setPointer:(NSInteger)pointer{
    
    _pointer = pointer;
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    
    Payment *payment = [_payments objectAtIndex:_pointer];
    
    if (payment) {
        
        NSString *labelString;
        NSMutableString *amountString;
        
        if (payment.amount ) {
            amountString = [[payment.amount stringValue]mutableCopy] ;
            [amountString insertString:@"£" atIndex:0];
            [amountString insertString:@"." atIndex:amountString.length - 2];
            labelString = amountString;
        }
		
        
        if (payment.businessName != (NSString *)[NSNull null] && ![payment.businessName isEqualToString:@""]) {
            
            labelString = [payment.businessName stringByAppendingString:@" has requested"];
            labelString = [labelString stringByAppendingString:@"\n\n"];
            labelString = [labelString stringByAppendingString:amountString];
            labelString = [labelString stringByAppendingString:@"\n"];
        }
		
        
        if (payment.propertyNumber != (NSString *)[NSNull null] && ![payment.propertyNumber isEqualToString:@""]) {
            labelString = [labelString stringByAppendingString:payment.propertyNumber];
            labelString = [labelString stringByAppendingString:@" "];
        }
		
        
        if (payment.street != (NSString *)[NSNull null] && ![payment.street isEqualToString:@""]) {
            labelString = [labelString stringByAppendingString:payment.street];
            labelString = [labelString stringByAppendingString:@"\n "];
        }
		
        if (payment.postCode != (NSString *)[NSNull null]&& ![payment.postCode isEqualToString:@""]) {
            labelString = [labelString stringByAppendingString:payment.postCode];
            labelString = [labelString stringByAppendingString:@"\n"];
			
        }
        if (payment.telephoneNumber != (NSString *)[NSNull null]&& ![payment.telephoneNumber isEqualToString:@""]) {
            labelString = [labelString stringByAppendingString:payment.telephoneNumber];
			
        }
		
        self.detailDescriptionLabel.lineBreakMode = 3;
        self.detailDescriptionLabel.text = labelString;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationItem.backBarButtonItem setAction:@selector(perform:)];
    UIImage *image = [UIImage imageNamed:@"BackGround"];
    UIColor *color = [UIColor colorWithPatternImage:image];
    self.view.backgroundColor = color;
    
    //UIImage *imageHeader = [UIImage imageNamed:@"header2.png"];
    //UIColor *colorHeader = [UIColor colorWithPatternImage:imageHeader];
    self.header.backgroundColor = [UIColor clearColor];
    
    self.detailDescriptionLabel.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [reach startNotifier];
    
    [self configureView];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    if ([super.cards count] > 1) {
        
        self.NextButton = [[UIButton alloc]initWithFrame:CGRectMake(200, self.view.frame.size.height - 45, 40, 30)];
        UIImage *imageFirst = [UIImage imageNamed:@"Continue2.png"];
        [self.NextButton setBackgroundImage:imageFirst forState:UIControlStateNormal];
        [self.NextButton addTarget:self action:@selector(onShowButton:) forControlEvents:UIControlEventTouchUpInside];
        self.NextButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
		
        [self.view addSubview:self.NextButton];
    }
    [self loadCard];
    
}

-(void)loadCard{
    
    self.RejectButton = [[UIButton alloc]initWithFrame:CGRectMake(80, self.view.frame.size.height - 45, 40, 30)];
    UIImage *imageFirst = [UIImage imageNamed:@"ignore_icon"];
    [self.RejectButton setBackgroundImage:imageFirst forState:UIControlStateNormal];
    [self.RejectButton addTarget:self action:@selector(reject:) forControlEvents:UIControlEventTouchUpInside];
    self.RejectButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
	
    [self.view addSubview:self.RejectButton];
    
    if ([super.cards count] == 0 ) {
        // Add card
        
        self.AddCardButton = [[UIButton alloc]initWithFrame:CGRectMake(200, self.view.frame.size.height - 45, 40, 30)];
        UIImage *imageAddCardButton = [UIImage imageNamed:@"Add.png"];
        [self.AddCardButton setBackgroundImage:imageAddCardButton forState:UIControlStateNormal];
        
        [self.AddCardButton addTarget:self action:@selector(insetCard) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.AddCardButton];
        
        //        [self.RejectButton removeFromSuperview];
        
        
    } else if ([super.cards count] == 1 ){
        
        [self.NextButton removeFromSuperview];
        NSDictionary *cardDic = [super.cards objectAtIndex:0];
        _card = [[Card alloc]initWithDictionary:cardDic];
        
        // Pay Now
        
        [self addCardView:0];
        
        self.PayButton = [[UIButton alloc]initWithFrame:CGRectMake(200, self.view.frame.size.height - 45, 40, 30)];
        UIImage *imageFirst = [UIImage imageNamed:@"payment"];
        [self.PayButton setBackgroundImage:imageFirst forState:UIControlStateNormal];
        [self.PayButton addTarget:self action:@selector(payNow:) forControlEvents:UIControlEventTouchUpInside];
		
        [self.view addSubview:self.PayButton];
        
    } else  if([super.cards count] > 1){
        // Proceed
        
        
    }
}

-(void)insetCard{
	UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
	
	AddCardViewController * addCardViewController = [storyboard instantiateViewControllerWithIdentifier:@"AddCardNavigationController"];
	//
	[self presentViewController:addCardViewController animated:YES completion:nil];
	return;
}

-(void)addCardView :(NSUInteger)cardInArray{
    
    NSMutableDictionary *card = [super.cards objectAtIndex:cardInArray ];
    UIColor *color = [UIColor whiteColor];
    //    if (self.CardView) {
    
    self.CardView = [[UIView alloc]initWithFrame:CGRectMake(0, 300, 320, 60)];
    //    }
    
    self.CardView.backgroundColor = [UIColor clearColor];
    self.CardView.backgroundColor = color;
    
    UILabel *cardNo = [[UILabel alloc]initWithFrame:CGRectMake(85, 18, 120, 30)];
    
    UIImage *imageCard;
    
    if ([[card valueForKey:@"cardType"] isEqualToString:@"visa"]) {
        
        imageCard = [UIImage imageNamed:@"VisaCard.jpeg"];
        
    } else {
        
        imageCard = [UIImage imageNamed:@""];
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 12, 60, 40)];
    imageView.image = imageCard;
    
    NSString *cardString = [[card valueForKey:@"cardNumber"]substringFromIndex:12];
    cardString = [@"************" stringByAppendingString:cardString];
    cardNo.text = cardString;
    cardNo.backgroundColor = [UIColor clearColor];
    
    [self.CardView addSubview:cardNo];
    [self.CardView addSubview:imageView];
    
    [self.view addSubview:self.CardView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

-(IBAction)payNow:(id)sender{
    
    [self payWebService];
    
}

-(void)payWebService{
    
    UILabel *waitLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 210, 110, 90)];
    waitLabel.backgroundColor = [UIColor blackColor];
    waitLabel.alpha = 0.7;
    waitLabel.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(35, 15, 40, 40)];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [activity startAnimating];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 55, 100, 30)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = @"Please wait...";
    
    [waitLabel addSubview:activity];
    [waitLabel addSubview:textLabel];
    [self.view addSubview:waitLabel];
    
    KeychainItemWrapper *userWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"account" accessGroup:nil];
    User *userDetails = [[User alloc]init];
    
    NSString *decodedString = [userWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSData *decodedData = [NSData dataWithBase64EncodedString:decodedString];
    
    if (decodedData) {
        
        userDetails = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    }
    
    Payment *payment = [_payments objectAtIndex:_pointer];
    
    NSString *urlString = @"https://foxdoor.com/Service/Service/AcceptTokenizedPaymentRequest/";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request addValue:userDetails.registrationID forHTTPHeaderField:@"Authorization"];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
//    [request addValue:[userDetails.password base64EncodedString] forHTTPHeaderField:@"X-Password"];
	
	
    NSDictionary *paymentRequestDic = [[NSDictionary alloc]initWithObjectsAndKeys:payment.paymentID, @"PaymentRequestId", _card.Token, @"token", nil];
    
	//        NSDictionary *paymentRequestDic = [[NSDictionary alloc]initWithObjectsAndKeys:payment.paymentID, @"PaymentRequestId", @"5425232820001308", @"CardNumber", @"0216", @"ExpiryDate", _card.cardHolderName, @"CardHolderName", @"MC", @"CardType", nil];
	
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:paymentRequestDic
						
                                                       options:NSJSONWritingPrettyPrinted error:nil];
	
    [request setHTTPBody:jsonData];
	
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         
         NSDictionary *dicResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
		 
		 //         NSObject *dicResponse = [arrayResponse objectAtIndex:0];
         
//         NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
         
         
         if (httpResponse.statusCode == 200 && [[dicResponse valueForKey:@"PaymentStatus"] isEqualToString:@"SUCCESS"] ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (waitLabel) {
                     [waitLabel removeFromSuperview];
                     
                 }
                 
				 //                 NSString *message = @"The payment has successfully been processed";
                 UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Successfull"
                                                                        message:[NSString stringWithFormat:@"%@", [dicResponse valueForKey:@"Message"]]
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                 messageAlert.tag =  0;
                 [messageAlert show];
                 
             });
             
         } else if(httpResponse.statusCode == 200 && ![[dicResponse valueForKey:@"Resuslt"] isEqualToString:@"SUCCESS"] ){
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (waitLabel) {
                     [waitLabel removeFromSuperview];
                     
                 }
                 
                 //                 NSString *message = @"The payment has successfully been processed";
                 UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                                        message:[NSString stringWithFormat:@"%@", [dicResponse valueForKey:@"Message"]]
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                 messageAlert.tag = 1;
                 [messageAlert show];
                 
             });
			 
         }
         
         else if(httpResponse.statusCode != 200){
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (waitLabel) {
                     [waitLabel removeFromSuperview];
                     
                 }
                 
                 //                 NSString *message = @"The payment has successfully been processed";
                 UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                                        message:@"Unkown Error, please try again later"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                 
                 messageAlert.tag = 2;
                 [messageAlert show];
                 
             });
             
         }
     }];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 0) {
        
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        app.pointer = self.pointer;
        [self.navigationController popViewControllerAnimated:YES];
    }
	
}

-(IBAction)proceed:(id)sender{
    
    [self.CardView removeFromSuperview];
}

-(IBAction)reject:(id)sender{
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    //    [app.PaymentRequests removeObjectAtIndex:_pointer];
    app.pointer = self.pointer;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)closeView:(id)sender{
    
    UIButton *button = sender;
    [button.superview removeFromSuperview];
    [blurView removeFromSuperview];
    
}

-(IBAction)Done:(id)sender{
    
    [super Done:nil];
    [self addCardView:0];
    [self loadCard];
    
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        
    }
    else
    {
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Connectivity Problem"
                                                               message:@"You need to connect your mobile to 3G or WiFi"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [messageAlert show];
    }
}

- (IBAction)onShowButton:(id)sender {
    //[self showList];
}

- (void)showList {
    
    NSInteger numberOfOptions = [super.cards count];
    NSMutableArray *options = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [super.cards count]; i++) {
        
        Card *card = [super.cards objectAtIndex:i];
        UIColor *color = [UIColor whiteColor];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(14, i*62 +20, 280, 60)];
        view.tag = i;
        view.backgroundColor = [UIColor clearColor];
        view.backgroundColor = color;
        
        UILabel *cardNo = [[UILabel alloc]initWithFrame:CGRectMake(85, 18, 120, 30)];
        
        UIImage *imageCard;
        
        if ([[card valueForKey:@"cardType"] isEqualToString:@"visa"]) {
            
            imageCard = [UIImage imageNamed:@"VisaCard.jpeg"];
            
        } else {
            
            imageCard = [UIImage imageNamed:@""];
            
        }
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 12, 60, 40)];
        imageView.image = imageCard;
        
        NSString *cardString = [[card valueForKey:@"cardNumber"]substringFromIndex:12];
        //        NSString *cardString = @"some";
        
        cardString = [@"************" stringByAppendingString:cardString];
        //        cardNo.textColor = [UIColor whiteColor];
        cardNo.text = cardString;
        
        [view addSubview:cardNo];
        [view addSubview:imageView];
        
        [options addObject:view];
        
    }
    RNGridMenu *av = [[RNGridMenu alloc] initWithViews:[options subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    av.itemSize = CGSizeMake(308, 80);
    
    
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width /2.f, self.view.bounds.size.height/2.f)];
}

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    [self addCardView:itemIndex];
    
    self.cardPointer = itemIndex;
    NSDictionary *cardDic = [super.cards objectAtIndex:itemIndex];
    _card = [[Card alloc]init];
    _card = (Card*)[[Card alloc]initWithDictionary:cardDic];
    
    if (self.NextButton) {
        [self.NextButton removeFromSuperview];
    }
    
    if ([super.cards count] > 1) {
        // Add Change
        self.ChangeCardButton = [[UIButton alloc]initWithFrame:CGRectMake(200, self.view.frame.size.height - 45, 40, 30)];
        UIImage *imageChangeCardButton = [UIImage imageNamed:@"Change1.png"];
        [self.ChangeCardButton setBackgroundImage:imageChangeCardButton forState:UIControlStateNormal];
        [self.ChangeCardButton addTarget:self action:@selector(onShowButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.PayButton = [[UIButton alloc]initWithFrame:CGRectMake(130, self.view.frame.size.height - 45, 40, 30)];
        UIImage *imageFirst = [UIImage imageNamed:@"payment"];
        [self.PayButton setBackgroundImage:imageFirst forState:UIControlStateNormal];
        [self.PayButton addTarget:self action:@selector(payNow:) forControlEvents:UIControlEventTouchUpInside];
		[self.PayButton setCenter:CGPointMake(self.view.center.x, self.PayButton.center.y)];
        
        [self.view addSubview:self.ChangeCardButton];
        [self.view addSubview:self.PayButton];
        
    }
}



@end

//
//  MasterViewController.m
//  AirCash
//
//  Created by Younes Nouri Soltan on 21/12/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "AppDelegate.h"

#import "PaymentDetailViewController.h"
#import  "CardManageViewController.h"
#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "Payment.h"
#import "Reachability.h"

#import "NSData+Base64.h"
#import "KeychainItemWrapper.h"

#import "Constants.h"
#import "KxMenu.h"
#import "LogInViewController.h"

@interface MasterViewController()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MasterViewController

@synthesize paymentDetailViewController = _paymentDetailViewController;
@synthesize payments;
@synthesize tableView;

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.payments = [NSMutableArray new];
    self.tableView.delegate =self;
	[self.tableView setDataSource:self];
	
    UIImage *imageSetting = [UIImage imageNamed:@"Setting"];
    UIBarButtonItem *buttonSetting = [[UIBarButtonItem alloc] initWithImage:imageSetting style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    self.navigationItem.rightBarButtonItem = buttonSetting;
    
    UIImage *imageRefresh = [UIImage imageNamed:@"Refresh"];
    UIBarButtonItem *buttonRefresh = [[UIBarButtonItem alloc] initWithImage:imageRefresh style:UIBarButtonItemStylePlain target:self action:@selector(refresh:)];
    self.navigationItem.leftBarButtonItem = buttonRefresh;

	self.tableView.backgroundColor = [UIColor clearColor];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.pointer != -1) {
        //        self.payments = app.PaymentRequests;
        [self.payments removeObjectAtIndex:app.pointer ];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:app.pointer inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        app.pointer = -1;
        [self.tableView reloadData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushHandler:) name:@"PaymentRequestNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"google.com"];
    [reach startNotifier];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PaymentRequestNotification" object:nil];
}

-(void)pushHandler :(NSDictionary*)userInfo{
    
    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Payment Request" message:BASE_URL delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [messageAlert show];
    });
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self loadPaymentRequests];
}

-(void)loadPaymentRequests
{
    UILabel *waitLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 210, 110, 90)];
    waitLabel.backgroundColor = [UIColor blackColor];
    waitLabel.alpha = 0.7;
    waitLabel.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(35, 15, 40, 40)];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [activity startAnimating];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 55, 140, 30)];
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
    
    NSString *urlString = [BASE_URL stringByAppendingString:@"Service/Service/GetPaymentRequests/"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:userDetails.registrationID forHTTPHeaderField:@"X-CustomerId"];
    [request addValue:[userDetails.password base64EncodedString] forHTTPHeaderField:@"X-Password"];
    
    [request setHTTPMethod:@"GET"];
	
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
//         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [activity stopAnimating];
             [activity removeFromSuperview];
             [textLabel removeFromSuperview];
             [waitLabel removeFromSuperview];
         });
         
         if ([data length] > 0 && error == nil){
             
             NSArray *dicResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             NSMutableString* responseString;
             responseString = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]mutableCopy];
             
             
             self.payments = [[NSMutableArray alloc]init];
             
             for (NSObject *object in dicResponse) {
                 
                 Payment *payment = [[Payment alloc]init];
                 
                 [payment setPaymentID:[object valueForKey:@"PaymentRequestId"]];
                 [payment setBusinessName:[object valueForKey:@"BusinessName"]];
                 [payment setBranch:[object valueForKey:@"Branch"]];
                 [payment setPropertyNumber:[object valueForKey:@"PropertyNumber"]];
                 [payment setStreet:[object valueForKey:@"Street"]];
                 [payment setTown:[object valueForKey:@"Town"]];
                 [payment setPostCode:[object valueForKey:@"PostCode"]];
                 [payment setTelephoneNumber:[object valueForKey:@"TelephoneNumber"]];
                 [payment setAmount:[object valueForKey:@"Amount"]];
                 
                 [self.payments addObject:payment];
                 
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (waitLabel) {
                     [waitLabel removeFromSuperview];
                     
                 }
                 [self.tableView reloadData];
                 
             });
             
         }else{
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (waitLabel) {
                     [waitLabel removeFromSuperview];
					 
                 }
                 
                 [self.tableView reloadData];
                 
             });
         }
         
     }];
}

-(IBAction)card:(id)sender{
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [story instantiateViewControllerWithIdentifier:@"cardManage"];
    //	    [self presentViewController:navController animated:YES completion:^{}];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    int row = (int)indexPath.row;
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        [[segue destinationViewController] setPointer:row];
        
        [[segue destinationViewController] setPayments:self.payments];
    }
}

#pragma mark - UITableView Delegate & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.payments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.paymentDetailViewController.payments = self.payments;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0.0;
    height = 74;
    
    return height;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.selectedBackgroundView.frame];
    //
    //    [cell setSelectedBackgroundView:backgroundView];
    
    UIImage *image = [UIImage imageNamed:@"requestCellBG"];
    UIColor *color = [UIColor colorWithPatternImage:image];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 2, 320, 68)];
    view.backgroundColor = [UIColor clearColor];
    view.backgroundColor = color;
    UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NextPointer"]];
	[arrow setCenter:CGPointMake(300, view.center.y)];
	[view addSubview:arrow];
    //    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Button1.png"]];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 12, 45, 45)];
    
//    imageView.image = [UIImage imageNamed:@"sampleRequestPic"];
    
    UILabel *paymentInquirer = [[UILabel alloc]initWithFrame:CGRectMake(80, 5, 120, 30)];
	[paymentInquirer setTextColor:[UIColor grayColor]];
	
    UILabel *amount = [[UILabel alloc]initWithFrame:CGRectMake(80, 30, 55, 30)];
    
    Payment *payment = [self.payments objectAtIndex:indexPath.row ];
    
    if (![payment.businessName isEqual:[NSNull null] ]) {
        
        paymentInquirer.text = payment.businessName;
        
    }
	paymentInquirer.backgroundColor = [UIColor whiteColor];
    
    NSMutableString *amountString = [[payment.amount stringValue]mutableCopy] ;
    [amountString insertString:@"£" atIndex:0];
    [amountString insertString:@"." atIndex:amountString.length - 2];
    
    amount.text = amountString;
    //    amount.backgroundColor = [UIColor clearColor];
    
    [view addSubview:imageView];
    [view addSubview:paymentInquirer];
    [view addSubview:amount];
    [cell addSubview:view];
//	[cell setBackgroundColor:[UIColor whiteColor]];
    
    if (indexPath.row == self.payments.count) {
        //        [waitLabel removeFromSuperview];
    }
    
}

#pragma mark - Menu Items

- (IBAction)showMenu:(UIBarButtonItem *)sender
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"        Settings"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@" Passcode lock    "
                     image:nil
                    target:self
                    action:@selector(settings:)],
      
      [KxMenuItem menuItem:@" Sign out    "
                     image:nil
                    target:self
                    action:@selector(signout:)],
      
      
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentLeft;
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(self.navigationItem.rightBarButtonItem.customView.frame.origin.x + 300, self.navigationItem.rightBarButtonItem.customView.frame.origin.y + 50, self.navigationItem.rightBarButtonItem.customView.frame.size.width, self.navigationItem.rightBarButtonItem.customView.frame.size.height)
                 menuItems:menuItems];
}

-(void)signout:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
		UIStoryboard *stroy = [ UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
		UIViewController *vc = [stroy instantiateViewControllerWithIdentifier:@"SignInNavigationController"];
		[self presentViewController:vc animated:YES completion:nil];
	}];
}

- (IBAction)settings:(id)sender
{
    
//	    KKPasscodeSettingsViewController *vc = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
//	    vc.delegate = self;
//	    [self.navigationController pushViewController:vc animated:YES];
    
    UIStoryboard *stroy = [ UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    SettingsViewController* vc = [stroy instantiateViewControllerWithIdentifier:@"Settings"];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navController animated:YES completion:nil];
    
}

- (IBAction)refresh:(id)sender
{
    
    [self loadPaymentRequests];
}

#pragma mark - Reachability

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        [self loadPaymentRequests];
        
    } else {
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Connectivity Problem"  message:@"You need to connect your mobile to 3G or WiFi" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [messageAlert show];
    }
}

@end

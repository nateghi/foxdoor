//
//  CardRegisteration.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "CardRegisteration.h"
#import <AFNetworking/AFNetworking.h>
#import "Card.h"
#import "NSData+Base64.h"
#import "KeychainItemWrapper.h"

@interface CardRegisteration()<UIWebViewDelegate>
{
	UIWebView * webView;
	NSTimer * timer;
	Card * card;
}

//@property (weak, nonatomic)  NSString *Name;
//@property (weak, nonatomic)  NSString *CardNumber1;
//@property (weak, nonatomic)  NSString *CVC;
//@property (weak, nonatomic)  NSString *ExpirationMonth;
//@property (weak, nonatomic)  NSString *ExpirationYear;
//@property (weak, nonatomic)  NSString *CardType;
//@property (weak, nonatomic)  NSString *CardRegisterationAddress;
//@property (weak, nonatomic)  NSString *IssueNo;

@end

@implementation CardRegisteration

@synthesize Delegate;

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self initWebView];
		card = [Card new];
	}
	return self;
}
- (void)clearCache
{
	webView = nil;
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)initWebView
{
	[self clearCache];
	webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	[webView setDelegate:self];
	
	NSURL * url = [[NSBundle mainBundle] URLForResource:@"html" withExtension:@"html"];
	NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:200];
	[webView loadRequest:request];
}

- (void)submitWithName:(NSString *)name cardNumber:(NSString *)cardNumber CVC:(NSString *)cvc withExpirationYear:(NSString *)expirationYear withExpirationMonth:(NSString *)expirationMonth cardType:(NSString *)cardType issueNumber:(NSString *)issueNumber
{
	card.nameOnCard = name;
	card.cardNumber = cardNumber;
	card.cvc = cvc;
	card.expirationYear = expirationYear;
	card.expirationMonth = expirationMonth;
	card.cardType = cardType;
	card.issueNumber = issueNumber;
	[self submit];
}

- (void)submit
{
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('NameOnCard').value = '%@'",[ card.nameOnCard stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('CardNumber').value = '%@'", card.cardNumber]];
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('CVC').value = '%@'", card.cvc]];
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('EXPMM').value = '%@'", card.expirationMonth]];
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('EXPYY').value = '%@'", card.expirationYear]];
	[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('btnPlaceOrder').click();"];
	[self checkValidation];
}

- (void)finalizeRegisterationWithHouseNumberOrName:(NSString *)houseNomber postCode:(NSString *)postCode streetName:(NSString *)streetName
{
	card.HouseNumber =houseNomber;
	card.PostCode = postCode;
	card.StreetName = streetName;
	[self finalizeRegister];
}

- (void)finalizeRegister
{
	//validate
	KeychainItemWrapper * cardsWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"cardsTest" accessGroup:nil];
    NSString *decodedString = [cardsWrapper objectForKey:(__bridge id)(kSecValueData)];
    NSData *decodedData;
    
    decodedData= [NSData dataWithBase64EncodedString:decodedString];
    NSMutableArray * cards = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    if (!cards) {
        cards = [[NSMutableArray alloc]init];
    }
    
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   // Object
									   card.cardNumber, @"cardNumber",
									   card.expirationYear, @"expirationYear",
									   card.expirationMonth, @"expirationMonth",
									   card.nameOnCard, @"cardHolderName",
									   card.cardType, @"cardType",
									   card.cvc, @"CVNCode",
									   card.HouseNumber, @"houseNumber",
									   card.PostCode, @"postCode",
									   card.StreetName, @"streetName",
									   card.issueNumber, @"issueNumber",
									   card.Token, @"Token",
									   nil];
	[cards addObject:dictionary];
	
	NSString *encodedString= [[NSKeyedArchiver archivedDataWithRootObject:cards] base64EncodedString];
	[cardsWrapper setObject:encodedString forKey:(__bridge id)(kSecValueData)];

	[Delegate registeredSuccessfully];
}

#pragma mark - WebView delegate

- (BOOL)webView:(UIWebView *)webViews shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	[self checkValidation];
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webViews
{
	timer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timeOutError) userInfo:nil repeats:NO];
	[self checkValidation];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViews
{
	[timer invalidate];
	timer = nil;
	[self checkValidation];
}

- (void)webView:(UIWebView *)webViews didFailLoadWithError:(NSError *)error
{
	[self checkValidation];
}

- (void)timeOutError
{
	[self initWebView];
	timer = nil;
	[Delegate didTimeOutProblem];
}

- (void)checkValidation
{
	NSString * token = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('token-p').innerHTML"];
	if (!token || [token isEqualToString:@""]) {
		[self handleError];
	}
	else if ([token hasPrefix:@"token: undefined"])
	{
		[Delegate didFailToGetTokenWithErrorDescription:@"Unknown Error!\nPlease check your card information and try again."];
		[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('token-p'').innerHTML ="""];
		
		[self initWebView];
	}
	else{
		[Delegate didDuccessfullyGetToken:token];
		card.Token = token;
	}
}

- (void)handleError
{
	NSString * result = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('payment-errors').innerHTML"];
	
	if (result && ![result isEqualToString:@""]) {
		[Delegate didFailToGetTokenWithErrorDescription:[result stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"]];
		[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('payment-errors').innerHTML = """];
	}
	
	//	[self initWebView];
}

- (void)dissmiss
{
	[timer invalidate];
	timer = nil;
	webView = nil;
}

@end

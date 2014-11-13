
//  CardsViewController.m
//  AirCash
//
//  Created by Younes Nouri Soltan on 23/12/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CardManageViewController.h"
#import "CardDetailsViewController.h"
#import "AddCardViewController.h"

#import <QuartzCore/QuartzCore.h>



@interface CardManageViewController ()

@property(strong, nonatomic)UIBarButtonItem *buttonSetting;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation CardManageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.buttonSetting = [[UIBarButtonItem alloc] initWithTitle:@"Add Card" style:UIBarButtonItemStylePlain target:self action:@selector(insertCard)];
						  
    self.navigationItem.rightBarButtonItem = self.buttonSetting;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

    self.tableView.delegate = self;
    self.tableView.userInteractionEnabled=YES;
}

-(IBAction)insertCard{
	UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
	
	AddCardViewController * addCardViewController = [storyboard instantiateViewControllerWithIdentifier:@"AddCardNavigationController"];
//
	[self presentViewController:addCardViewController animated:YES completion:nil];
	return;
	// prevent duplications
    if (!self.view1 && !self.view2) {
        
        [super insetCard];

    }
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    [self.tableView reloadData];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [super cards].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CardCell";
    UITableViewCell *cell ;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CardCell"];
    // Configure the cell...
    
    [self configureCell:cell atIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellEditingStyleDelete;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width, cell.frame.size.height - 10)];
	[view setBackgroundColor:[UIColor whiteColor]];
    [cell addSubview:view];
	[cell sendSubviewToBack:view];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   //add code here for when you hit delete
   
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    _cardDetailsViewController = [story instantiateViewControllerWithIdentifier:@"CarDetailsVC"];
    self.cardDetailsViewController.cards = super.cards;
    self.cardDetailsViewController.index = indexPath.row ;
    [self.navigationController  pushViewController:_cardDetailsViewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0.0;
    height = 72;
    return height;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *card = [super.cards objectAtIndex:indexPath.row ];
    UIImage *image = [UIImage imageNamed:@"Button1.png"];
    UIColor *color = [UIColor colorWithPatternImage:image];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 2, 300, 72)];
    view.backgroundColor = [UIColor clearColor];
    view.backgroundColor = color;
    
    UILabel *cardNo = [[UILabel alloc]initWithFrame:CGRectMake(100, 18, 120, 30)];
    UIImage *imageCard;
    
    if ([[card valueForKey:@"cardType"] isEqualToString:@"VISA"]) {
        
        imageCard = [UIImage imageNamed:@"Visa4.png"];
        
    } else if ([[card valueForKey:@"cardType"] isEqualToString:@"MC"]) {
        
        imageCard = [UIImage imageNamed:@"MasterCard33.png"];
        
    } else if ([[card valueForKey:@"cardType"] isEqualToString:@"JCB"]) {
        
        imageCard = [UIImage imageNamed:@"JCBCard.jpeg"];
        
    } else if ([[card valueForKey:@"cardType"] isEqualToString:@"AX"]) {
        
        imageCard = [UIImage imageNamed:@"American-Express4.png"];
        
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 60, 40)];
    imageView.image = imageCard;
    NSString *cardString = [[card valueForKey:@"cardNumber"]substringFromIndex:12];
    cardString = [@"************" stringByAppendingString:cardString];
    cardNo.text = cardString;
    cardNo.backgroundColor = [UIColor clearColor];
    
    [view addSubview:cardNo];
    [view addSubview:imageView];
    
    [cell addSubview:view];
    
}

-(IBAction)dismiss:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)Done:(id)sender{
    
    [super Done:nil];
    [self.tableView reloadData];
}

@end

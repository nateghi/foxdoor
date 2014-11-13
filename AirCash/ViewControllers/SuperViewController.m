//
//  SuperViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "SuperViewController.h"

@interface SuperViewController ()

@end

@implementation SuperViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"statusBar"] forBarMetrics:UIBarMetricsDefault];
	UIImageView * logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_navbar"]];
	[self.navigationController.navigationBar addSubview:logo];
	[logo setCenter:CGPointMake(self.view.center.x, logo.center.y)];

	UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	[imageView setImage:[UIImage imageNamed:@"BackGround"]];
    [self.view addSubview:imageView];
	[self.view sendSubviewToBack:imageView];
	[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
	self.navigationController.navigationBar.topItem.title = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

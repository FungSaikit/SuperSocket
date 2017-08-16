//
//  Consumption.h
//  SuperSocket
//
//  Created by fungjack on 2017/2/21.
//  Copyright © 2017年 fungjack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Consumption : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSURLSessionDelegate>

@property UIAlertController *loginAlert;
@property NSMutableArray *socketArray;
@property NSMutableArray *consumptionArray;
@property (strong, nonatomic) IBOutlet UINavigationItem *topBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)reloadButton:(id)sender;
- (IBAction)clickToUserInfo:(id)sender;

-(void)viewDidLoad;
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)didReceiveMemoryWarning;

@end

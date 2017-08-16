//
//  Control.h
//  SuperSocket
//
//  Created by fungjack on 2016/10/3.
//  Copyright © 2016年 fungjack. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Control : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate, UITextFieldDelegate>

@property NSMutableArray *ControlArray;
@property NSString *UID;
@property NSString *Token;
@property UITextField *socketNameText;
@property UITextField *socketNumberText;
@property UIAlertController *loginAlert;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)addSocketButton:(id)sender;
- (IBAction)updateSwitchAtIndexPath:(id)sender;
- (IBAction)clickToUserInfo:(id)sender;
- (IBAction)clickToAddSocketAlert:(id)sender;



- (void)viewDidLoad;
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;//返回表格的项目数
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didReceiveMemoryWarning;



@end

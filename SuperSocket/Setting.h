//
//  Setting.h
//  SuperSocket
//
//  Created by fungjack on 2016/10/3.
//  Copyright © 2016年 fungjack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Setting : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    NSArray *recipes;
    NSInteger a;
}

@property UIAlertController *loginAlert;
@property UIAlertController *softwareAlert;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(void)viewDidLoad;
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
-(void)didReceiveMemoryWarning;

@end

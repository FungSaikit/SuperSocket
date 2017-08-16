//
//  Timer.h
//  SuperSocket
//
//  Created by fungjack on 2016/10/3.
//  Copyright © 2016年 fungjack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Timer : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSURLSessionDelegate>
{
    NSArray *recipes501;
    NSMutableArray *selectWeekArray;
}

@property NSMutableArray *timersArray;
@property UITextField *nameTextField;
@property UITextField *numberTextField;
@property UILabel *setLabel;
@property UISwitch *statusSwitch;
@property UIDatePicker *datePicker;
@property UITableView *weekTableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property UIAlertController *loginAlert;
@property NSNumber *setStatus;

-(void)viewDidLoad;

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)didReceiveMemoryWarning;
- (IBAction)clickToUserInfo:(id)sender;
- (IBAction)clickToAddPlan:(id)sender;


@end

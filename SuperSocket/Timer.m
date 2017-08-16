//
//  Timer.m
//  SuperSocket
//
//  Created by fungjack on 2016/10/3.
//  Copyright © 2016年 fungjack. All rights reserved.
//

/*
    定时信息存储文件名：timerPlist.plist
    socketName:NSString
    socketNumber:NSString
    setStatus:NSNumber
    setTime:NSString
    setDate:NSArray
    jobKeyName:NSString
    jobKeyGroup:NSString
    
 */


#import "Timer.h"

@implementation Timer

#pragma mark - viewController协议
- (void)viewDidLoad {
    [super viewDidLoad];
    [self readFromFile];//填充timersArray数组
    recipes501 = [NSArray arrayWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    _tableView.separatorInset = UIEdgeInsetsZero;
}

- (void)viewWillAppear:(BOOL)animated{
    [self readFromFile];
    _tableView.separatorInset = UIEdgeInsetsZero;
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self saveToFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self saveToFile];
}



#pragma mark - tableView协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView.tag == 501){
        return [recipes501 count];
    }else{
        return [_timersArray count];
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 501) {
        NSString *tableIdentifier = @"TabelCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
        }
        cell.textLabel.text = [recipes501 objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor clearColor];
        cell.separatorInset = UIEdgeInsetsZero;
        if ([[selectWeekArray objectAtIndex:indexPath.row] integerValue] == 1) {//如果该行被选择了，就打勾
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else if([[selectWeekArray objectAtIndex:indexPath.row] integerValue] == 0){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }else{
        NSString *tableIdentifier = @"SimpleTableCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableIdentifier];
        }
        cell.textLabel.text = [[_timersArray objectAtIndex:indexPath.row] objectForKey:@"socketName"];
        
        //副标题包括 状态 时间 日期
        NSMutableString *detailString = [[NSMutableString alloc] init];
        if ([[[_timersArray objectAtIndex:indexPath.row] objectForKey:@"setStatus"] integerValue] == 0) {
            [detailString appendString:@"关 "];
        }else if ([[[_timersArray objectAtIndex:indexPath.row] objectForKey:@"setStatus"] integerValue] == 1){
            [detailString appendString:@"开 "];
        }
        [detailString appendString:[NSString stringWithFormat:@"%@ ", [[_timersArray objectAtIndex: indexPath.row] objectForKey:@"setTime"]]];
        for (int i = 0; i<=6; i++) {
            if ([[[[_timersArray objectAtIndex:indexPath.row] objectForKey:@"setDate"] objectAtIndex:i] integerValue] == 1) {
                if (i == 0) {
                    [detailString appendString:@"日"];
                }else if(i == 1){
                    [detailString appendString:@"一"];
                }else if(i == 2){
                    [detailString appendString:@"二"];
                }else if(i == 3){
                    [detailString appendString:@"三"];
                }else if(i == 4){
                    [detailString appendString:@"四"];
                }else if(i == 5){
                    [detailString appendString:@"五"];
                }else if(i == 6){
                    [detailString appendString:@"六"];
                }
            }
        }
        cell.detailTextLabel.text = detailString;
        cell.detailTextLabel.textColor = [UIColor grayColor];
//        cell.separatorInset = UIEdgeInsetsZero;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 501) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([[selectWeekArray objectAtIndex:indexPath.row] integerValue] == 0) {
            selectWeekArray[indexPath.row] = @1;
        }else if([[selectWeekArray objectAtIndex:indexPath.row] integerValue] == 1){
            selectWeekArray[indexPath.row] = @0;
        }
        [tableView reloadData];
        
        
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 501) {
        return NO;
    }else{
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag != 501) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            //向服务器发送删除请求
            
            [_timersArray removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }
    }
    [self saveToFile];
}







#pragma mark - 添加计划的方法

- (IBAction)clickToAddPlan:(id)sender {
    //先将week数组清零
    selectWeekArray = [NSMutableArray arrayWithObjects:@0, @0, @0, @0, @0, @0, @0, nil];
    _setStatus = [[NSNumber alloc] initWithInt:0];
    
    UIAlertController *selectTimeAlert = [UIAlertController alertControllerWithTitle:@"请设定定时器\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    

    //设定定时页面设计
   _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 55, 260, 30)];
    _nameTextField.placeholder = @"设备名称";
    _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    _nameTextField.delegate = self;
    _nameTextField.returnKeyType = UIReturnKeyContinue;
    [selectTimeAlert.view addSubview:_nameTextField];
    
    _numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 90, 260, 30)];
    _numberTextField.placeholder = @"设备编号";
    _numberTextField.borderStyle = UITextBorderStyleRoundedRect;
    _numberTextField.delegate = self;
    _numberTextField.returnKeyType = UIReturnKeyContinue;
    [selectTimeAlert.view addSubview:_numberTextField];
    
    _setLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 125, 180, 30)];
    _setLabel.text = @"将此设备设置为：关";
    [selectTimeAlert.view addSubview:_setLabel];
    
    _statusSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(210, 125, 50, 20)];
    [_statusSwitch addTarget:self action:@selector(setStatus:) forControlEvents:UIControlEventValueChanged];
    [selectTimeAlert.view addSubview:_statusSwitch];
    
    _weekTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 160, 110, 220) style:UITableViewStylePlain];
    _weekTableView.backgroundColor = [UIColor clearColor];
    _weekTableView.tag = 501;
    _weekTableView.delegate = self;
    _weekTableView.dataSource = self;
    _weekTableView.rowHeight = 30;
    _weekTableView.scrollEnabled = NO;
    _weekTableView.separatorInset = UIEdgeInsetsZero;
    [selectTimeAlert.view addSubview:_weekTableView];

    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(120, 160, 140, 220)];
    _datePicker.datePickerMode = UIDatePickerModeTime;
    [selectTimeAlert.view addSubview:_datePicker];
    //设定按钮点击事件
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"设定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        NSDateFormatter *newTime = [[NSDateFormatter alloc] init];
        newTime.dateFormat = @"HH:mm";
        [self startConnectWithSocketID:_numberTextField.text andControl:[NSNumber numberWithBool:[_statusSwitch isOn]] andTime:[newTime stringFromDate:_datePicker.date] andDays:selectWeekArray];
    }];
    [selectTimeAlert addAction:okButton];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [selectTimeAlert addAction:cancelButton];
    
    [self presentViewController:selectTimeAlert animated:YES completion:nil];
}

- (void)setStatus:(id)sender{//设置文字显示
    UISwitch *Switcher = (UISwitch *)sender;
    if (Switcher.isOn) {
        _setLabel.text = @"将此设备设置为：开";
        _setStatus = @1;
    }else{
        _setLabel.text = @"将此设备设置为：关";
        _setStatus = @0;
    }
}

- (void)startConnectWithSocketID:(NSString *)socketID andControl:(NSNumber *)Control andTime:(NSString *)Time andDays:(NSMutableArray *)Days{
    NSString *hour = [[Time componentsSeparatedByString:@":"] firstObject];
    NSString *minute = [[Time componentsSeparatedByString:@":"] lastObject];
    BOOL isDayLoop;
    if([Days[0] integerValue]==1 && [Days[1] integerValue]==1 && [Days[2] integerValue]==1 && [Days[3] integerValue]==1 && [Days[4] integerValue]==1 && [Days[5] integerValue]==1 && [Days[6] integerValue]==1){
        isDayLoop = YES;
    }else{
        isDayLoop = NO;
    }
    
    //以下是网络请求
    NSString *urlString = [NSString stringWithFormat:@"http://47.93.57.54:8080/ssm_school_project/user/setTimerTask"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 2.0;
    request.HTTPMethod = @"POST";
    NSString *bodyString = [NSString stringWithFormat:@"socketId=%@&&control=%ld&&hour=%@&&minute=%@&&second=0&&isDayLoop=%d&&isWeekLoop=1&&one=%ld&&two=%ld&&three=%ld&&four=%ld&&five=%ld&&six=%ld&&seven=%ld", socketID, (long)[Control integerValue], hour, minute, isDayLoop, (long)[Days[1] integerValue], (long)[Days[2] integerValue],(long)[Days[3] integerValue],(long)[Days[4] integerValue],(long)[Days[5] integerValue],(long)[Days[6] integerValue],(long)[Days[0] integerValue]];
    NSLog(@"HTTPBody = %@", bodyString);
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];//添加httpbody
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //解析数据
        if (data!=nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if([[dict valueForKey:@"code"] integerValue] == 200){
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"dict = %@", dict);
                //此处添加数据持久化代码
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                [newDict setValue:_nameTextField.text forKey:@"socketName"];
                [newDict setValue:_numberTextField.text forKey:@"socketNumber"];
                [newDict setValue:_setStatus forKey:@"setStatus"];
                NSDateFormatter *newTime = [[NSDateFormatter alloc] init];
                newTime.dateFormat = @"HH:mm";
                [newDict setValue:[newTime stringFromDate:_datePicker.date]  forKey:@"setTime"];
                [newDict setValue:selectWeekArray forKey:@"setDate"];
                [newDict setValue:[[dict objectForKey:@"jobKey"] objectForKey:@"name"] forKey:@"jobKeyName"];
                [newDict setValue:[[dict objectForKey:@"jobKey"] objectForKey:@"group"] forKey:@"jobKeyGroup"];
                [_timersArray addObject:newDict];
                NSLog(@"%@", newDict);
                NSLog(@"%@", _timersArray);
                [self saveToFile];
                [_tableView reloadData];
                UIAlertController *resultAlert = [UIAlertController alertControllerWithTitle:@"结果" message:@"设置成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [resultAlert addAction:okButton];
                [self presentViewController:resultAlert animated:YES completion:nil];
                
                
                
            }else{
                UIAlertController *resultAlert = [UIAlertController alertControllerWithTitle:@"结果" message:@"设置失败！服务器无响应，请检查网络" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [resultAlert addAction:okButton];
                [self presentViewController:resultAlert animated:YES completion:nil];
            }
        }
    }];
    [dataTask resume];

    
    
    
}


#pragma mark - TextField代理方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 文件处理方法

- (void)saveToFile{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [path stringByAppendingString:@"/timerPlist.plist"];
    [_timersArray writeToFile:filePath atomically:YES];
}

- (void)readFromFile{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray firstObject];
    NSString *filePath = [path stringByAppendingString:@"/timerPlist.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        _timersArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    }else{
        //NSLog(@"文件不存在");
        _timersArray = [[NSMutableArray alloc] init];
    }
}

#pragma mark - 注册登陆账号方法
- (IBAction)clickToUserInfo:(id)sender {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray firstObject];
    NSString *filePath = [path stringByAppendingString:@"/userPlist.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //如果文件存在
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];//读取文件
        if ([dict objectForKey:@"userName"]) {
            //弹出用户信息
            [self goToUserInfoAlert];
        }
        else{//如果objectForKey没有东西
            //弹出登录注册窗口
            [self goToLoginAlert];
        }
    }else{//如果文件不存在
        //弹出登录注册窗口
        [self goToLoginAlert];
        
    }
}

- (void)goToLoginAlert{//显示login的AlertController
    _loginAlert = [UIAlertController alertControllerWithTitle:@"登录\n\n\n" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UITextField *userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 55, 260, 30)];
    userNameTextField.placeholder = @"请输入账号";
    userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    userNameTextField.delegate = self;
    [_loginAlert.view addSubview:userNameTextField];
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 90, 260, 30)];
    passwordTextField.placeholder = @"请输入密码";
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    passwordTextField.delegate = self;
    passwordTextField.secureTextEntry = YES;
    [_loginAlert.view addSubview:passwordTextField];
    
    UIAlertAction *loginButton = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (userNameTextField.text.length!=0&&passwordTextField.text.length!=0) {
            //如果未登陆，在此处登陆
            NSString *urlString = [NSString stringWithFormat:@"http://47.93.57.54:8080/ssm_school_project/user/login"];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.timeoutInterval = 2.0;
            request.HTTPMethod = @"POST";
            NSString *loginString = [NSString stringWithFormat:@"username=%@&password=%@", userNameTextField.text, passwordTextField.text];
            request.HTTPBody = [loginString dataUsingEncoding:NSUTF8StringEncoding];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //解析数据
                if (data != nil) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    NSLog(@"%@", dict);
                    if([[dict objectForKey:@"code"] integerValue] == 200){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //主线程更新ui
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:@"登陆成功！" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                            [alert addAction:okButton];
                            [self presentViewController:alert animated:YES completion:nil];
                            //登录数据保存到本地
                            NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc] init];
                            [userInfoDict setObject:userNameTextField.text forKey:@"userName"];
                            [userInfoDict setObject:passwordTextField.text forKey:@"password"];
                            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *path = [pathArray firstObject];
                            NSString *filePath = [path stringByAppendingString:@"/userPlist.plist"];
                            [userInfoDict writeToFile:filePath atomically:YES];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //主线程更新ui
                            
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:@"登陆失败，请检查登陆信息是否正确！" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [self presentViewController:_loginAlert animated:YES completion:nil];
                            }];
                            [alert addAction:okButton];
                            [self presentViewController:alert animated:YES completion:nil];
                            
                        });
                    }
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:@"登陆失败，请检查网络！" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self presentViewController:_loginAlert animated:YES completion:nil];
                    }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
            [dataTask resume];
            
        }else{//如果账号或密码为空
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"未填写账号或密码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                [self presentViewController:_loginAlert animated:YES completion:nil];
            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    [_loginAlert addAction:loginButton];
    
    UIAlertAction *registerButton = [UIAlertAction actionWithTitle:@"注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //插入注册代码
        [self goToRegisterAlert];
    }];
    [_loginAlert addAction:registerButton];
    [self presentViewController:_loginAlert animated:YES completion:nil];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [_loginAlert addAction:cancelButton];
}

- (void)goToRegisterAlert{//显示register的AlertController
    UIAlertController *registerAlert = [UIAlertController alertControllerWithTitle:@"注册\n\n\n\n\n\n" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UITextField *userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 55, 260, 30)];
    userNameTextField.placeholder = @"请输入用户名";
    userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    userNameTextField.delegate = self;
    [registerAlert.view addSubview:userNameTextField];
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 90, 260, 30)];
    passwordTextField.placeholder = @"请输入密码";
    passwordTextField.secureTextEntry = YES;
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    passwordTextField.delegate = self;
    [registerAlert.view addSubview:passwordTextField];
    
    UITextField *comfirmPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 125, 260, 30)];
    comfirmPasswordTextField.placeholder = @"请再次确认密码";
    comfirmPasswordTextField.secureTextEntry = YES;
    comfirmPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    comfirmPasswordTextField.delegate = self;
    [registerAlert.view addSubview:comfirmPasswordTextField];
    
    UITextField *phoneNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 160, 260, 30)];
    phoneNumberTextField.placeholder = @"请输入认证手机";
    phoneNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
    phoneNumberTextField.delegate = self;
    [registerAlert.view addSubview:phoneNumberTextField];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *resultAlert;
        if (userNameTextField.text.length==0||passwordTextField.text.length==0||comfirmPasswordTextField.text.length==0||phoneNumberTextField.text.length==0) {
            resultAlert = [UIAlertController alertControllerWithTitle:@"错误" message:@"请完成以上所有信息" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *backButton = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self presentViewController:registerAlert animated:YES completion:nil];
            }];
            [resultAlert addAction:backButton];
        }else if (![passwordTextField.text isEqualToString:comfirmPasswordTextField.text]){
            resultAlert = [UIAlertController alertControllerWithTitle:@"错误" message:@"两次密码输入不一致" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *backButton = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self presentViewController:registerAlert animated:YES completion:nil];
            }];
            [resultAlert addAction:backButton];
        }else{
            //网络传输注册代码！
            NSString *urlString = [NSString stringWithFormat:@"http://47.93.57.54:8080/ssm_school_project/user/register"];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.timeoutInterval = 2.0;
            request.HTTPMethod = @"POST";
            NSString *registerString = [NSString stringWithFormat:@"username=%@&password=%@&phonenumber=%@", userNameTextField.text, passwordTextField.text, phoneNumberTextField.text];
            request.HTTPBody = [registerString dataUsingEncoding:NSUTF8StringEncoding];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //解析注册返回的数据
                NSLog(@"data = %@", data);
                if(data != nil){
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    NSLog(@"dict = %@", dict);
                    if([[dict objectForKey:@"code"] integerValue] == 200){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //主线程更新ui
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:@"注册成功！" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                            [alert addAction:okButton];
                            [self presentViewController:alert animated:YES completion:nil];
                        });
                    }else if([[dict objectForKey:@"code"] integerValue] == 1){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:@"注册失败，该用户名已被注册！" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [self presentViewController:registerAlert animated:YES completion:nil];
                            }];
                            [alert addAction:okButton];
                            [self presentViewController:alert animated:YES completion:nil];
                        });
                    }else if([[dict objectForKey:@"code"] integerValue] == 2){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:@"注册失败，手机号不符合规格！" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [self presentViewController:registerAlert animated:YES completion:nil];
                            }];
                            [alert addAction:okButton];
                            [self presentViewController:alert animated:YES completion:nil];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:@"注册失败，未知错误！" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [self presentViewController:registerAlert animated:YES completion:nil];
                            }];
                            [alert addAction:okButton];
                            [self presentViewController:alert animated:YES completion:nil];
                        });
                    }
                }else if(data == nil){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:@"网络错误！" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self presentViewController:registerAlert animated:YES completion:nil];
                        }];
                        [alert addAction:okButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                }
            }];
            [dataTask resume];
        }
        //[self presentViewController:resultAlert animated:YES completion:nil];
    }];
    [registerAlert addAction:okButton];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentViewController:_loginAlert animated:YES completion:nil];
    }];
    [registerAlert addAction:cancelButton];
    
    [self presentViewController:registerAlert animated:YES completion:nil];
}

- (void)goToUserInfoAlert{//显示用户信息的AlertController
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray firstObject];
    NSString *filePath = [path stringByAppendingString:@"/userPlist.plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    NSString *userInfoString = [NSString stringWithFormat:@"我的账号：%@", [dict objectForKey:@"userName"]];
    UIAlertController *userInfoAlert = [UIAlertController alertControllerWithTitle:@"用户信息\n\n\n\n\n" message: userInfoString preferredStyle:UIAlertControllerStyleAlert];
    UIView *userIconView = [[UIView alloc] initWithFrame:CGRectMake(90, 55, 90, 90)];
    userIconView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UserIcon"]];
    [userInfoAlert.view addSubview:userIconView];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:nil];
    [userInfoAlert addAction:okButton];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"注销" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //注销，将userPlist里内容清空
        NSMutableDictionary *nullDict = [[NSMutableDictionary alloc] init];
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [pathArray firstObject];
        NSString *filePath = [path stringByAppendingString:@"/userPlist.plist"];
        [nullDict writeToFile:filePath atomically:YES];
        
    }];
    [userInfoAlert addAction:logoutAction];
    [self presentViewController:userInfoAlert animated:YES completion:nil];
}

@end

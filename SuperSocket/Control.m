//
//  Control.m
//  SuperSocket
//
//  Created by fungjack on 2016/10/3.
//  Copyright © 2016年 fungjack. All rights reserved.
//

/*
 用户信息存储文件文件名：userPlist.plist
 userName:NSString
 password:NSString
 插座信息保存文件文件名：controlPlist.plist
 socketName:NSString
 socketNumber:NSString
 socketStatus:NSNumber
 */

#import "Control.h"

@implementation Control

#pragma mark - 文件处理

- (void)readFromFile{
    //NSLog(@"执行读取文件方法");
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray firstObject];
    NSString *filePath = [path stringByAppendingString:@"/controlPlist.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {//如果文件存在
        _ControlArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    }
    else{
        //NSLog(@"文件不存在");
        _ControlArray = [[NSMutableArray alloc] init];
    }
}

- (void)saveToFile{
    //NSLog(@"执行保存到文件方法");
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray firstObject];
    NSString *filePath = [path stringByAppendingString:@"/controlPlist.plist"];
    [_ControlArray writeToFile:filePath atomically:YES];
}

- (BOOL)doUserLogin{
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [pathArray firstObject];
        NSString *filePath = [path stringByAppendingString:@"/userPlist.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            //如果文件存在
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];//读取文件
            if ([dict objectForKey:@"userName"]) {
                return YES;
            }
            else{//如果objectForKey没有东西
                return NO;
            }
        }else{//如果文件不存在
            return NO;
        }
}

#pragma mark - 点击事件

- (IBAction)clickToAddSocketAlert:(id)sender {
    UIAlertController *addSocketAlert = [UIAlertController alertControllerWithTitle:@"添加新的设备\n\n\n" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    _socketNameText = [[UITextField alloc] initWithFrame:CGRectMake(5, 55, 260, 30)];
    _socketNameText.placeholder = @"请指定一个设备名称";
    _socketNameText.borderStyle = UITextBorderStyleRoundedRect;
    _socketNameText.delegate = self;
    _socketNameText.returnKeyType = UIReturnKeyContinue;
    [addSocketAlert.view addSubview:_socketNameText];
    
    _socketNumberText = [[UITextField alloc] initWithFrame:CGRectMake(5, 90, 260, 30)];
    _socketNumberText.placeholder = @"请输入设备编号";
    _socketNumberText.borderStyle = UITextBorderStyleRoundedRect;
    _socketNumberText.delegate = self;
    _socketNumberText.returnKeyType = UIReturnKeyContinue;
    [addSocketAlert.view addSubview:_socketNumberText];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [addSocketAlert addAction:cancelButton];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //此处是确定按钮点击时事件
        NSLog(@"%@ %@", _socketNameText.text, _socketNumberText.text);
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        if (_socketNameText.text.length!=0 && _socketNumberText.text.length!=0) {
            [newDict setValue:_socketNameText.text forKey:@"socketName"];
            [newDict setValue:_socketNumberText.text forKey:@"socketNumber"];
            [newDict setValue:@0 forKey:@"socketStatus"];
            [_ControlArray addObject:newDict];//将新增插座参数添加到控制数组中
            [self saveToFile];
            
            UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"结果" message:@"添加成功" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [confirmAlert addAction:okButton];
            [self presentViewController:confirmAlert animated:YES completion:nil];
            [self.tableView reloadData];
            
        }else{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"错误" message:@"输入不能为空" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *errorComfirmButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self presentViewController:addSocketAlert animated:YES completion:nil];
                [self presentViewController:errorAlert animated:YES completion:nil];
            }];
            [errorAlert addAction:errorComfirmButton];
            [self presentViewController:errorAlert animated:YES completion:nil];
        }
    }];
    [addSocketAlert addAction:okButton];
    
    [self presentViewController:addSocketAlert animated:YES completion:nil];
    
}

- (IBAction)addSocketButton:(id)sender {//点击添加按钮
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    if (_socketNameText.text.length!=0 && _socketNumberText.text.length!=0) {
        [newDict setValue:_socketNameText.text forKey:@"socketName"];
        [newDict setValue:_socketNumberText.text forKey:@"socketNumber"];
        [newDict setValue:@0 forKey:@"socketStatus"];
        [_ControlArray addObject:newDict];//将新增插座参数添加到控制数组中
        [self saveToFile];
        
        UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"结果" message:@"添加成功" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [confirmAlert addAction:okButton];
        [self presentViewController:confirmAlert animated:YES completion:nil];
    }
}
- (IBAction)updateSwitchAtIndexPath:(id)sender{//cellSwitch点击事件，获取真正行数需要tag-500
    UISwitch *cellSwitch = (UISwitch *)sender;
    
    if ([cellSwitch isOn]) {//如果cellSwitch被打开了
        NSLog(@"Row %ld Switch is on", cellSwitch.tag);
        [[_ControlArray objectAtIndex:(cellSwitch.tag - 500)] setValue:@1 forKey:@"socketStatus"];
        [self startConnectWithSocketNumber:[[_ControlArray objectAtIndex:cellSwitch.tag - 500] objectForKey:@"socketNumber"]  andStatus:@"1"];
    }
    else{
        NSLog(@"Row %ld Switch is off", cellSwitch.tag);
        [[_ControlArray objectAtIndex:(cellSwitch.tag - 500)] setValue:@0 forKey:@"socketStatus"];
        //向服务器的请求关闭开关
        [self startConnectWithSocketNumber:[[_ControlArray objectAtIndex:cellSwitch.tag - 500] objectForKey:@"socketNumber"] andStatus:@"0"];
    }
    [self saveToFile];//保存修改后的状态
}



#pragma mark - ViewControl协议方法

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{//每当视图出现时从文件中刷新一次
    _tableView.separatorInset = UIEdgeInsetsZero;
    [self readFromFile];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self saveToFile];
}

- (void)didReceiveMemoryWarning{//当内存不足发出警告时执行保存_controlArray到plist
    [super didReceiveMemoryWarning];
    
    [self saveToFile];
}




#pragma mark - TableView协议方法

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
    return [_ControlArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{//为单元格添加数据
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[_ControlArray objectAtIndex:indexPath.row] objectForKey:@"socketName"];
    cell.detailTextLabel.text = [[_ControlArray objectAtIndex:indexPath.row] objectForKey:@"socketNumber"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加小右箭头
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    //添加Switch
    UISwitch *cellSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    cellSwitch.tag = indexPath.row + 500;//tag加500防止冲突
    [cellSwitch addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
    
    //修改Switch的状态
    if ([[[_ControlArray objectAtIndex:indexPath.row] objectForKey:@"socketStatus"] integerValue] == 1) {//如果status状态为1，则为开
        [cellSwitch setOn:YES];
    }else [cellSwitch setOn:NO];
    
    cell.accessoryView = cellSwitch;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;//可以编辑单元格
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{//滑动可以删除单元格
    //如果点击的editingstyle是删除
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_ControlArray removeObjectAtIndex:indexPath.row];//删除相应下标的数组
        [tableView reloadData];//重新载入数据
    }
    //写入沙盒
    [self saveToFile];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //单元格点击事件
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//点击单元格时不选定单元格
}

#pragma mark - 网络请求

- (void)startConnectWithSocketNumber: (NSString *)socketNumber andStatus: (NSString *)status{
    if([self doUserLogin]){
    NSString *urlString = [NSString stringWithFormat:@"http://47.93.57.54:8080/ssm_school_project/user/postSocketId"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 2.0;
    request.HTTPMethod = @"POST";
    NSString *bodyString = [NSString stringWithFormat:@"socketId=%@&&control=%@", socketNumber, status];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];//添加httpbody
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //解析插座控制服务器返回数据
        if(data == nil){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:@"设置失败！服务器无响应，请检查网络" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    [dataTask resume];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请先登录" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - 登陆相关
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




#pragma mark - TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}



@end

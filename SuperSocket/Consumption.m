//
//  Consumption.m
//  SuperSocket
//
//  Created by fungjack on 2017/2/21.
//  Copyright © 2017年 fungjack. All rights reserved.
//

#import "Consumption.h"

@implementation Consumption

#pragma mark - viewController协议


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blueColor]];
    _tableView.separatorInset = UIEdgeInsetsZero;
}

-(void)viewWillAppear:(BOOL)animated{
    _tableView.separatorInset = UIEdgeInsetsZero;
    [self readFromFile];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - tableView协议

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
    return [_socketArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = [[_socketArray objectAtIndex:indexPath.row] objectForKey:@"socketName"];
    if ([_consumptionArray count] != 0) {
        cell.detailTextLabel.text = [_consumptionArray objectAtIndex:indexPath.row];
    }else{
        cell.detailTextLabel.text = @"0";
    }

    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}






#pragma mark - 数据获取方法
- (void)readFromFile{
    _socketArray = [[NSMutableArray alloc] init];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [path stringByAppendingString:@"/controlPlist.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        _socketArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    }
}

#pragma mark - 点击事件
- (IBAction)reloadButton:(id)sender {
    [self readFromFile];
    [self getConsumption];
    [_tableView reloadData];
}

#pragma mark - 登录注册账号
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

#pragma mark - TextField代理方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 获取插座功耗方法
-(void)getConsumption{
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.102:8080/ssm_school_project/user/queryDevicePower"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 2.0;
    request.HTTPMethod = @"POST";
    
    for (int i = 0; i < [_socketArray count]; i++) {
        NSString *bodyString = [NSString stringWithFormat:@"socketId=%@", [_socketArray[i] objectForKey:@"socketNumber"]];
        request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //解析数据
            if(data != nil){
                if ([[data valueForKey:@"msg"] isEqualToString:@"error"]) {//如果获取信息错误
                    _consumptionArray[i] = @"0";
                }else{
                    _consumptionArray[i] = [data valueForKey:@"msg"];
                }
            }else{
                _consumptionArray[i] = @"0";
            }
            if (i == [_socketArray count]-1) {
                [_tableView reloadData];
            }
        }];
        [dataTask resume];
    }
}

@end

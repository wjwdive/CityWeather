//
//  ViewController.m
//  WJWMyApp
//
//  Created by infosys on 2017/8/18.
//  Copyright © 2017年 wjwdive. All rights reserved.
//

#import "ViewController.h"
#import "XMLReader.h"

 NSString *baseUrl = @"http://www.webxml.com.cn/WebServices/WeatherWebService.asmx/getWeatherbyCityName?theCityName=";
 NSString *httpVersion = @" HTTP/1.1";


@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *weatherTF;
@property (strong, nonatomic) IBOutlet UILabel *weatherResultLabel;
@property (strong, nonatomic) UILabel *wLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.weatherTF addTarget:self action:@selector(textWeatherTFChange:) forControlEvents:UIControlEventEditingChanged];
    
    _wLabel = [[UILabel alloc] init];
    
    [self.view addSubview:_wLabel];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
//    设置成NO表示当前控件响应后会传播到其他空间上，默认为YES
    tapGestureRecognizer.cancelsTouchesInView = NO;
}

- (void)textWeatherTFChange:(UITextField *)textFiled{
    if ([textFiled isEqual: self.weatherTF]) {
        NSLog(@"输入的城市为：%@",textFiled.text);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (void)keyboardHide:(UITapGestureRecognizer *)tap {
    [_weatherTF resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getCities:(id)sender {
    NSString *sUrl = [NSString stringWithFormat:@"%@%@",baseUrl,_weatherTF.text];
//    NSString *sUrl = [NSString stringWithFormat:@"%@",@"www.webxml.com.cn/WebServices/WeatherWebService.asmx/getWeatherbyCityName?theCityName=%E4%B8%8A%E6%B5%B7"];

//  NSURL *url = [NSURL URLWithString:@"www.webxml.com.cn/WebServices/WeatherWebService.asmx/getWeatherbyCityName?theCityName=%E4%B8%8A%E6%B5%B7"];
    NSLog(@" sUrl %@", sUrl);

    NSCharacterSet *allowCharaters = [NSCharacterSet URLQueryAllowedCharacterSet];
    sUrl = [sUrl stringByAddingPercentEncodingWithAllowedCharacters:allowCharaters];
    NSLog(@" sUrl encoded %@", sUrl);

    

    NSURL *url = [NSURL URLWithString:sUrl];
    NSLog(@" url encoded %@", url);

//    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        解析服务器返回的数据
        NSString *resultDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"服务器返回 data %@ dataStr %@", data, resultDataStr);
//        默认在子线程中解析数据
        NSLog(@"%@", [NSThread currentThread]);
        dispatch_sync(dispatch_get_main_queue(), ^{
            _wLabel.backgroundColor = [UIColor greenColor];
            _wLabel.font = [UIFont systemFontOfSize:14.0];
            CGSize size = [_wLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_wLabel.font,NSFontAttributeName, nil]];
            CGFloat wLabelContentWith = size.width;
            if (wLabelContentWith >= 150) {
                wLabelContentWith = 150.0;
            }
             CGSize size2 = CGSizeMake(200, MAXFLOAT);
            NSString *str = [self dictionaryToJson:[self parseXmlToDict:resultDataStr]];
            CGRect rect2 = [str boundingRectWithSize:size2
                                             options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:_wLabel.font,NSFontAttributeName, nil]
                                             context:nil];//方法2，计算大小，但是会根据size2来限制
            CGFloat label2_H = rect2.size.height;
            _wLabel.frame = CGRectMake(50, 100, size2.width, label2_H);
//            _wLabel.frame = CGRectMake(0, 200, wLabelContentWith, 600);
//            _wLabel.text = @"hello";
            _wLabel.adjustsFontSizeToFitWidth=YES;
            _wLabel.minimumScaleFactor=0.5;
            _wLabel.numberOfLines = 0;
            _wLabel.text = [self dictionaryToJson:[self parseXmlToDict:resultDataStr]];
            
            NSLog(@"wLabel.text %@",self.wLabel.text);
//            _weatherResultLabel.text = [self dictionaryToJson:[self parseXmlToDict:resultDataStr]];
        });
        NSLog(@"error %@:",error);
        NSLog(@"response %@",response);
    
    }];
//    发送请求
    [dataTask resume];
    
    
}

//解析xml 为 dictionary
- (NSDictionary *)parseXmlToDict:(NSString*)xmlString {
    NSError *parseError = nil;
    return [XMLReader dictionaryForXMLString:xmlString error:&parseError];;
}

//字典 转 json
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField  {
    [textField resignFirstResponder];
    return YES;
}




























@end

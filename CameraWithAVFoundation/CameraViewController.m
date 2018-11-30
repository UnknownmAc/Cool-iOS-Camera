//
//  CameraViewController.m
//  CameraWithAVFoundation
//
//  Created by Gabriel Alvarado on 4/16/14.
//  Copyright (c) 2014 Gabriel Alvarado. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraSessionView.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "FileUtil.h"
#import "CameraWithAVFoundation-Swift.h"


@interface CameraViewController () <CACameraSessionDelegate>

@property (nonatomic, strong) CameraSessionView *cameraView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (IBAction)launchCamera:(id)sender {
    
    //Set white status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    //Instantiate the camera view & assign its frame
    _cameraView = [[CameraSessionView alloc] initWithFrame:self.view.frame];
    
    //Set the camera view's delegate and add it as a subview
    _cameraView.delegate = self;
    
    //Apply animation effect to present the camera view
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.6];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[_cameraView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    
    [self.view addSubview:_cameraView];
    
    //____________________________Example Customization____________________________
    //[_cameraView setTopBarColor:[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha: 0.64]];
    //[_cameraView hideFlashButton]; //On iPad flash is not present, hence it wont appear.
    //[_cameraView hideCameraToggleButton];
    //[_cameraView hideDismissButton];
}

-(void)didCaptureImage:(UIImage *)image {
    NSLog(@"CAPTURED IMAGE");
    ThumbViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EmotionThumbVC"];
    [vc HandleImageDataWithImage:image];
    [self.navigationController pushViewController:vc animated:YES];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [self.cameraView removeFromSuperview];
    
    //Save the image to device temp location and get the path.
    NSString *path = [FileUtil saveImageTODocumentAndGetPath:image];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
    
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    //[requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"content-type"];
    [requestSerializer setValue:@"x-analyzer-id" forHTTPHeaderField:@"classifier:mona3:expression"];
    [requestSerializer setValue:@"x-api-key" forHTTPHeaderField:@"AdobeSenseiPredictServiceStageKey"];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
    
    manager.securityPolicy.validatesDomainName = NO;
    
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:@"https://sensei-stage-ew1.adobe.io/predict/mona-expression/v1/predict" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileURL:fileURL name:@"content" fileName:@"file.jpg" mimeType:@"image/jpeg" error:nil];
        
        NSData *fileNameconvertedToUTF8data = [@"file.jpg" dataUsingEncoding:NSUTF8StringEncoding];
        
        [formData appendPartWithFormData:fileNameconvertedToUTF8data name:@"content"];
        //[formData appendPartWithFormData:@"{}" name:@"properties"];
        //[formData appendPartWithFormData:objectData name:@"contentAnalyzerRequests"];
        
    } error:nil];
    
    [request setTimeoutInterval:10000];
    
    NSURLSessionUploadTask *uploadTask;
    
    
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          NSLog(@"show progress here...");
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Throw if there is any Error: %@", error);
                      } else {
                          NSString *responseMessage = [NSString stringWithUTF8String:[responseObject bytes]];
                          
                          UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"File Upload" message:responseMessage preferredStyle: UIAlertControllerStyleAlert];
                          
                          UIAlertAction *action = [UIAlertAction actionWithTitle:@"OKK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                              //anything to do...
                              NSLog(@"ok button pressed...");
                          }];
                          
                          [controller addAction:action];
                          
                          [self presentViewController:controller animated:YES completion:nil];
                      }
                  }];
    
    [uploadTask resume];

    
#if 0
    //Save the image to device temp location and get the path.
    NSString *path = [FileUtil saveImageTODocumentAndGetPath:image];
    //NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
    
    //NSDictionary *params = @{
    //                         @"file":path,
      //                       @"contentAnalyzerRequests" : @"{\"requests\":[{\"analyzer_id\":\"Feature:EmotionMonaChain:84af1950-aa0d-4558-ba36-94bfea189937\"}]}"
        //                     };
    
    NSDictionary *params = @{
                                @"content":path,
                                @"properties":@"{}"
                            };
    
    //NSURL *url = [NSURL URLWithString:@"https://sensei.adobe.io/sensei-core/v1/predict"];
    NSURL *url = [NSURL URLWithString:@"https://sensei-stage-ew1.adobe.io/predict/mona-expression/v1/predict"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //request.HTTPMethod = @"POST";
    [request setHTTPMethod:@"POST"];
    //request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:NULL];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:NULL]];
    
    NSData *jsonArray = [NSJSONSerialization dataWithJSONObject:params options:0 error:NULL];
    
//    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"Cache-Control" forHTTPHeaderField:@"no-cache"];
//    [request setValue:@"x-api-key" forHTTPHeaderField:@"AdobeSenseiPredictServiceProdKey"];
    [request addValue:@"x-api-key" forHTTPHeaderField:@"AdobeSenseiPredictServiceStageKey"];
    [request addValue:@"x-analyzer-id" forHTTPHeaderField:@"classifier:mona3:expression"];
    //[request addValue:[NSString stringWithFormat:@"%d", [jsonArray length]] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Throw if there is any Error: %@", error);
        } else {
            NSLog(@"dataAsString %@", [NSString stringWithUTF8String:[data bytes]]);
        }
    }] resume];
#endif
 
#if 0
    //NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSString* path = @"https://sensei.adobe.io/sensei-core/v1/predict";
    NSArray* array = @[
                       // Request parameters
                       @"contentAnalyzerRequests={ \"requests\":[ { \"analyzer_id\":\"Feature:EmotionMonaChain:84af1950-aa0d-4558-ba36-94bfea189937\"}]}"
                       ];
    
    NSString* string = [array componentsJoinedByString:@"&"];
    path = [path stringByAppendingFormat:@"?%@", string];
    
    NSLog(@"%@", path);
    
    NSString *path1 = [FileUtil saveImageTODocumentAndGetPath:image];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path1];
    NSString* body = @"file=" ;
    
    NSMutableURLRequest* _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [_request setHTTPMethod:@"POST"];
    // Request headers
    [_request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [_request setValue:@"AdobeSenseiPredictServiceProdKey" forHTTPHeaderField:@"x-api-key"];
    // Request body
    [_request setHTTPBody:[@"{body}" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData* _connectionData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
    
    if (nil != error)
    {
        NSLog(@"Error: %@", error);
    }
    else
    {
        NSError* error = nil;
        NSMutableDictionary* json = nil;
        NSString* dataString = [[NSString alloc] initWithData:_connectionData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", dataString);
        
        if (nil != _connectionData)
        {
            json = [NSJSONSerialization JSONObjectWithData:_connectionData options:NSJSONReadingMutableContainers error:&error];
        }
        
        if (error || !json)
        {
            NSLog(@"Could not parse loaded json with error:%@", error);
        }
        
        NSLog(@"%@", json);
        _connectionData = nil;
    }
    
    //[pool drain];
#endif
    
#if 0
    //Save the image to device temp location and get the path.
    NSString *path = [FileUtil saveImageTODocumentAndGetPath:image];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
    
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"content-type"];
    [requestSerializer setValue:@"Cache-Control" forHTTPHeaderField:@"no-cache"];
    [requestSerializer setValue:@"x-api-key" forHTTPHeaderField:@"AdobeSenseiPredictServiceProdKey"];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
    
    manager.securityPolicy.validatesDomainName = NO;
    
    NSArray* objectArray = @[
                       // Request parameters
                       @"contentAnalyzerRequests={ \"requests\":[ { \"analyzer_id\":\"Feature:EmotionMonaChain:84af1950-aa0d-4558-ba36-94bfea189937\"}]}"
                       ];
    //NSData *objectData = [@"{\"requests\":[{\"analyzer_id\":\"Feature:EmotionMonaChain:84af1950-aa0d-4558-ba36-94bfea189937\"}]}" dataUsingEncoding:NSUTF16StringEncoding];
    //let jsonResponse = try JSONSerialization.jsonObject(with: objectData!, options: .mutableContainers);
    //NSError *e = nil;
    //NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: objectData options: NSJSONReadingMutableContainers error: &e];
    
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:@"https://sensei.adobe.io/sensei-core/v1/predict" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileURL:fileURL name:@"file" fileName:@"file.jpg" mimeType:@"image/jpeg" error:nil];
        
        //NSData *fileNameconvertedToUTF8data = [@"my_file_name.jpg" dataUsingEncoding:NSUTF8StringEncoding];
        
        //[formData appendPartWithFormData:fileNameconvertedToUTF8data name:@"file"];
        //[formData appendPartWithFormData:objectData name:@"contentAnalyzerRequests"];
        
    } error:nil];
    
    [request setTimeoutInterval:10000];
    
    NSURLSessionUploadTask *uploadTask;
    
    
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          NSLog(@"show progress here...");
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Throw if there is any Error: %@", error);
                      } else {
                          NSString *responseMessage = [NSString stringWithUTF8String:[responseObject bytes]];
                          
                          UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"File Upload" message:responseMessage preferredStyle: UIAlertControllerStyleAlert];
                          
                          UIAlertAction *action = [UIAlertAction actionWithTitle:@"OKK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                              //anything to do...
                              NSLog(@"ok button pressed...");
                          }];
                          
                          [controller addAction:action];
                          
                          [self presentViewController:controller animated:YES completion:nil];
                      }
                  }];
    
    [uploadTask resume];
#endif
}

-(void)didCaptureImageWithData:(NSData *)imageData {
    NSLog(@"CAPTURED IMAGE DATA");
 
#if 0
    static bool flag = false;
    
    UIImage *tempImage = [UIImage imageWithData:imageData scale: 0.1];
    NSData *imgData = UIImagePNGRepresentation(tempImage);
    
    //Save the image to device temp location and get the path.
    NSString *path = [FileUtil saveImageTODocumentAndGetPath:tempImage];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
    
    
    if(!flag) {
        flag = true;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"Cache-Control" forHTTPHeaderField:@"no-cache"];
    [manager.requestSerializer setValue:@"x-api-key" forHTTPHeaderField:@"AdobeSenseiPredictServiceProdKey"];
    
    NSError *error;
    NSData *objectData = [@"{\"requests\":[{\"analyzer_id\":\"Feature:EmotionMonaChain:84af1950-aa0d-4558-ba36-94bfea189937\"}]}" dataUsingEncoding:NSUTF16StringEncoding];
   

    NSDictionary *parameters;// = [NSJSONSerialization JSONObjectWithData:objectData
                                   //                 options:NSJSONReadingMutableContainers
                                     //               error:&error];
    
    NSString *urlString = [[NSString alloc] initWithData:imgData encoding:NSUTF16StringEncoding]; // Or any other appropriate encoding
    NSString* webStringURL = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    //NSURL* filePath = [NSURL URLWithString:webStringURL];
    //NSURL *filePath = [[NSURL alloc] initWithString:webStringURL];

    [manager POST:@"https://sensei.adobe.io/sensei-core/v1/predict" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //[formData appendPartWithFileURL:filePath name:@"file" error:nil];
        //[formData appendPartWithFileData:imageData name:@"file" fileName:@"temp.jpeg" mimeType:@"image/jpeg"];
        [formData appendPartWithFileURL:fileURL name:@"file" fileName:@"file.jpg" mimeType:@"image/jpeg" error:nil];
        [formData appendPartWithFormData:objectData name:@"contentAnalyzerRequests"];
        //[formData appendPartWithFormData:imageData name:@"file"];
    } progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    }
    flag = true;
#endif
    
#if 0
    
    NSError *error;
    NSString *urlString = @"https://sensei.adobe.io/sensei-core/v1/predict";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPMethod:@"POST"];
    
    [request setURL:url];
    
    [request addValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"Cache-Control" forHTTPHeaderField:@"no-cache"];
    [request addValue:@"x-api-key" forHTTPHeaderField:@"AdobeSenseiPredictServiceProdKey"];
    
    NSString *contentData = @"\"-F\" , \"contentAnalyzerRequests={\n \"requests\":[\n{\n \"analyzer_id\":\"Feature:EmotionMonaChain:84af1950-aa0d-4558-ba36-94bfea189937\"\n }\n ]\n";
   
    NSString* dataFormatString = @"data:image/png;base64,%@";
    NSString* dataString = [NSString stringWithFormat:dataFormatString, [imageData base64EncodedStringWithOptions:0]];
    NSURL* dataURL = [NSURL URLWithString:dataString];
    NSString* fileData = @"\"-F\" , \"file=@";
    NSString *contentURL = [fileData stringByAppendingString:dataURL.absoluteString];
    
    NSMutableData *postData = [[NSMutableData alloc] init];
    [postData appendData:[[NSString stringWithFormat:contentData] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:contentURL] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postData];
    
    NSData *finalDataToDisplay = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    NSMutableDictionary *abc = [NSJSONSerialization JSONObjectWithData: finalDataToDisplay
                                                               options: NSJSONReadingMutableContainers
                                
                                                                 error: &error];
    NSLog(@"%@",abc);
#endif
    //UIImage *image = [[UIImage alloc] initWithData:imageData];
    //UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //[self.cameraView removeFromSuperview];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //Show error alert if image could not be saved
    if (error) [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

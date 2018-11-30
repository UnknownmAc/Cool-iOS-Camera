//
//  FileUtil.h
//  AfNetowrkExample
//
//  Created by Zumry Gapstars on 2/21/17.
//  Copyright © 2017 Appsgit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileUtil : NSObject

+(BOOL) fileExistsInProject:(NSString *)fileName;

+(NSString*) saveImageTODocumentAndGetPath: (UIImage *) image;

@end

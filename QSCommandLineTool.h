//
//  QSCommandLineTool.h
//  QSCommandLineTool
//
//  Created by Nicholas Jitkoff on 7/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#define kToolIsInstalled @"QSCommandLineToolInstalled"
#import "QSCommandLineToolProtocol.h"

@interface QSCommandLineTool : NSObject <QSCommandLineTool> {
    NSConnection *commandLineConnection;
}

+ (id)sharedInstance;

- (void)checkForTool;
- (void)startToolConnection;

@end


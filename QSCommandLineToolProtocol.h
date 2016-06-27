//
//  QSCommandLineToolProtocol.h
//  QSCommandLineTool
//
//  Created by Patrick Robertson on 21/05/2013.
//
//

@protocol QSCommandLineTool <NSObject>
- (void)handleArguments:(NSArray *)array input:(NSData *)input directory:(NSString *)directory;
- (NSString *)usageText;
@end

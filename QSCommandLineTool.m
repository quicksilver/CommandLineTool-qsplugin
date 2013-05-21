//
//  QSCommandLineTool.m
//  QSCommandLineTool
//
//  Created by Nicholas Jitkoff on 7/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSCommandLineTool.h"
#import "QSCLStartupDialogWindowController.h"

@implementation QSCommandLineTool


+ (void)loadPlugIn{
	[[self sharedInstance]checkForTool];
	return ;	
}


+ (id)sharedInstance{
    static QSCommandLineTool *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
    }
    return _sharedInstance;
}

- (void)checkForTool
{
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *currentPath = [[NSBundle bundleForClass:[self class]]pathForResource:@"qs" ofType:@""];
	NSString *installedPath = @"/usr/bin/qs";
	if ([manager fileExistsAtPath:installedPath] && [manager contentsEqualAtPath:currentPath andPath:installedPath]) {
		[self performSelectorOnMainThread:@selector(startToolConnection) withObject:nil waitUntilDone:NO];
	} else {
        NSString *statusText = [manager fileExistsAtPath:installedPath] ? NSLocalizedStringFromTableInBundle(@"The command line tool was not found. It can be installed from the Command Line Tool preferences window.", nil, [NSBundle bundleForClass:[self class]], @"Message displayed when the command line tool is not installed") : NSLocalizedStringFromTableInBundle(@"The command line tool is out of date. It can be updated from the Command Line Tool preferences window.", nil, [NSBundle bundleForClass:[self class]], @"Message displayed when the command line tool is out of date");
		QSCLStartupDialogWindowController *wc = [[QSCLStartupDialogWindowController alloc] initWithStatus:statusText];
        
        [wc showWindow:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kToolIsInstalled];
	}
}

- (void)startToolConnection{
	if (commandLineConnection) return;
	commandLineConnection=[NSConnection new];
	[commandLineConnection registerName:@"Quicksilver Command Line Tool"];
	[commandLineConnection setRootObject:self];
}


- (BOOL)putOnShelfFromPasteboard:(NSPasteboard *)pboard{
	[[NSApp delegate]putOnShelfFromPasteboard:pboard];
	return YES;
}

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard{
	[[NSApp delegate]readSelectionFromPasteboard:pboard];
	return YES;
}

- (void)handleArguments:(NSArray *)arguments input:(NSData *)input directory:(NSString *)directory{
//	if (DEBUG) 
//		NSLog(@"recieved: %@\rArguments:%@\rInput:%@\rPath:%@\r",self,[arguments description],input,directory);
	
	
	NSString *options=nil;
	if([arguments count] > 1) {
		options= [arguments objectAtIndex:1];
    }
	NSUInteger firstFilename=0;
	
	QSObject *object=nil;
	if ([options hasPrefix:@"-"]){
		firstFilename=1;
	}
	
	if (input){
		NSString *string=[[[NSString alloc]initWithData:input encoding:NSUTF8StringEncoding] autorelease];
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		object=[QSObject objectWithString:string];
    } else if (![arguments containsObject:@"-b"]) {
		NSMutableArray *filenames=[NSMutableArray array];
        NSMutableArray *stringobjs = [NSMutableArray array];
		NSFileManager *manager=[NSFileManager defaultManager];
		//NSLog(currentPath);
		for (NSUInteger i=firstFilename;i<[arguments count];i++){
			NSString *currentString=[[arguments objectAtIndex:i] stringByStandardizingPath];
            NSString *fileString = currentString;
			if (![currentString hasPrefix:@"/"])
				fileString = [[directory stringByAppendingPathComponent:currentString]stringByStandardizingPath];
			if ([manager fileExistsAtPath:fileString isDirectory:nil]) {
				[filenames addObject:fileString];
            } else {
                // treat it as a string instead
                [stringobjs addObject:[QSObject objectWithString:currentString]];
            }
		}
		//NSLog(@"%@",filenames);
        if ([stringobjs count]) {
            if ([filenames count]) {
                object= [QSObject objectByMergingObjects:stringobjs withObject:[QSObject objectByMergingObjects:[QSObject fileObjectsWithPathArray:filenames]]];
            } else {
                object = [QSObject objectByMergingObjects:stringobjs];
            }
        } else {
            object = [QSObject fileObjectWithArray:filenames];
        }
	}
	
	
	if ([options isEqualToString:@"-s"]){
		[[QSReg getClassInstance:@"QSShelfController"] addObject:object atIndex:0];
	}else{
        QSInterfaceController *controller = [QSReg preferredCommandInterface];
        [controller clearObjectView:[controller dSelector]];
        [controller selectObject:object];
        [controller activate:self];
	}
}




- (NSString *)usageText{
	NSString *usageFile=[[NSBundle bundleForClass:[self class]]pathForResource:@"qs-usage" ofType:@"txt"];
    NSError *err = nil;
	NSMutableString *usageText=[NSMutableString stringWithContentsOfFile:usageFile usedEncoding:nil error:&err];
    if (err != nil) {
        NSLog(@"Error loading command line tool usage text: %@",err);
    }
	
	
	//[usageText appendFormat:@"\nTriggers: %@",[[NSArray array]description]];
	
	return usageText;
}
@end

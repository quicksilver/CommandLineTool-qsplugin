//
//  QSCommandLineTool.m
//  QSCommandLineTool
//
//  Created by Nicholas Jitkoff on 7/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSCommandLineTool.h"

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
	} else if ([[NSUserDefaults standardUserDefaults] boolForKey:kToolIsInstalled]) {
		// TODO this prevents the menubar icon from appearing until the next clean launch
		NSRunInformationalAlertPanel([NSString stringWithFormat:@"Tool is missing", nil], @"The command line tool was not found, or is out of date. It can be reinstalled from the general preferences window.", @"OK", nil, nil);
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
	if([arguments count]>1)
		options=[arguments objectAtIndex:1];
	int firstFilename=1;
	
	QSObject *object=nil;
	if ([options hasPrefix:@"-"]){
		firstFilename=2;
	}
	
	if (input){
		NSString *string=[[[NSString alloc]initWithData:input encoding:NSUTF8StringEncoding] autorelease];
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		object=[QSObject objectWithString:string];
	}else{
		NSUInteger i;
		NSMutableArray *filenames=[NSMutableArray arrayWithCapacity:[arguments count]-1];
		NSFileManager *manager=[NSFileManager defaultManager];
		//NSLog(currentPath);
		for (i=firstFilename;i<[arguments count];i++){
			NSString *currentFile=[[arguments objectAtIndex:i]stringByStandardizingPath];
			if (![currentFile hasPrefix:@"/"])
				currentFile=[[directory stringByAppendingPathComponent:currentFile]stringByStandardizingPath];
			if ([manager fileExistsAtPath:currentFile isDirectory:nil])
				[filenames addObject:currentFile];
		} 
		//NSLog(@"%@",filenames);
		object=[QSObject fileObjectWithArray:filenames];
	}
	
	
	if ([options isEqualToString:@"-s"]){
		[[QSReg getClassInstance:@"QSShelfController"] addObject:object atIndex:0];
	}else{
		if (object){
			QSInterfaceController *controller = [QSReg preferredCommandInterface];
			[controller clearObjectView:[controller dSelector]];
			[controller selectObject:object];
			[controller activate:self];
		}		
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

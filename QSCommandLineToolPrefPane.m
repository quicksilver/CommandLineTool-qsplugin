

#import "QSCommandLineToolPrefPane.h"
#import "QSCommandLineTool.h"

#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>


@implementation QSCommandLineToolPrefPane

@synthesize toolCanBeInstalled;

- (id)init {
    self = [super initWithBundle:[NSBundle bundleForClass:[QSCommandLineToolPrefPane class]]];
    if (self) {
		[self setToolCanBeInstalled:YES];
    }
    return self;
}

- (NSImage *) paneIcon{
	return [QSResourceManager imageNamed:@"ExecutableBinaryIcon"];
}

- (NSString *) paneName{
	return @"CL Tool";
}

- (NSString *) paneDescription{
	return @"Configure the Command Line Tool";
}


- (NSString *) mainNibName{
	return @"QSCommandLineToolPrefPane";
}

- (void)mainViewDidLoad{
	[self populateFields];
	[toolImageView setImage:[self paneIcon]];
    [super mainViewDidLoad];
}

- (void) populateFields{
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *currentPath = [[NSBundle bundleForClass:[self class]]pathForResource:@"qs" ofType:@""];
	NSString *installedPath = @"/usr/local/bin/qs";
    NSString *status = [NSString stringWithFormat:@"Installed: %@", installedPath];
	if ([manager fileExistsAtPath:installedPath]) {
		if ([manager contentsEqualAtPath:currentPath andPath:installedPath]) {
			[toolInstallStatus setStringValue:status];
			[self setToolCanBeInstalled:NO];
		} else {
			[toolInstallStatus setStringValue:@"Out of Date"];
		}
	} else {
        status = [NSString stringWithFormat:@"Not Installed: %@", installedPath];
		[toolInstallStatus setStringValue:status];
	}
}


- (void)setValueForSender:(id)sender{
	if (sender==toolInstallButton){
		[self installCommandLineTool:self];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kToolIsInstalled];
		[[QSCommandLineTool sharedInstance]startToolConnection];
		[self populateFields];
	}	
}

- (IBAction)installCommandLineTool:(id)sender
{
    NSString *installPath = @"/usr/local/bin";
    NSString *toolName = @"qs";
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *toolPath = [[NSBundle bundleForClass:[self class]] pathForResource:toolName ofType:@""];
    if ([manager isWritableFileAtPath:installPath]) {
        NSString *qstool = [installPath stringByAppendingPathComponent:toolName];
        [manager copyItemAtPath:toolPath toPath:qstool error:nil];
        return;
    }

    OSStatus myStatus;
    AuthorizationFlags myFlags = kAuthorizationFlagDefaults;
    AuthorizationRef myAuthorizationRef;
    myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, myFlags, &myAuthorizationRef);
    if (myStatus != errAuthorizationSuccess) {
        return;
    }
    
    do {
        AuthorizationItem myItems = {kAuthorizationRightExecute, 0, NULL, 0};
        AuthorizationRights myRights = {1, &myItems};
        myFlags = kAuthorizationFlagDefaults |
            kAuthorizationFlagInteractionAllowed |
            kAuthorizationFlagPreAuthorize |
            kAuthorizationFlagExtendRights;
        myStatus = AuthorizationCopyRights(myAuthorizationRef, &myRights, NULL, myFlags, NULL);
        
        if (myStatus != errAuthorizationSuccess) break;
        
        char *mkdirArgs[] = {"-p", (char *)[installPath UTF8String], NULL};
        AuthorizationExecuteWithPrivileges(myAuthorizationRef, "/bin/mkdir", kAuthorizationFlagDefaults, mkdirArgs, NULL);
        char *myArguments[] = {(char *)[toolPath UTF8String], (char *)[installPath UTF8String], NULL};
        char myReadBuffer[128];
        
        myFlags = kAuthorizationFlagDefaults;
        FILE *myCommunicationsPipe = NULL;
        myStatus = AuthorizationExecuteWithPrivileges(myAuthorizationRef, "/bin/cp", myFlags, myArguments, &myCommunicationsPipe);

        if (myStatus == errAuthorizationSuccess)
            for(;;)
            {
                ssize_t bytesRead = read (fileno (myCommunicationsPipe),
                                      myReadBuffer, sizeof (myReadBuffer));
                if (bytesRead < 1) break;
                write (fileno (stdout), myReadBuffer, bytesRead);
            }
    } while (0);
            
            AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);
            return;
}

@end




//
//
//NSPasteboard * pboard = [NSPasteboard pasteboardWithUniqueName];
//
//int fileArgs=1;
//BOOL putOnShelf=NO;
//if (argc>1 && !strcmp(argv[1],"-s")){
//	//NSLog(@"Object ");
//	fileArgs++;
//	putOnShelf=YES;
//}
//
////NSLog(@"pipe? %d %d",fileArgs,argc);
//if(argc <= fileArgs){
//	// NSLog(@"pipe");
//	NSFileHandle * fhandle = [NSFileHandle fileHandleWithStandardInput];
//	NSData * data = [fhandle readDataToEndOfFile];
//	[pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:data];
//	[pboard setData:data forType:NSStringPboardType];
//}else{
//	int i;
//	NSMutableArray *filenames=[NSMutableArray arrayWithCapacity:argc-1];
//	NSFileManager *manager=[NSFileManager defaultManager];
//	NSString *currentPath=[manager currentDirectoryPath];
//	//NSLog(currentPath);
//	for (i=1;i<argc;i++){
//		NSString *currentFile=[[NSString stringWithCString:argv[i]]stringByStandardizingPath];
//		if (![currentFile hasPrefix:@"/"])
//			currentFile=[currentPath stringByAppendingPathComponent:currentFile];
//		if ([manager fileExistsAtPath:currentFile isDirectory:nil])
//			[filenames addObject:currentFile];
//	}       
//	if ([filenames count]){
//		[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
//		[pboard setPropertyList:filenames forType:NSFilenamesPboardType];
//	}
//}   
//
//[proxy setProtocolForProxy:@protocol(QSCommandLineTool)];
//
//if (putOnShelf) [proxy putOnShelfFromPasteboard:pboard];
//else [proxy readSelectionFromPasteboard:pboard];

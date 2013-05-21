#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "QSCommandLineToolProtocol.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    id proxy=[NSConnection rootProxyForConnectionWithRegisteredName:@"Quicksilver Command Line Tool" host:nil];
    if (proxy){
		[proxy setProtocolForProxy:@protocol(QSCommandLineTool)];
        
        NSArray *args = [[NSProcessInfo processInfo] arguments];
		// If help requested, print usage
		if ([args containsObject:@"-h"] || [args containsObject:@"-?"] || [args containsObject:@"--help"]) {
			NSString *usageText=[proxy usageText];
			fprintf(stderr,"%s\n",[usageText UTF8String]);
			return 0;
		}
		
		NSData *input=nil;
		
		// Get CWD
		NSFileManager *manager=[[NSFileManager alloc] init];
		NSString *directory= [manager currentDirectoryPath];
        NSLog(@"A");
		// If last argument begins with (or is a) dash, read stdin and provide
		if (argc == 1 || argv[argc-1][0] == '-')
		{
			//fprintf(stderr,"%s\r",[usageText UTF8String]);
			NSFileHandle * fhandle = [NSFileHandle fileHandleWithStandardInput];
			input = [fhandle readDataToEndOfFile];
		}

		// Send data to Quicksilver
		[proxy handleArguments:[args objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [args count]-1)]] input:input directory:directory];
		
    }else{	
		fprintf(stderr,"Unable to connect to Quicksilver\n");
		return 1;
    }    
    
    [pool release];
    return 0;
}

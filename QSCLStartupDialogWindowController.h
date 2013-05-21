//
//  QSCLStartupDialogWindowController.h
//  QSCommandLineTool
//
//  Created by Patrick Robertson on 21/05/2013.
//
//

#import <Cocoa/Cocoa.h>

@interface QSCLStartupDialogWindowController : NSWindowController {
    IBOutlet NSTextField *statusLabel;
    NSString *statusText;
}

- (id)initWithStatus:(NSString *) newStatus;
- (void)setStatusText;
- (IBAction)close:(id)sender;
- (IBAction)showPrefs:(id)sender;

@end

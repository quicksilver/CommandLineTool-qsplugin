//
//  QSCLStartupDialogWindowController.m
//  QSCommandLineTool
//
//  Created by Patrick Robertson on 21/05/2013.
//
//

#import "QSCLStartupDialogWindowController.h"

@interface QSCLStartupDialogWindowController ()

@end

@implementation QSCLStartupDialogWindowController


- (id)initWithStatus:(NSString *) newStatus
{
    self = [super initWithWindowNibName:@"QSCLStartupDialog"];
    if (self) {
        // Initialization code here.
        statusText = [newStatus retain];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [[self window] setIsVisible:NO];
    [[self window] setLevel:NSModalPanelWindowLevel];
    [self setStatusText];
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self autorelease];
}

- (void)setStatusText {
    if (statusLabel.stringValue != statusText) {
        statusLabel.stringValue = statusText;
        [statusText release];
    }
}

- (IBAction)showPrefs:(id)sender {
    // Hacky. Using [[NSWorkspace ...] openURL:...@"qs://QSCommandLineToolPrefPane"] doesn't quite work since it won't necessarily use the same copy of QS to show the prefs (if you have multiple installed)
    [[NSClassFromString(@"QSPreferencesController") sharedInstance] showPaneWithIdentifier:@"QSCommandLineToolPrefPane"];
    [self close];
}

- (IBAction)close:(id)sender {
    [self close];
}
@end

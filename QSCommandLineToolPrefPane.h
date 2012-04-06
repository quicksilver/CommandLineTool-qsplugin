#import <Foundation/Foundation.h>
#import <PreferencePanes/PreferencePanes.h>

@interface QSCommandLineToolPrefPane : QSPreferencePane {
    IBOutlet NSButton *toolInstallButton;
    IBOutlet NSTextField *toolInstallStatus;
    BOOL toolCanBeInstalled;
	
    IBOutlet NSImageView *toolImageView;
}
@property BOOL toolCanBeInstalled;

- (IBAction)installCommandLineTool:(id)sender;


- (void) populateFields;
- (void)setValueForSender:(id)sender;
@end

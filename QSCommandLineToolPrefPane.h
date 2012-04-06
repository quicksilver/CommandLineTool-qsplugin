#import <Foundation/Foundation.h>
#import <PreferencePanes/PreferencePanes.h>

@interface QSCommandLineToolPrefPane : QSPreferencePane {
    IBOutlet NSButton *toolInstallButton;
    IBOutlet NSTextField *toolInstallStatus;
	
    IBOutlet NSImageView *toolImageView;
}

- (IBAction)installCommandLineTool:(id)sender;


- (void) populateFields;
- (void)setValueForSender:(id)sender;
@end

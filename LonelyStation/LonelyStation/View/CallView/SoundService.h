
#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

//#import <AVFoundation/AVAudioPlayer.h>

@interface SoundService : NSObject

-(BOOL) playRingTone;
-(BOOL) stopRingTone;

-(BOOL) playRingBackTone;
-(BOOL) stopRingBackTone;

@end

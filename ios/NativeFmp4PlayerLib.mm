#import "Fmp4PlayerLib.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "NativeFmp4PlayerLib-Swift.h"

#import <Foundation/Foundation.h>
@implementation Fmp4PlayerLib {
  NativeFmp4PlayerLib *nativeFmp4Module;
}
RCT_EXPORT_MODULE(NativeFmp4PlayerLib)

- (instancetype)init {
  if (self = [super init]) {
    nativeFmp4Module = [[NativeFmp4PlayerLib alloc] init];  // Initialize in init method
  }
  return self;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeFmp4PlayerLibSpecJSI>(params);
}

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);

    return result;
}

- (void)startStreaming { 
  if (@available(iOS 16.0, *)) {
    [nativeFmp4Module startStreaming];
  } else {
    // Fallback on earlier versions
  }
}

- (void)stopStreaming { 
  [nativeFmp4Module stopStreaming];
}

@end

//
//  NDSEmulatorBridge.m
//  NDSDeltaCore
//
//  Created by Will Cobb on 8/23/17.
//  Copyright © 2017 Will Cobb. All rights reserved.
//

#import "NDSEmulatorBridge.h"
#import "NDSSoundDriver.h"

// DeSmuME
#include "emu.h"
#include "types.h"
#include "render3D.h"
#include "rasterize.h"
#include "SPU.h"
#include "debug.h"
#include "NDSSystem.h"
#include "path.h"
#include "slot1.h"
#include "saves.h"
#include "cheatSystem.h"
#include "slot1.h"
#include "version.h"
#include "metaspu.h"

#include <sys/time.h>

// DeltaCore
#import <NDSDeltaCore/NDSDeltaCore.h>
#import <NDSDeltaCore/NDSDeltaCore-Swift.h>

// Temp Types
typedef uint32_t u32;
typedef uint16_t u16;
typedef uint8_t u8;


int  emulating;

@interface NDSEmulatorBridge () {
    struct NDS_fw_config_data fw_config;
}

@property (nonatomic, copy, nullable, readwrite) NSURL *gameURL;

@property (assign, nonatomic, getter=isFrameReady) BOOL frameReady;

@property (strong, nonatomic, nonnull, readonly) NSMutableSet<NSNumber *> *activatedInputs;

@end

@implementation NDSEmulatorBridge
@synthesize audioRenderer = _audioRenderer;
@synthesize videoRenderer = _videoRenderer;
@synthesize saveUpdateHandler = _saveUpdateHandler;

+ (instancetype)sharedBridge
{
    static NDSEmulatorBridge *_emulatorBridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emulatorBridge = [[self alloc] init];
    });
    
    return _emulatorBridge;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _activatedInputs = [NSMutableSet set];
    }
    
    return self;
}

- (void)initWithLanguage:(int)lang
{
    NSLog(@"Initiating DeSmuME");
    
    path.ReadPathSettings();
    
    EMU_loadDefaultSettings();
    
    Desmume_InitOnce();
    NDS_FillDefaultFirmwareConfigData(&fw_config);
    
    INFO("Init NDS");
    
    NDS_Init();
    cur3DCore = 1;
    NDS_3D_ChangeCore(cur3DCore);
    
    //    LOG("Init sound core\n");
    //    SPU_ChangeSoundCore(SNDCORE_COREAUDIO, DESMUME_SAMPLE_RATE*8/60);
    //
    static const char* nickname = "Delta";
    fw_config.nickname_len = strlen(nickname);
    for(int i = 0 ; i < fw_config.nickname_len ; ++i) {
        fw_config.nickname[i] = nickname[i];
    }
    
    static const char* message = "Delta is the best!";
    fw_config.message_len = strlen(message);
    for(int i = 0 ; i < fw_config.message_len ; ++i) {
        fw_config.message[i] = message[i];
    }
    
    fw_config.language = lang < 0 ? NDS_FW_LANG_ENG : lang;
    fw_config.fav_colour = 15;
    fw_config.birth_month = 2;
    fw_config.birth_day = 17;
    fw_config.ds_type = NDS_CONSOLE_TYPE_LITE;
    fw_config.language = 1;
    
    //video.setfilter(video.NONE);
    NDS_CreateDummyFirmware(&fw_config);
}

#pragma mark - Emulation -

- (void)startWithGameURL:(NSURL *)URL
{
    [self initWithLanguage:-1];
    
    self.gameURL = URL;
    if (NDS_LoadROM(URL.relativePath.UTF8String) < 1) {
        assert(false);
        return;
    }
    //NDS_Reset();
    
    emulating = 1;
}

- (void)stop
{
    NDS_DeInit();

    emulating = 0;
}

- (void)pause
{
    emulating = 0;
}

- (void)resume
{
    emulating = 1;
}

- (void)readInputs
{
    u16 joypad = 0;
    NSLog(@"Inputs: %@", [NDSEmulatorBridge sharedBridge].activatedInputs);
    for (NSNumber *input in [NDSEmulatorBridge sharedBridge].activatedInputs.copy)
    {
        joypad |= [input unsignedIntegerValue];
    }
    printf("Joypad: %x\n", joypad);
    
    NDS_setPad(joypad & NDSGameInputRight,
               joypad & NDSGameInputLeft,
               joypad & NDSGameInputDown,
               joypad & NDSGameInputUp,
               joypad & NDSGameInputSelect,
               joypad & NDSGameInputStart,
               joypad & NDSGameInputB,
               joypad & NDSGameInputA,
               joypad & NDSGameInputY,
               joypad & NDSGameInputX,
               joypad & NDSGameInputL,
               joypad & NDSGameInputR,
               false,
               false);
    
    if (joypad & NDSGameInputTouch) {
        CGPoint touchPosition = CGPointApplyAffineTransform(self.HACK_touchPoint,
                                                            CGAffineTransformMakeScale(256/256,
                                                                                       192/192));
        EMU_touchScreenTouch(touchPosition.x * 256, touchPosition.y * 192);
    } else {
        EMU_touchScreenRelease();
    }
    
}

void systemDrawScreen();
- (void)runFrame
{
    [self readInputs];
    NDS_beginProcessingInput();
    NDS_endProcessingInput();
    
    NDS_exec<false>();
    //if (soundEnabled) SPU_Emulate_user(true);
    
    systemDrawScreen();
}

#pragma mark - Settings -

- (void)updateGameSettings
{
    
}

#pragma mark - Inputs -

- (void)activateInput:(NSInteger)gameInput
{    
    [self.activatedInputs addObject:@(gameInput)];
}

- (void)deactivateInput:(NSInteger)gameInput
{
    [self.activatedInputs removeObject:@(gameInput)];
}

- (void)resetInputs
{
    [self deactivateInput:NDSGameInputUp];
    [self deactivateInput:NDSGameInputDown];
    [self deactivateInput:NDSGameInputLeft];
    [self deactivateInput:NDSGameInputRight];
    [self deactivateInput:NDSGameInputA];
    [self deactivateInput:NDSGameInputB];
    [self deactivateInput:NDSGameInputX];
    [self deactivateInput:NDSGameInputY];
    [self deactivateInput:NDSGameInputL];
    [self deactivateInput:NDSGameInputR];
    [self deactivateInput:NDSGameInputStart];
    [self deactivateInput:NDSGameInputSelect];
}

#pragma mark - Game Saves -

- (void)saveGameSaveToURL:(NSURL *)URL
{
    
}

- (void)loadGameSaveFromURL:(NSURL *)URL
{
    
}

#pragma mark - Save States -

- (void)saveSaveStateToURL:(NSURL *)URL
{
    savestate_save(URL.fileSystemRepresentation);
}

- (void)loadSaveStateFromURL:(NSURL *)URL
{
    savestate_load(URL.fileSystemRepresentation);
}

#pragma mark - Cheats -

- (BOOL)addCheatCode:(NSString *)cheatCode type:(NSString *)type
{
    BOOL success = NO;
    
    if ([type isEqualToString:CheatTypeActionReplay] || [type isEqualToString:CheatTypeGameShark])
    {
        NSString *sanitizedCode = [cheatCode stringByReplacingOccurrencesOfString:@" " withString:@""];
        //success = cheatsAddGSACode([sanitizedCode UTF8String], "code", true);
    }
    else if ([type isEqualToString:CheatTypeCodeBreaker])
    {
        //success = cheatsAddCBACode([cheatCode UTF8String], "code");
    }
    
    return success;
}

- (void)resetCheats
{
    
}

- (void)updateCheats
{
    
}

@end

#pragma mark - Main

void systemDrawScreen()
{
    
    u8 *srcBuffer = (u8*)EMU_ABGR1555Buffer();
    
    
    dispatch_apply(384, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t y){
        
            memcpy([NDSEmulatorBridge sharedBridge].videoRenderer.videoBuffer + y * 256 * 4, srcBuffer + y * 256 * 4, 256 * 4);
        });
    
    [[NDSEmulatorBridge sharedBridge] setFrameReady:YES];
}



u32 systemGetClock()
{
    timeval time;
    
    gettimeofday(&time, NULL);
    
    double milliseconds = (time.tv_sec * 1000.0) + (time.tv_usec / 1000.0);
    return milliseconds;
}

//SoundDriver *systemSoundInit()
//{
//    //soundShutdown();
//    
//    auto driver = new NDSSoundDriver;
//    return driver;
//}


void log(const char *defaultMsg, ...)
{
    static FILE *out = NULL;
    
    if(out == NULL) {
        out = fopen("trace.log","w");
    }
    
    va_list valist;
    
    va_start(valist, defaultMsg);
    vfprintf(out, defaultMsg, valist);
    va_end(valist);
}

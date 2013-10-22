//
//  FileIO.h
//  MEMO2
//
//  Created by ZheJun on 09/09/26.
//  Copyright 2009 JinDi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileIO : NSObject {
	
	NSFileHandle *m_pFileHandle;
	NSString     *m_strFilePath;
}

-(id) initFileIO;

-(void) writeInt: (int) data_no: (int) value;
-(int)  readInt : (int) data_no;

-(void) writeBool:(int) position :(BOOL) valu;
-(BOOL) readBool :(int) position;

-(void)      writeString:(int) position :(NSString*) value;
-(NSString*) readString :(int) position :(int) length;

-(void) writeBytes:(int) position :(Byte*) value :(int) length;
-(void) readBytes :(int) position :(Byte*) dest :(int) length;

+(int) getNowDate:(int) type;

-(void) openFile:(BOOL) bRead;
-(void) closeFile;

@end

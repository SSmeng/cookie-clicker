/*
 *  server.h
 *  ConstaPad
 *
 *  Created by Artem Stepanenko on 8/10/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#define TEST_SERVER_HOST                @"test.p4rc.com:8080"

#define PRODUCTION_SERVER_HOST          @"www.p4rc.com"

#define USE_TEST                        1

#if USE_TEST
    #define DEFAULT_SERVER_HOST             TEST_SERVER_HOST

    #define DEFAULT_CURRENT_API_KEY         @"d1919f76-395e-4ef0-a7cb-4a31a79fcdd0"
    #define DEFAULT_GAME_ID                 @"TESTGAME001"
#else
    #define DEFAULT_SERVER_HOST             PRODUCTION_SERVER_HOST

    #define DEFAULT_CURRENT_API_KEY         @"d7cc1f18-c05c-4970-850b-c0467f12fd53"
    #define DEFAULT_GAME_ID                 @"ZS001"
#endif


#define DEFAULT_API_KEY                 @""

#define DEFAULT_SERVER_ADDRESS          (@"http://" DEFAULT_SERVER_HOST @"/")

#define TERMS_OF_USE_URL                @"http://test.p4rc.com:8080/termsofuse.html"

#define FRAMED_BROWSER_TIMEOUT          15
#define REQUEST_TIMEOUT                 60

//http://www.p4rc.com/termsofuse.html
//http://test.p4rc.com:8080/termsofuse.html
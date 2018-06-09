//
//  main.cpp
//  SyncExtensionCmd
//
//  Created by Jens Restemeier on 09.06.18.
//  Copyright © 2018 Jens Restemeier. All rights reserved.
//

#include <stdio.h>

#include <sys/xattr.h>
#include <sys/types.h>
#include <pwd.h>
#include <dirent.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>


int main(int argc, const char * argv[])
{
    struct passwd * pwuid = getpwuid(getuid());

    DIR * dir = opendir(pwuid->pw_dir);
    
    if (dir != NULL)
    {
        dirent * ent;
        while ((ent = readdir(dir)))
        {
            if (ent->d_name[0] != '.') {
            	printf("%s\n", ent->d_name);
                char filePath[1024];
                sprintf(filePath, "%s/%s", pwuid->pw_dir, ent->d_name);
                char value[1024];
                ssize_t length = getxattr(filePath, "com.apple.TextEncoding", value, sizeof(value), 0, 0);
                if (length > 0) {
                    printf("value: %s\n", value);
                }
                if (length < 0) {
                    char errbuf[1024];
                    strerror_r(errno, errbuf, sizeof(errbuf));
                    printf("error: %i %s\n", errno, errbuf);
                }
            }
        }
        closedir (dir);
    }
    return 0;
}

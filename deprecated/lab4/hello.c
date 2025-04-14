#include <stdio.h>
#include <sys/reboot.h>
#include <unistd.h>

int main()
{
    printf("Hello world!\n");
    sync(); // Synchronize the disks
    return reboot(RB_AUTOBOOT);
}

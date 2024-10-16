/*
 * clang -framework CoreGraphics -framework Foundation -framework Metal newbufnocopy.m -o newbufnocopy && ./newbufnocopy
 */

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <CoreGraphics/CoreGraphics.h>
#include <stdlib.h>  // For posix_memalign

int main(int argc, char** argv)
{
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    int length = 16;
    void *updateAddress;

    // Use posix_memalign to ensure memory alignment
    int alignment = 16;  // Metal usually requires at least 16-byte alignment
    int result = posix_memalign(&updateAddress, alignment, length);
    
    for (int i = 0; i < 4; i++) {
        ((int*)updateAddress)[i] = i;
    }

    // Create a Metal buffer with newBufferWithBytes
    id<MTLBuffer> device_buffer = [device newBufferWithBytes:updateAddress
                                                      length:length
                                                     options:0
                                                     deallocator:nil
    ];
    
    printf("Device buffer created\n");
    int device_buffer_length = (int)[device_buffer length];
    printf("Length: %d\n", device_buffer_length);
    
    int *data = (int*)[device_buffer contents];
    printf("Data pointer obtained\n");

    if (device_buffer_length == 0) {
        printf("Device buffer length is 0\n");
        free(updateAddress);
        return 0;
    }

    for (int i = 0; i < 4; i++) {
        printf("Device buffer[%d] = %d\n", i, data[i]);
    }
    
    free(updateAddress);
    return 0;
}

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
    if (!device) {
        printf("Metal is not supported on this device\n");
        return -1;
    }

    int length = 16;
    void *updateAddress;

    // Use posix_memalign to ensure memory alignment
    int alignment = 16;  // Metal usually requires at least 16-byte alignment
    int result = posix_memalign(&updateAddress, alignment, length);
    
    if (result != 0) {
        printf("Memory alignment failed with error: %d\n", result);
        return -1;
    }

    // Initialize the buffer with some test data
    for (int i = 0; i < 4; i++) {
        ((int*)updateAddress)[i] = i;
    }

    // Create a Metal buffer with newBufferWithBytes (this will copy the data)
    id<MTLBuffer> device_buffer = [device newBufferWithBytes:updateAddress
                                                      length:length
                                                     options:0];
    
    if (!device_buffer) {
        printf("Failed to create Metal buffer\n");
        free(updateAddress);
        return -1;
    }

    printf("Device buffer created\n");

    // Check the buffer length
    int device_buffer_length = (int)[device_buffer length];
    printf("Length: %d\n", device_buffer_length);
    
    // Check the contents of the buffer
    int *data = (int*)[device_buffer contents];
    printf("Data pointer obtained\n");

    if (device_buffer_length == 0) {
        printf("Device buffer length is 0\n");
        free(updateAddress);
        return 0;
    }

    // Print the contents of the buffer
    for (int i = 0; i < 4; i++) {
        printf("Device buffer[%d] = %d\n", i, data[i]);
    }

    // Free the aligned memory after usage
    free(updateAddress);

    return 0;
}

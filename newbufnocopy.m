/*
 * clang -framework CoreGraphics -framework Foundation -framework Metal newbufnocopy.m -o newbufnocopy && ./newbufnocopy
 */

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <CoreGraphics/CoreGraphics.h>

int main(int argc, char** argv)
{
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();

    int length = 16;


    void *updateAddress;
    kern_return_t err = vm_allocate((vm_map_t)mach_task_self(),
                                            (vm_address_t*)&updateAddress,
                                            length,
                                            VM_FLAGS_ANYWHERE);
    for (int i = 0; i < 4; i++) {
        ((int*)updateAddress)[i] = i;
    }
    assert(err == KERN_SUCCESS);
    id<MTLBuffer> device_buffer = [device newBufferWithBytesNoCopy:updateAddress
                                                            length:length
                                                           options:0
                                                       deallocator:nil
    ];
    printf("Device buffer created\n");
    int device_buffer_length = [device_buffer length];
    printf("Length: %d\n", device_buffer_length);
    int *data = [device_buffer contents];
    printf("Data pointer obtained\n");
    if (device_buffer_length == 0) {
        printf("Device buffer length is 0\n");
        return 0;
    }
    for (int i = 0; i < 4; i++) {
        printf("Device buffer[%d] = %d\n", i, data[i]);
    }
}

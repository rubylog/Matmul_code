import torch

################################### bfloat to binary converting ###################################

import struct

def bfloat16_to_binary(value):
    """
    Convert a torch.bfloat16 value to its binary representation.
    
    Args:
        value (torch.bfloat16): A single bfloat16 value.
    
    Returns:
        str: A 16-bit binary string representing the bfloat16 value.
    """
    # Convert torch.bfloat16 to float32
    float32_value = float(value)

    # Convert float32 to 32-bit binary
    float32_binary = struct.unpack('>I', struct.pack('>f', float32_value))[0]

    # Extract the upper 16 bits for bfloat16
    bfloat16_binary = float32_binary >> 16

    # Format as a 16-bit binary string
    return f"{bfloat16_binary:016b}"

def convert_2d_list_to_bfloat16_binary(input_list):
    """
    Convert a 2D list of floats to their BFLOAT16 binary representations.

    Args:
        input_list (list of list of float): The 2D list of float values.

    Returns:
        list of list of str: The 2D list of BFLOAT16 binary representations.
    """
    return [[bfloat16_to_binary(value) for value in row] for row in input_list]

################################### save .txt ###################################

def save_2d_list_to_file(input_list, filename):
    """
    Save a 2D list to a text file, with rows separated by newlines.

    Args:
        input_list (list of list of str): The 2D list to save.
        filename (str): The name of the file to save to.
    """
    with open(filename, 'w') as f:
        for row in input_list:
            f.write(''.join(row) + '\n')
            
################################### random bfloat ###################################

A_fp64 = torch.rand((64, 128), dtype=torch.float64) # 0 ~ 1
B_fp64 = torch.rand((64, 128), dtype=torch.float64)

# scaling
def tensor_scaling(tensor):
    scaled_tensor = tensor * (10.0 - 1.0) + 1.0
    return scaled_tensor

A_fp64 = tensor_scaling(A_fp64)
B_fp64 = tensor_scaling(B_fp64)

################################### For SW test ###################################

A_bf16 = A_fp64.to(dtype=torch.bfloat16)
A_fp16 = A_fp64.to(dtype=torch.float16)
A_fp32 = A_fp64.to(dtype=torch.float32) # same range as Bfloat16

print(A_bf16[0][0])
print(A_fp16[0][0])
print(A_fp32[0][0])
print(A_fp64[0][0])

"""
################################### For HW test ###################################


A_binary = convert_2d_list_to_bfloat16_binary(A)
B_binary = convert_2d_list_to_bfloat16_binary(B)

save_2d_list_to_file(A_binary, "A_64x128_raw.txt")
save_2d_list_to_file(B_binary, "B_64x128_raw.txt")

OUTPUT = A @ B.T
save_2d_list_to_file(OUTPUT, "OUT_64x64_raw.txt")
#print(OUTPUT.type())

"""

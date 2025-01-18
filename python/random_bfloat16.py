# >> Module for generating data for test bench and verifying bfloat16 accuracy on sw.

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

def convert_1d_list_to_bfloat16_binary(input_list):
    """
    Convert a 1D list of floats to their BFLOAT16 binary representations.

    Args:
        input_list (list of float): The 1D list of float values.

    Returns:
        list of str: The 1D list of BFLOAT16 binary representations.
    """
    return [bfloat16_to_binary(value) for value in input_list]

import torch

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
            
def save_1d_list_to_file(input_list, filename):
    """
    Save a 1D list to a text file, with each element on a new line.

    Args:
        input_list (list of str): The 1D list to save.
        filename (str): The name of the file to save to.
    """
    with open(filename, 'w') as f:
        for item in input_list:
            f.write(item + '\n')
       
################################### random bfloat & fp ###################################

torch.manual_seed(seed=17)

A_fp64 = torch.rand((64, 128), dtype=torch.float64) # 0 ~ 1
B_fp64 = torch.rand((64, 128), dtype=torch.float64)


scale = 20  # Define the scale factor
A_fp64 = (torch.rand((64, 128), dtype=torch.float64) * 2 - 1) * scale  # Rescale to [-scale, scale]
B_fp64 = (torch.rand((64, 128), dtype=torch.float64) * 2 - 1) * scale  # Rescale to [-scale, scale]


A_bf16 = A_fp64.to(dtype=torch.bfloat16)
A_fp16 = A_fp64.to(dtype=torch.float16)
A_fp32 = A_fp64.to(dtype=torch.float32) # same range as Bfloat16

B_bf16 = B_fp64.to(dtype=torch.bfloat16)
B_fp16 = B_fp64.to(dtype=torch.float16)
B_fp32 = B_fp64.to(dtype=torch.float32) # same range as Bfloat16



################################### For SW test ###################################

# <Matmul>

print('')
print("< Matmul SW TEST >")
print('')

print("bf16 : ", A_bf16[0][0])
print("fp16 : ", A_fp16[0][0])
print("fp32 : ", A_fp32[0][0])
print("fp64 : ", A_fp64[0][0])
print('')

output_fp16 = A_fp16 @ B_fp16.T
output_fp32 = A_fp32 @ B_fp32.T
output_fp64 = A_fp64 @ B_fp64.T

OUTPUT = A_bf16 @ B_bf16.T

print("Matmul result (1st row) bf16 : ", OUTPUT[0])
print("Matmul result (1st row) fp16 : ", output_fp16[0])
print("Matmul result (1st row) fp32 : ", output_fp32[0])
print("Matmul result (1st row) fp64 : ", output_fp64[0])


# <Each Adder>

print('')
print('')
print("< Adder SW TEST : BF16 only>")
print('')

def sum_two_lists(list1, list2):
    """
    Sums the elements of two lists element-wise.

    Args:
        list1 (list of numbers): The first input list.
        list2 (list of numbers): The second input list.

    Returns:
        list of numbers: A list containing the sums of the corresponding elements.
    """
    return [(a + b).item() for a, b in zip(list1, list2)]

adder_output = sum_two_lists(A_bf16[0], B_bf16[0]) # 128 outputs
print("Adder result (A, B first row) : ", adder_output)

# <PE Array> : same as each Multiplier

print('')
print('')
print("< PE Multiply SW TEST : BF16 only>")
print('')

def mul_two_lists(list1, list2):
    """
    Sums the elements of two lists element-wise.

    Args:
        list1 (list of numbers): The first input list.
        list2 (list of numbers): The second input list.

    Returns:
        list of numbers: A list containing the sums of the corresponding elements.
    """
    return [(a * b).item() for a, b in zip(list1, list2)]

PE_array_output = mul_two_lists(A_bf16[0], B_bf16[0])
print("PE Multiplay result (A, B first row) : ", PE_array_output)

# <Adder tree>

print('')
print('')
print("< Adder tree vs. Accumulation SW TEST : BF16 only>")
print('')

# 1. Accumulation in order

accumulation = sum(A_bf16[0])
print("bf16 Accumulation result (A first row) : ", accumulation)
accumulation = sum(A_fp16[0])
print("fp16 Accumulation result (A first row) : ", accumulation)
accumulation = sum(A_fp32[0])
print("fp32 Accumulation result (A first row) : ", accumulation)
accumulation = sum(A_fp64[0])
print("fp64 Accumulation result (A first row) : ", accumulation)
print('')

# 2. Adder Tree
from Adder_tree import Adder_tree

adder_tree_A = Adder_tree(A_bf16[0], count=128)
print("bf16 Adder tree result (A first row) : ", adder_tree_A)
adder_tree_B = Adder_tree(B_bf16[0], count=128)
#print("Adder tree result (B first row) : ", adder_tree_B)

adder_tree_fp16 = Adder_tree(A_fp16[0], count=128)
print("fp16 Adder tree result (A first row) : ", adder_tree_fp16)
adder_tree_fp32 = Adder_tree(A_fp32[0], count=128)
print("fp32 Adder tree result (A first row) : ", adder_tree_fp32)
adder_tree_fp64 = Adder_tree(A_fp64[0], count=128)
print("fp64 Adder tree result (A first row) : ", adder_tree_fp64)
print('')


################################### For HW test ###################################


# Matmul TB

A_binary = convert_2d_list_to_bfloat16_binary(A_bf16)
B_binary = convert_2d_list_to_bfloat16_binary(B_bf16)
OUTPUT = convert_2d_list_to_bfloat16_binary(OUTPUT)

save_2d_list_to_file(A_binary, "A_64x128_raw.txt")
save_2d_list_to_file(B_binary, "B_64x128_raw.txt")
save_2d_list_to_file(OUTPUT, "OUT_64x64_raw.txt")

# Adder, Adder Tree, PE Array TB

A_1st_row_binary = convert_1d_list_to_bfloat16_binary(A_bf16[0])
B_1st_row_binary = convert_1d_list_to_bfloat16_binary(B_bf16[0])
adder_output = convert_1d_list_to_bfloat16_binary(adder_output)
PE_array_output = convert_1d_list_to_bfloat16_binary(PE_array_output)

save_1d_list_to_file(A_1st_row_binary, "A_1x128_raw.txt")
save_1d_list_to_file(B_1st_row_binary, "B_1x128_raw.txt")
save_1d_list_to_file(adder_output, "SW_BF_adder_raw.txt")
save_1d_list_to_file(PE_array_output, "SW_PE_array_raw.txt")
print("Adder tree result A : ", adder_tree_A, bfloat16_to_binary(adder_tree_A))
print("Adder tree result B : ", adder_tree_B, bfloat16_to_binary(adder_tree_B))


################################### For HW debugging ###################################

"""
list = []
for a, b in zip(A_bf16[0], B_bf16[0]):
    #print(a)
    #print(b)
    #print(a*b)
    list.append(bfloat16_to_binary(a*b))
    
print(list[0:3])

print(A_bf16[0][0])
"""
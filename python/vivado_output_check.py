# >> Module that reads binary files from Vivado test bench results and compares them with the results of bfloat16 sw operations.

import torch

################################### binary (vivado output) to bfloat converting ###################################

def binary_to_bfloat16(binary_str):
    """
    Converts a binary string to a torch.bfloat16 tensor.

    Args:
        binary_str (str): A binary string (e.g., '1100001010100000') representing a BFLOAT16 number.

    Returns:
        torch.Tensor: A tensor with dtype=torch.bfloat16.
    """
    # Ensure the binary string is exactly 16 bits
    if len(binary_str) != 16:
        raise ValueError("Binary string must be exactly 16 bits.")

    # Convert binary string to an integer
    int_value = int(binary_str, 2)

    # Interpret the integer as a BFLOAT16 by using torch.tensor
    bfloat16_tensor = torch.tensor([int_value], dtype=torch.uint16).view(torch.bfloat16)

    return bfloat16_tensor.item()

def convert_2d_binary_list_to_bfloat16(input_list):
    """
    Convert a 2D list of binary strings to BFLOAT16 tensors.

    Args:
        input_list (list of list of str): The 2D list of binary strings.

    Returns:
        list of list of torch.bfloat16: The 2D list of BFLOAT16 tensors.
    """
    return [[binary_to_bfloat16(value) for value in row] for row in input_list]

def convert_1d_binary_list_to_bfloat16(input_list):
    """
    Convert a 1D list of binary strings to BFLOAT16 tensors.

    Args:
        input_list (list of str): The 1D list of binary strings.

    Returns:
        list of torch.bfloat16: The 1D list of BFLOAT16 tensors.
    """
    return [binary_to_bfloat16(value) for value in input_list]


################################### binary .txt (vivado output) read ###################################

def read_bfloat16_binary_file_to_list(filename):
    """
    Reads a text file containing continuous BFLOAT16 binary representations 
    and converts it to a list.

    Args:
        filename (str): The path to the text file.

    Returns:
        list of list of str: A 2D list of BFLOAT16 binary strings.
    """
    with open(filename, 'r') as f:
        # Read all lines, stripping any newline characters
        lines = f.readlines()

    # Define BFLOAT16 binary length
    binary_length = 16

    # Process each line
    result = []
    for line in lines:
        # Remove newline and split into chunks of 16 bits
        chunks = [line[i:i+binary_length] for i in range(0, len(line.strip()), binary_length)]
        result.append(chunks)

    return result

"""
<example>

input :
00111110010000000100000001000000
01000001010000000100001001000000


output :
[['0011111001000000', '0100000001000000'],
 ['0100000101000000', '0100001001000000']]
 
"""

def read_bfloat16_binary_file_vertical(filename):
    """
    Reads a text file containing 16-bit binary numbers written vertically (one per line)
    and converts it to a list.

    Args:
        filename (str): The path to the text file.

    Returns:
        list of str: A list of BFLOAT16 binary strings.
    """
    with open(filename, 'r') as f:
        # Read each line and strip newline characters
        result = [line.strip() for line in f if line.strip()]
    return result

################################### check result ###################################

# BF Adder
a = convert_1d_binary_list_to_bfloat16(read_bfloat16_binary_file_vertical("SW_BF_adder_raw.txt"))
b = convert_1d_binary_list_to_bfloat16(read_bfloat16_binary_file_vertical("tb_BF_adder_raw.txt"))

print('SW BF Adder Result : ')
print(a)
print('')
print('HW BF Adder Result : ')
print(b)
print('')
print('')

# PE Array

a = convert_1d_binary_list_to_bfloat16(read_bfloat16_binary_file_vertical("SW_PE_array_raw.txt"))
b = convert_1d_binary_list_to_bfloat16(read_bfloat16_binary_file_vertical("tb_PE_array_raw.txt"))

print('SW PE Array Result : ')
print(a)
print('')
print('HW PE Array Result : ')
print(b)
print('')
print('')

# Adder Tree

"""
Adder tree result A :  tensor(63.5000, dtype=torch.bfloat16) 0100001001111110
Adder tree result B :  tensor(67., dtype=torch.bfloat16) 0100001010000110
"""

print("A - Adder Tree SW Result : ", binary_to_bfloat16("0100001001111110"))
print("A - Adder Tree HW Result : ", binary_to_bfloat16("0100001001111011"))
print('')
print("B - Adder Tree SW Result : ", binary_to_bfloat16("0100001010000110"))
print("B - Adder Tree HW Result : ", binary_to_bfloat16("0100001010000101"))
print('')
print('')


# Matmul

a = convert_2d_binary_list_to_bfloat16(read_bfloat16_binary_file_to_list("OUT_64x64_raw.txt"))
b = convert_2d_binary_list_to_bfloat16(read_bfloat16_binary_file_to_list("tb_OUTPUT_64x64_raw.txt"))
print('SW Matmul Result (1st row) : ')
print(a[0])
print('')
print('HW Matmul Result (1st row) : ')
print(b[0])
print('')

print('SW Matmul Result (64th row) : ')
print(a[63])
print('')
print('HW Matmul Result (64th row) : ')
print(b[63])
print('')


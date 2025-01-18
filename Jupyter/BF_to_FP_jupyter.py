def BF_to_float(test_list_BF):
    test_list_FP = []
    
    for x in test_list_BF:
        sign_bit = x[0]
        exp_bits = x[1:9] # 8 bits
        fraction_bits = x[9:] # 7bits
        
        if sign_bit == '1':
            sign = -1
        else: sign = 1
        
        if exp_bits == '00000000':
            exp = 2**(-126)
        else: exp = 2**(int(exp_bits, 2)-127)
        
        if exp_bits == '00000000':   
            fraction = 0 + sum(int(bit) * (2 ** -(i + 1)) for i, bit in enumerate(fraction_bits))
        else: fraction = 1 + sum(int(bit) * (2 ** -(i + 1)) for i, bit in enumerate(fraction_bits))
        
        x_FP = sign * exp * fraction
        #print("exp :", exp)
        #print("fraction :", fraction)
        
        test_list_FP.append(x_FP)
        
    return test_list_FP
    
def BF_to_float_single(x):
    sign_bit = x[0]
    exp_bits = x[1:9] # 8 bits
    fraction_bits = x[9:] # 7 bits

    if sign_bit == '1':
        sign = -1
    else:
        sign = 1

    if exp_bits == '00000000':
        exp = 2**(-126)
    else:
        exp = 2**(int(exp_bits, 2)-127)

    if exp_bits == '00000000':
        fraction = 0 + sum(int(bit) * (2 ** -(i + 1)) for i, bit in enumerate(fraction_bits))
    else:
        fraction = 1 + sum(int(bit) * (2 ** -(i + 1)) for i, bit in enumerate(fraction_bits))

    x_FP = sign * exp * fraction
    return x_FP
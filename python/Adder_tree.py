def Adder_tree(input_list, count=128):
    k = 0
    layer1_out = []
    while k != count:
        layer1_out.append(input_list[k] + input_list[k + 1])
        k += 2

    k = 0
    layer2_out = []
    while k != count / 2:  # 64
        layer2_out.append(layer1_out[k], layer1_out[k + 1])
        k += 2

    k = 0
    layer3_out = []
    while k != count / 4:  # 32
        layer3_out.append(layer2_out[k], layer2_out[k + 1])
        k += 2

    k = 0
    layer4_out = []
    while k != count / 8:  # 16
        layer4_out.append(layer3_out[k], layer3_out[k + 1])
        k += 2

    k = 0
    layer5_out = []
    while k != count / 16:  # 8
        layer5_out.append(layer4_out[k], layer4_out[k + 1])
        k += 2

    k = 0
    layer6_out = []
    while k != count / 32:  # 4
        layer6_out.append(layer5_out[k], layer5_out[k + 1])
        k += 2

    k = 0
    layer7_out = []
    while k != count / 64:  # 2
        layer7_out.append(layer6_out[k], layer6_out[k + 1])
        k += 2

    # Final result in layer7_out
    return layer7_out[0]  # Assuming only one result remains

import re
import random

with open('tb_fp_add.sv', 'r') as file:
    content = file.read()

"""
    A function to convert from float to binary
"""
def float_to_binary(num : float, precision: int = 23) -> str:
    whole, decimal = str(num).split(".")
    whole = int(whole)
    decimal = float(f"0.{decimal}")

    #Convert the whole number part into binary
    whole_bin = bin(whole).replace("0b", "")

    decimal_bin = []
    while decimal and len(decimal_bin) < precision:
        decimal *= 2
        bit = int(decimal)
        decimal_bin.append(str(bit))
        decimal -= bit

    return whole_bin + "." + "".join(decimal_bin)

"""
    Normalizing the floating point number
"""
def normalize(num : str) -> list:
    temp = num.split(".")
    temp = int(temp[0])
    exp = -1
    while temp != 0:
        temp //= 10
        exp += 1
    num = num.replace(".","")
    num = num[1:24]
    exp += 127
    exp = bin(exp).replace("0b", "")
    return [num, exp]

def float_to_fp32(num : float) -> int:
    sign_bit = 0
    if (num < 0):
        sign_bit = 1

    y = normalize(float_to_binary(num))
    return int(str(sign_bit) +  str(y[1]) + y[0])

if __name__ == "__main__":

    # Find all occurrences of in_a and in_b assignments
    matches = re.findall(r"in_a = 32'b[01]+; in_b = 32'b[01]+;", content)
    
    for match in matches:
        r1 = float_to_fp32(random.uniform(0, 100))
        r2 = float_to_fp32(random.uniform(0, 50))

        in_a_value, in_b_value = r1, r2
        new_assignment = f"in_a = 32'b{in_a_value}; in_b = 32'b{in_b_value};"
        content = content.replace(match,new_assignment,1)

    # Write the modified content back to the file
    with open('tb_fp_add.sv', 'w') as file:
        file.write(content)
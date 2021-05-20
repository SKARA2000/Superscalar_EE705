def inst_code(name, rs, rt, rd, imm):
    if(name == "add"):
        out_str = "{0:06b}".format(0) + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:05b}".format(rd) + "{0:05b}".format(0) + "100000" + "\n"
    elif(name == "addi"):
        out_str = "001000" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm) + "\n"
    elif(name == "and"):
        out_str = "{0:06b}".format(0) + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:05b}".format(rd) + "{0:05b}".format(0) + "100100" + "\n"
    elif(name == "xor"):
        out_str = "{0:06b}".format(0) + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:05b}".format(rd) + "{0:05b}".format(0) + "100110" + "\n"        
    elif(name == "lw"):
        out_str = "100011" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm) + "\n"
    elif(name == "sw"):
        out_str = "101011" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm) + "\n"
    elif(name == "j"):
        out_str = "000010" + "{0:026b}".format(imm) + "\n"
    elif(name == "jal"):
        out_str = "000011" + "{0:026b}".format(imm) + "\n"
    elif(name == "bltz"):
        out_str = "000001" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm) + "\n"
    elif(name == "beq"):
        out_str = "000100" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm) + "\n"
    elif(name == "fpadd"):
        out_str = "000110" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:05b}".format(rd) + "{0:011b}".format(0) + "\n"
    elif(name == "fpadd"):
        out_str = "000111" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:05b}".format(rd) + "{0:011b}".format(0) + "\n"
    return out_str

if __name__ == "__main__":
    f = open("Codemem.txt", 'w')
    str_wr = []

    # ALU Program

    # FPU Program

    # Branch Program
    # f.write(inst_code("add", 1, 2, 0, 0))
    # f.write(inst_code("beq", 3, 3, 1, 4))
    # f.write(inst_code("addi", 3, 2, 1, 30))
    # f.write(inst_code("and", 1, 2, 4, 0))
    # f.write(inst_code("xor", 0, 4, 5, 0))
    # f.write(inst_code("add", 5, 1, 3, 0))

    # f.write(inst_code("and", 1, 2, 0, 0))
    # f.write(inst_code("addi", 3, 3, 1, 48))
    # f.write(inst_code("xor", 3, 2, 1, 1))
    # f.write(inst_code("beq", 2, 2, 1, 5))
    # f.write(inst_code("and", 0, 4, 5, 0))
    # f.write(inst_code("fpadd", 5, 1, 3, 0))
    # f.write(inst_code("fpadd", 3, 2, 4, 0))

    # f.write(inst_code("and", 1, 2, 0, 0))
    # f.write(inst_code("addi", 3, 3, 1, 48))
    # f.write(inst_code("xor", 3, 2, 1, 1))
    # f.write(inst_code("beq", 2, 2, 1, 1))

    # Memory Access Program
    # f.write(inst_code("add", 1, 2, 3, 0))
    # f.write(inst_code("lw", 0, 4, 1, 5))
    # f.write(inst_code("addi", 3, 2, 1, 30))
    # f.write(inst_code("and", 1, 2, 4, 0))
    # f.write(inst_code("xor", 0, 4, 5, 0))
    # f.write(inst_code("sw", 0, 1, 3, 38))

    # Simple Loop Program

    f.close()
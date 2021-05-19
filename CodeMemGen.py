def inst_code(name, rs, rt, rd, imm):
    if(name == "add"):
        out_str = "{0:06b}".format(0) + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:05b}".format(rd) + "{0:05b}".format(0) + "100000"
    elif(name == "addi"):
        out_str = "001000" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm)
    elif(name == "and"):
        out_str = "{0:06b}".format(0) + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:05b}".format(rd) + "{0:05b}".format(0) + "100100"
    elif(name == "lw"):
        out_str = "100011" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm)
    elif(name == "sw"):
        out_str = "101011" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm)
    elif(name == "j"):
        out_str = "000010" + "{0:026b}".format(imm)
    elif(name == "jal"):
        out_str = "000011" + "{0:026b}".format(imm)
    elif(name == "bltz"):
        out_str = "000001" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm)
    elif(name == "bltz"):
        out_str = "000001" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:016b}".format(imm)
    elif(name == "fpadd"):
        out_str = "000110" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:05b}".format(rd) + "{0:011b}".format(0)
    elif(name == "fpadd"):
        out_str = "000111" + "{0:05b}".format(rs) + "{0:05b}".format(rt) + "{0:05b}".format(rd) + "{0:011b}".format(0)
    return out_str

if __name__ == "__main__":
    f = open("Codemem.txt", 'w')
    str_wr = []

    # ALU Program
    f.write(inst_code("add", 1, 2, 0, 0))
    f.write(inst_code("add", 3, 0, 1, 0))
    f.write(inst_code("add", 3, 2, 1, 0))
    f.write(inst_code("add", 1, 2, 4, 0))

    # FPU Program
    # Branch Program
    # Memory Access Program
    # Simple Loop Program

    f.close()
import os
import re
import random
path=os.path.dirname(os.path.realpath(__file__))
os.chdir(path)
# 加载测试用的数据（用mips汇编语言给出，随机生成），写到test.asm文件中
with open("test.asm","w") as file:
    # 随机生成各15条ori和lui指令
    for i in range(15):
        x=random.randint(0,31)
        y=random.randint(0,31)
        num=random.randint(0,10000)
        file.write("ori $%d,$%d,%d\n"%(x,y,num))
        file.write("lui $%d,%d\n"%(x,num))
    # 随机生成各15条sw和lw指令
    for i in range(15):
        x=random.randint(0,31)
        y=random.randint(0,31)
        num=random.randint(0,100000)
        file.write("sw $%d,%d($%d)\n"%(x,num,y))
        file.write("lw $%d,%d($%d)\n"%(x,num,y))
    # 随机生成各15条add和sub指令
    for i in range(15):
        x=random.randint(0,31)
        y=random.randint(0,31)
        z=random.randint(0,31)
        file.write("add $%d,$%d,$%d\n"%(x,y,z))
        file.write("sub $%d,$%d,$%d\n"%(x,y,z))
# 利用test.asm文件中的内容，调用Mars将其翻译成机器码，写入test.txt
rom_name="test.txt"
command="java -jar Mars4_5.jar test.asm nc mc CompactDataAtZero a dump .text HexText "+rom_name
os.system(command)
content=open(rom_name).read()

# 将这些指令机器码写入测试电路IM模块的ROM中，并将写入后的电路另存为test.circ    
circmy=open("p3-cpu-test.circ",encoding='UTF-8').read()
# addr/data: 12 32 这一部分是正则字符串匹配，请按照自己的ROM规格修改
circmy=re.sub(r'addr/data: 12 32([\s\S]*)</a>',"addr/data: 12 32\n"+content+"</a>",circmy)
with open("test.circ","w",encoding='UTF-8') as file:
        file.write(circmy)

# 调用Logisim对test.circ电路进行测试，将测试得到的输出写到mytest.txt
os.system("java -jar logisim-generic-2.7.1.jar test.circ -tty table,halt >mytest.txt")
print("generate is successful!")
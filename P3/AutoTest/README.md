# 自动化测试初步尝试说明

> 只是想在此保留一下我的尝试记录。第一次实践中遇到诸多问题，功能不完善请见谅。  
> 目前最主要的问题是**通过命令行让Logisim运行测试电路时无法自行停止**，或者说**在下面的`python`脚本中`os.system("java -jar logisim-generic-2.7.1.jar test.circ -tty table,halt >my-text.txt")`命令会一直处于执行状态**。  
> 目前暂行的办法在终端是人为输入`ctrl`+`C`停止运行，得到输出的结果。


主要进行的步骤如下：
- 编写测试电路
  - 在自己已成型的cpu电路文件（`.circ`）基础上拷贝一份，加入最顶层模块`test`（命名可自定义）。将原来的`main`模块做为子模块，接入`test`模块中。具体的连接方式可以模仿**评测机提交窗口的测试电路图**。
  - 将这个修改后的电路文件（`.circ`）做为用来测试的电路，这里命名为`p3-cpu-test.circ`。
- 编写自动化测试`python`脚本
  - 参考代码如下，其中**部分框架参考了已有的python模块。具体内容由本人填充**。
```python
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
``` 
- 运行并比对结果
  - 在Windows命令行脚本文件目录下，运行脚本：`python xxx.py`。请确保目录下有 `logisim-generic-2.7.1.jar`和`Mars4_5.jar`
  - 得到自己的输出后，可以同样用其他人的标准的cpu进行测试，并将两个结果进行对比

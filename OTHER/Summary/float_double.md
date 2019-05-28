# float && double 在内存中的存储 #
## 1.float ##
* 存储划分  

float类型在内存中4个字节,其中第一个字节中的最高位代表此float类型知道的符号(标识正负,0为正,1为负),
第二的字节的低7位,及第三个字节的高1位共1个字节代表指数部分,剩余的23个bit代表底数部分,详情见先下述表示:  
 0     0000000 0  0000000 00000000 00000000  
|-|   |---------||-------------------------|

* 计算  
假设 F 为符号位,E 为指数为, D 为底数  
F = 0,E = 1000 0001b  D = 100 0000 0000 0000 0000 0000  
其中底数部分以1为基础,__*既当前D值将1,为1.10000000000000*__,  
指数部分有正负,因此指数的范围为[-127,127],指数的计算方式为E-127  
F值为符号
因此当前值为 1.10000b * 2^(10000001b-127) = 1.1b*(2^2) = 1.1b<<2 = 110b = 6

## 2.double ##
类似float 的存储,区别在于double在内存中占8个字节,精度更高,符号为仍占一个bit,指数占11bits,底数占52bits,计算方式同float计算
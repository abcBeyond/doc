# <center> ibus_A33 代码解析 </center>  ##
## 基本概述 ## 
    基本功能同2440,由于A33上部分硬件的改动,软件上的实现不同与2440,在此做部分说明

## 功能汇总  ##
* [扣费流程](#costfee)
* [网络相关](#network)
* [声音播放](#voice)
* [交通部测试](#tmtest)
* [安卓移植](#android)
* [其他](#other)

## 功能详解 ##
* <span id="costfee"> 扣费流程 </span>
     由于对应交通部L1测试,扣费流程代码做了部分更改,重新架构了底层串口通讯部分,同时针对这部分更改,也重新实现了一下大连的卡业务处理.  
     1. 底层实现
        * 通讯
            当前的业务主要是串口通讯,代码设计时考虑到其他通讯方式的可能性,设计了基类BaseTransTools
            ```
            class BaseTransTools{
            public:
                BaseTransTools(){}
                virtual bool open()=0;
                virtual void close()=0;
                virtual void flush()=0;
                virtual char* readAll(int *)=0;
                virtual int  write(const char*,int)=0;
                virtual void resetPortSetting() = 0;
            };
            ```
            如果要添加其他通讯方式,继承此类并实现对应的虚函数即可.   
            当前代码中实现了两种串口通讯方式,一种是依赖于基于Qt实现的串口库Posix_QextSerialPort,另一种是基于linux原生的串口库.    
            基于Qt的第三方串口库相关代码:
            ```
            class SerialPortBaseQextSerialPort:public BaseTransTools{
            public:
                explicit SerialPortBaseQextSerialPort(const char*,int baund,int dataBits,int flowControl,int parity,int stopBits);
                ~SerialPortBaseQextSerialPort();
                bool open();
                void close();
                void flush();
                char* readAll(int *len);
                int write(const char *pData, int len);
                void resetPortSetting();
            private:
                const char* m_portName;
                PortSettings m_portSetting;
                Posix_QextSerialPort* m_serialPort;
            };
            ```
            基于Linux原生串口相关代码:
            ```
            class SerialPortBaseNormalSerialPort:public BaseTransTools{
            public:
                explicit SerialPortBaseNormalSerialPort(const char*,int baund,int dataBits,int flowControl,int parity,int stopBits);
                ~SerialPortBaseNormalSerialPort();
                bool open();
                void close();
                void flush();
                char* readAll(int *len);
                int write(const char *pData, int len);
                void resetPortSetting();
            private:
                enum{Buffer_Size=512};
                typedef struct _t_portSetting{
                    _t_portSetting():name(NULL),baund(9600),dataBits(8),flowControl(0),parity('N'),stopBits(1){}
                    _t_portSetting(const char* pn,int b,int d,int f,int p,int s):
                    name(pn),baund(b),dataBits(d),flowControl(f),parity(p),stopBits(s){
                    }
                    const char* name;
                    int baund;
                    int dataBits;
                    int flowControl;
                    int parity;
                    int stopBits;
                    void resetPortSetting();
                }tPortSetting;
                const char* m_portName;
                int m_fd;
                tPortSetting m_portSetting;
                char m_readBuffer[Buffer_Size];

                int _open(const char* name);
                bool _setUART(tPortSetting);
            };
            ```
        * 协议
           两部分协议,一是同读卡模块的通讯(参考文档"MF-Reader通信协议V1.4.doc"),另一个是和PSAM通讯的协议(参考资料 白皮书 "建设部安全认证卡(模块)技术要求",应该有最新的,写代码时参考本书)   
           涉及到的代码内容:
           ```
           class ReaderTransProtocol:public BaseTransProtocol
           {
           public:
        
               /**
                 针对各种制定声明的数据结构,易于控制各种参数
                 **/
               //通用接口,只有超时时间的命令
               typedef struct _common_cmd{
            
                   _common_cmd(char w):waitTime(w){}
                   char waitTime;  //等待时间
               }commonCmd_t;
               ...
           }
           ```
           ```
           class PSAMTransProtocol:public BaseTransProtocol{
            public:

                //选择PSAM ADF指令
                typedef struct _tSelectADF{
                    _tSelectADF(char* p,int l):pCh(p),len(l){}
                    char* pCh;
                    int len;
                }SelectADF_t;

                //count MAC1
                typedef SelectADF_t PSAMCountMAC1_t;
                ...
           }
           ```
        * UI 
           封装接口调用原界面显示接口进行显示  
           相关代码:
           ```
           ```
        * 声音
           封装接口调用原接口进行语音播放,[声音](#voice)   
           相关代码:
           ```
           ```
        * 设备
            工厂模式实现,通过实例化"通讯","协议","UI"以及"声音"的组合,来实现不同的设备,当前代码中主要实现了两个设备CardReaderDevice 和 PSAMDevice,主要用来实现当前的业务需求,如后续添加其他业务,只需实现相应协议等内容,重新组合一下即可  
            相关代码:
            ```
            class CardReaderDevice:public BaseDevice{
            public:
                explicit CardReaderDevice(int fd,BaseTransProtocol* p,BaseTransTools* t,BaseSound* sound,BaseUI* ui);
                ~CardReaderDevice();
                operateBack_t doOperate(eCmd,void* pv = NULL);
                operateBack_t doOperate(eCmd,const char* buffer,int len);
                operateBack_t doOperate(const tSndCmdPara* p);
                ...
            }
            ```
            ```
            class PSAMDevice:public BaseDevice{
            public:
                typedef struct _tPSAMChannel{
                    int io1;
                    int io2;
                    int io3;
                }tPSAMChannel;

                enum {PSAMKEYNUMBER = 6};
                ...
            }
            ```

     2. 卡处理
        主要是对应项目中的process文件夹下的文件,其中baseprocess.h中声明基类BaseCardProcess,其中纯虚函数是process是处理入口,子类只需重载process函数来实现业务处理
        ```
        class BaseCardProcess
        {
        public:
            BaseCardProcess();
            virtual ~BaseCardProcess();
            virtual void process() = 0;
        };
        ```
        在正式的业务处理中会涉及到数据的存储,如CardProcessDL中,当前项目中实现了两种存储数据的方式,一是存储在Sqlite中(当前Android用这种法师),一种是保留2440中的CSV文件存储(当前A33中是这种方式)
        ```
            m_db = new CardprocessDBCSV();
        ```

     3. 大连业务处理
        见文件"cardprocessdl.h"及"cardprocessdl.cpp"

* <span id="network"> 网络相关 </span>
     主要是工具quectel-CM的使用,具体见代码中的"ltecontrol.h"和"ltecontrol.cpp"文件
* <span id="voice"> 声音播放 </span>
     A33中音频播放不能直接用Qt中的QSound进行声音播放,因为当前版本的Qt(4.7.2)中的QSound可能是调用的OSS架构播放语音,A33中用的Alsa架构,当前的解决方案是移植TinyAlsa工具来实现语音播放,具体方式就是将TinyAlsa编译成第三方库放入当前工程中,通过调用库函数来播放语音.   
     TinyAlsa源码路径: svn://172.18.1.3/bus_m2plus2440/code/branches_other/tinyalsa  (编译方式见"编译说明")    
     iBus代码相关文件:

* <span id="tmtest"> 交通部测试</span>   
    - Level1   
        Level1的测试基本已经完成,部分未通过相需要等待刷卡模块程序完善.   
        以下是代码基本逻辑的流程图:
        <span id = "totalprocess">总流程:</span>
        ```flow
        st=>start: 开始
        e=>end: 结束
        OpeCardA=>subroutine: A卡处理
        OpeCardB=>subroutine: B卡处理
        CardABack=>condition: GoOn?
        CardBBack=>condition: GoOn?
        st->OpeCardA->CardABack()
        CardABack(yes)->OpeCardB
        CardABack(no)->OpeCardA
        OpeCardB->CardBBack()
        CardBBack(yes)->OpeCardA
        CardBBack(no)->OpeCardB
        ```
        <span id="processtypea">TypeA流程:</span>
        ```flow
        st=>start: 开始
        e=>end: 结束
        
        opeAnticollision=>subroutine: 防冲突
        opeSelect=>subroutine: 选择 
        opeGetRTS=>subroutine: GetRTS 
        opeAPDU=>subroutine: APDU 

        opeReset=>operation: Reset 
        opeHalt=>operation: Halt
        opeHaltForError=>operation: Halt
        wupA=>operation: WupA
        isFindCardSuccess=>condition: 是否正确寻到A卡?
        isNoCard=>condition: 是否无卡?
        isWupABackError=>condition: WupA返回错误
        isFindCardBefore=>condition: 上一次WupA是否返回
        isFindCardBeforeForNoCard=>condition: 上一次WupA是否返回
        isFindCardBeforeForError=>condition: 上一次WupA是否返回
        isTimesOver=>condition: 计数器i是否超过3

        timesAdd=>operation: 计数器i++
        timesClear=>operation: 计数器清空
        backGoOn=>operation: 继续
        backReProcess=>operation: 重发
        st->wupA->isFindCardSuccess()
        isFindCardSuccess(yes)->isFindCardBefore()
        isFindCardSuccess(no)->isNoCard()

        isNoCard(yes)->isFindCardBeforeForNoCard()
        isNoCard(no)->isFindCardBeforeForError()

        isFindCardBeforeForError(yes)->opeReset
        isFindCardBeforeForError(no)->opeHaltForError->backGoOn

        isFindCardBeforeForNoCard(yes)->timesAdd->isTimesOver()
        isFindCardBeforeForNoCard(no)->backGoOn
        
        isTimesOver(yes)->timesClear->opeReset->backReProcess
        isTimesOver(no)->backReProcess->e

        isFindCardBefore(no)->opeHalt->backGoOn->e
        isFindCardBefore(yes)->opeAnticollision->opeSelect->opeGetRTS->opeAPDU->e

        ```
        防冲突,选择,GetRTS以及后续的APDU逻辑上比较简单,更多的是判断刷卡模块的返回值,具体可参考代码 
    - Level2
    ```
    ```
* <span id="android"> 安卓移植</span>  
    1. 代码处理    
         当初为兼容安卓版本,刷卡流程部分没有用Qt相关库的API,其中有几个宏值需要特别关注一下:   
         _include.h
        ```
         #define _ANDROID_ 0             //是否为安卓程序
        ```   
    2. 动态库生成

         通过打开_include.h中的_ANDROID_开关,编译生成安卓需要的so文件,调用相关函数即可进行刷卡流程.当前SVN服务器上有一个可以处理基础卡流程的版本,路径为:   
         svn://172.18.1.3/bus_m2plus2440/code/branches_android/iBus_CardTradeModule   
         在子目录jtbL1Test 下执行make ,makefile 会自动将生成的库文件以及需要的头文件拷贝到安卓App源码中,需要根据自己机器的环境去配置makefile文件,几个关键的变量:   
         BASEINSTALLDIR: 安卓工程的放置库文件和.h文件的路径,可参考SVN上版本的makefile进行更改   
         NDK_ROOT:  ndk路径   

* <span id="other"> 其他</span>  
         项目中还涉及到一些第三方软件的使用,如上文提到的tinyalsa之类的,在此做个总结,方便查找   
         1. tinyalsa
         2. dhclient
         3. quectel-CM
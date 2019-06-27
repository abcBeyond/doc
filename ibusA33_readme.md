# <center> ibus_A33 代码解析 </center> #
## 基本概述 ##  
       基本功能同2440,由于A33上部分硬件的改动,软件上的实现不同与2440,在此做部分说明
## 功能汇总 ##
* [扣费流程](#costfee)
* [网络相关](#network)
* [串口相关](#serial)
* [声音播放](#voice)
* [交通部测试](#tmtest)
* [安卓移植](#android)
* [其他](#other)

## 功能详解 ##
* <span id="costfee"> 扣费流程 </span>
     由于对应交通部L1测试,扣费流程代码做了部分更改,重新架构了底层串口通讯部分,同时针对这部分更改,也重新实现了一下大连的卡业务处理.  
     1. 串口通讯
     2. 卡处理架构

* <span id="network"> 网络相关 </span>
* <span id="serial">  串口相关 </span>
* <span id="voice"> 声音播放 </span>
     A33中音频播放不能直接用Qt中的QSound进行声音播放,因为当前版本的Qt(4.7.2)中的QSound可能是调用的OSS架构播放语音,A33中用的Alsa架构,当前的解决方案是移植TinyAlsa工具来实现语音播放,具体方式就是将TinyAlsa编译成第三方库放入当前工程中,通过调用库函数来播放语音.   
     TinyAlsa源码路径: svn://172.18.1.3/bus_m2plus2440/code/branches_other/tinyalsa  (编译方式见"编译说明")    
     iBus代码相关文件:

* <span id="tmtest"> 交通部测试</span>   
    - Level1   
        Level1的测试基本已经完成,部分未通过相需要等待刷卡模块程序完善.   
        以下是代码基本逻辑的流程图:
        <span id = "totalprocess">总流程:</span>
        ```mermaid
            graph TB;
            Start-->WupA{寻A卡,是否有卡}
            WupA-->|yes|WupB{寻B卡,是否有卡}
        ```
        <span id="processtypea">A流程:</span>
        ```mermaid
            graph TB;
            A-->B
        ```
        <span id="processtypeb">B流程:</span>
        ```mermaid
            graph TB;
            A-->B
        ```
    - Level2
    ```
        void main(){

        }
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
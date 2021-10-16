#!/bin/bash

function clean_hello()
{
    rm -f hello.i hello.s hello.o hello.bin
}

function build_hello()
{
    # 预处理：加入头文件，替换宏
    gcc -E hello.c -o hello.i

    # 编译：包含预处理，将C程序转换成汇编程序
    gcc -S hello.i -o hello.s

    # 汇编：包含预处理、编译，将汇编程序转换成可链接的二进制程序
    gcc -c hello.s -o hello.o

    # 链接：包含以上所有操作，将可链接的二进制程序和其他别的库链接在一起，形成可执行的程序文件
    gcc hello.o -o hello.bin
}

case $1 in
    clean)
        clean_hello
        ;;

    build)
        build_hello
        ;;
    *)
        echo "Usage: ./run.sh clean|build"
        ;;
esac

---
layout: post
title:  "如Py似C：Python 與 C 的共生法則"
categories: Blog Tech Python
tags: ["Python", "PyLadies", "C"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

「C君，你做事那麼快，carry 一下我的作業啦！」「好啊Py桑，那你人緣那麼好，記得幫我介紹女朋友喔。」

C 的高效能及接近底層硬體的特性，使其成為嵌入式系統開發的首選，卻極少有人會厭世到拿它開發網頁；Python 語法簡潔且能快速開發，無論網頁、遊戲、資料科學皆有其應用，但其速度卻會在很多資源有限的地方吃鱉。

C 與 Python 如何互相截長補短、共生共榮，成為程式語言界的一大課題。此篇將會簡介一些 C 與 Python 的整合方法，見證C君與Py桑如何從死對頭變成相互扶持的好友。

<!--more-->
---

_* 請注意，以下只針對Python3進行講解與測試，並以 MacOSX 為環境。_

假使你正在跑 Python 的專案，卻因為其中某個需要做大量運算的 function 等得不耐煩，又不想整個專案改用效能高但複雜的 C 重寫，那麼如何能只獨立這個 function 改用 C ，並將它置入原本的 Python 專案呢？又或是你的 C 專案裡有一部分寫起來很棘手，能不能改用 Python 快速實現這部分的功能，並插入原本的 C 專案？又或者你手邊拿到的程式碼就剛好是 C 或 Python，如何用另一個語言調用手邊的現有程式而不用重新實現呢？

接下來將會簡單介紹幾個 Python 調用 C 以及 C 調用 Python 的方法。

GitHub 原始碼：https://github.com/pyliaorachel/python-c-mixing

## Python 調用 C

假設我們有一個很花時間的 function 叫做 `slow_calc`，想用效能高的 C 實現：

```c
int slow_calc(int x, int a, int b) {
    return a * x + b;
}
```

以下簡介幾個可以讓 Python 調用這個 C function 的 library 或工具。

### [Python/C API](https://docs.python.org/3/c-api/intro.html)

[Python extension module](https://docs.python.org/3/extending/building.html) 是以 Python 以外的語言建立且能夠讓 Python 匯入的 module。Python/C API 即是 C 裡能夠建立 Python extension module 的媒介，只需要引入 `Python.h` 這個標頭檔即可開始手刻。

```c
#include <Python.h>
```

這邊注意，這些 extension module 都是針對 CPython，也就是官方以 C 實現的 Python 直譯器。

為了建立 `slow_calc` function 的接口，我們把它寫進 `speedup_performance.c` 檔並打包成 Python extension module，大致上有五個步驟：

##### Step 1: 包裝 Function

Python 裡的任何 type 都對應到 C 裡的 `PyObject`，所以我們要把原本的 function 包裝一下，讓參數和回傳值皆為 `PyObject`。這個包裝可以有以下三種參數形式：

1. `(PyObject *self, PyObject *args)`
2. `(PyObject *self, PyObject *args, PyObject *kwargs)`
3. `(PyObject *self)`

`args` 是 positional arguments，`kwargs` 是 keyword arguments。讓我們試試有 keyword argument 的例子，把前面定義的 `slow_calc` function 包成 `_slow_calc`：

```c
static PyObject *_slow_calc(PyObject *self, PyObject *args, PyObject *kwargs) {
    // 參數值
    int x, a = 0, b = 0;
    // kwlist 裡存放 keyword 的名字，以 NULL 結束
    static char *kwlist[] = {"x", "a", "b", NULL};
    // 回傳值
    int res;

    // PyArg_ParseTupleAndKeywords 會嘗試把接收的 args 及 kwargs 
    // 包成我們要的 format，也就是 "i|ii"
    // i 即 int，non-optional 和 optional arguments 以 | 區隔
    // 成功包好的值存在 x，a，b 中，打包失敗則整個 function 回傳 0，不再繼續下去
    if (!PyArg_ParseTupleAndKeywords(args, kwargs, "i|ii", kwlist, &x, &a, &b)) {
        return NULL;
    }

    // 呼叫原 function，傳入包好的值 
    res = slow_calc(x, a, b);

    // 把回傳值用 Py_BuildValue 包成 PyObject 以回送給 Python
    return Py_BuildValue("i", res);
}
```

##### Step 2: 建立 Module's Method Table

把 module 裡的 function 都一一包好後，就要建立一個 module's method table，也就是這個 module 的 method 列表。

```c
// 每筆形式為 { name, method, flags, doc }
// 即 { 名稱, 對應函數, 哪種 argument 形式, 描述 }
static PyMethodDef SpeedupPerformanceMethods[] = {
    {"slow_calc", _slow_calc, METH_VARARGS | METH_KEYWORDS, "A slow calculation method."},
    {NULL, NULL, 0, NULL} // 以 NULL 作結
};
```

這邊的 `flags` 可提供的值可參照[文件](https://docs.python.org/3/c-api/structures.html#c.PyMethodDef)，主要是告知 arguments 會如何被傳入。

##### Step 3: 定義 Module 結構

接著再定義 module：

```c
// 形式為 { base, name, doc, size, module's method table }
// 即 { PyModuleDef_HEAD_INIT, 名稱, 描述, 分配 memory 大小, method 列表 }
static struct PyModuleDef speedup_performance_module = {
    PyModuleDef_HEAD_INIT,
    "speedup_performance",
    "A module containing methods with faster performance.",
    -1, // global state
    SpeedupPerformanceMethods
};
```

第一個 `base` 皆設為 `PyModuleDef_HEAD_INIT` 即可。`size` 則是每個 `module` 可被分配存放 `module state` 的空間大小，設為 `-1` 則為 `global state`。詳可參照[文件](https://docs.python.org/3/c-api/module.html#c.PyModuleDef)。

##### Step 4: 定義 Module Initialization Method

當 Python import 這個 module 時會呼叫一個 initialization method，這個 method 必須以 `PyInit_<module>` 形式命名：

```c
// PyMODINIT_FUNC 除了回傳 PyObject，還會處理不同平台間的 linkage 問題
PyMODINIT_FUNC PyInit_speedup_performance() {
    return PyModule_Create(&speedup_performance_module);
}
```

這個 initialization method 被呼叫後，會建立一個 module object，內含 method 列表列出的 function。這樣 Python 就能使用 C 裡提供的 function 了！

##### Step 5: 建立 Extension Module

上述程式碼寫完後存在 `speedup_performance.c`裡。接著藉著 `setup.py` 和 `Distutils` 把 extension module 真的做出來：

```python
from distutils.core import setup, Extension

speedup_performance_module = Extension('speedup_performance',
                                       sources=['speedup_performance.c'])

setup(name='SpeedupPerformance',
      description='A package containing modules for speeding up performance.',
      ext_modules=[speedup_performance_module],
)
```

然後下：

```bash
$ python3 setup.py build_ext --inplace
```

如此會有一個 `*.so` 出現在當前目錄，這就是 Python 可以使用的 shared library。讓我們打開 Python 用用看:

```python
from speedup_performance import slow_calc

print(slow_calc(3, a=2, b=4))
>>> 10
```

### [ctypes](https://docs.python.org/3.6/library/ctypes.html)

`ctypes` 是 Python 提供的一個 library，可以在 Python 中匯入一些外部 dynamic-link library (DLL) 或 shared library，來調用其中的 function。

如果是已經存在的 library，可以直接從下面的第二步開始。現在假設我們想把前面提到自己寫的，很花時間運算的 `slow_calc` function 打包給 `ctypes` 調用，且這個 function 寫在 `speedup_performance.c` 裡。

`ctypes` 簡單三步驟：

##### Step 1: 建立 Shared Library

首先用 gcc 建立 shared library，產生 `speedup_performance.so` 檔：

```bash
$ gcc -shared -fPIC speedup_performance.c -o speedup_performance.so
```

##### Step 2: 匯入 Library

接著在 Python 用 `ctypes` 提供的 function 來匯入剛剛建立的 `so` 檔：

```python
from ctypes import *
m = cdll.LoadLibrary('./speedup_performance.so')
```

如此一來 library 中的 function 就能以 `m.func()` 取用。

##### Step 3: 呼叫 Function

調用的時候，需要傳入對應原 C function 中的 parameter types。[這邊](https://docs.python.org/3.6/library/ctypes.html#fundamental-data-types)有列出每個 C type 對應的 ctypes type，例如我們需要傳入的 `int` 對應到 `c_int`：

```python
print(m.slow_calc(c_int(3), c_int(2), c_int(4)))
>>> 10
```

### [SWIG](http://www.swig.org/Doc3.0/Contents.html#Contents)

比起前兩者，SWIG (Simplified Wrapper and Interface Generator) 是一個更全面的建立 C/C++ interface 的工具，支援如 Python，Perl，Ruby 等多種語言。

在[安裝](http://www.swig.org/Doc3.0/Preface.html#Preface_installation)好 SWIG 後，再來一樣嘗試打包我們的 `slow_calc` function。這次我們方便起見，把 function 直接寫在 `speedup_performance.h` 裡，等一下需要 include。

大致上有四步驟：

##### Step 1: 建立 Interface File

首先要有一個描述 interface 的檔案，習慣命名為 `*.i` 或 `*.swg`。

讓我們建立一個 `speedup_performance.i`：

```
/* 定義 module 名稱 */
%module speedup_performance

/* 在這個區塊的程式碼會原封不動置入待會產生的 C wrapper */
%{
#include "speedup_performance.h"
%}

/* 告訴 SWIG 你宣告的 function 或 variable */
int slow_calc(int x, int a = 0, int b = 0);
```

上面被包在 `%{ ... %}` 裡的程式碼，主要是一些 header file 或其他 declaration；這些宣告不會被 compile，而是直接置入下一步產生的 C wrapper 檔。但下面的區塊不是也有差不多的宣告嗎？為什麼需要重複？這麼做是因為下面區塊的宣告是讓 SWIG 在 wrapper file 裡建立一些 wrapper function 用的，而不是用來與原本寫的 function 連接。所以要在 wrapper file 重新置入 `%{ ... %}` 裡的宣告，wrapper file 裡才能調用原 function，也才可以確保在第三步建立 shared library 的時候的 linkage 可以成功。

另外我們原本的 `slow_calc` 裡並沒有 default argument （因 C 本身並不怎麼支援），但是 SWIG 接受 [default argument](http://www.swig.org/Doc1.3/SWIGPlus.html#SWIGPlus_default_args)，所以我們在這裡添加了一些 default values。

###### Step 2: 產生 Wrapper File

有了 interface 的資訊後，就可以請 SWIG 建立可以拿來做 extension module 的 `speedup_performance.py` 和 wrapper file `speedup_performance_wrap.c`：

```bash
$ swig -python speedup_performance.i
```

或是建立 keyword argument 形式：

```bash
$ swig -python -keyword speedup_performance.i
```

##### Step 3: 建立 Shared Library

這邊同上面 `Python/C API` 範例，用 `setup.py` 和 `Distutils` 建立 shared library：

```python
from distutils.core import setup, Extension

# Extension module name 要有底線前綴
speedup_performance_module = Extension('_speedup_performance',
                                       sources=['speedup_performance_wrap.c'])

setup(name='SpeedupPerformance',
      description='A package containing modules for speeding up performance.',
      ext_modules=[speedup_performance_module],
)
```

這邊注意 extension module 名稱必須有底線前綴，這是[官方文件](http://www.swig.org/Doc1.3/Python.html#Python_nn6)上提到的命名規則。

下個指令建立 `*.so`：

```bash
$ python3 setup.py build_ext --inplace
```

##### Step 4: 匯入 Library & 調用 Function 

有了 Step 2 的 `*.py` 和 Step 3 的 `*.so`，就可以成功調用 `slow_calc` function 了：

```python
from speedup_performance import slow_calc

print(slow_calc(3, a=2, b=4))
>>> 10
```

## C 調用 Python

### [Python/C API](https://docs.python.org/3/c-api/intro.html)

`Python/C API` 一樣是最基礎的解法。

現在假設我們有個寫法很複雜，卻不需在意效能的 `complex_calc` function 想用 Python 實現：

```python
def complex_calc(x, a=0, b=0):
    return a * x + b
```

讓我們先把上述 `complex_calc` function 寫進 `speedup_dev.py` 裡。然後我們在 `main.c` 裡先理所當然地：

```c
#include <Python.h>
```

接著三步驟調用這個 function：

##### Step 1: 打包 Function

```c
int complex_calc(int x, int a, int b) {
    PyObject *pModule, *pFunc, *pArgs, *pKargs, *pRes;
    int res;

    // 匯入 `speedup_dev` module & `complex_calc` function 
    pModule = PyImport_Import(PyUnicode_FromString("speedup_dev"));
    pFunc = PyObject_GetAttrString(pModule, "complex_calc");
    
    // 把 arguments 打包成 PyObject
    pArgs = Py_BuildValue("(i)", x);
    pKargs = Py_BuildValue("{s:i, s:i}", "a", a, "b", b);

    // 呼叫 function 
    pRes = PyObject_Call(pFunc, pArgs, pKargs);

    // 檢查有沒有呼叫失敗，沒有的話把回傳值從 PyObject 包回 C type 
    if (pRes == NULL)
        return -1;
    res = PyLong_AsLong(pRes);

    // 處理一下 memory allocation 
    Py_DECREF(pModule);
    Py_DECREF(pFunc);
    Py_DECREF(pArgs);
    Py_DECREF(pKargs);
    Py_DECREF(pRes);

    return res;
}
```

再次重複，跟 Python 溝通的值皆為 `PyObject` type，所以需要轉換 argument 和 return value。

這邊比較麻煩的是要自己[處理 memory allocation](https://docs.python.org/3.6/extending/extending.html#reference-counting-in-python) 。每當一個 `PyObject` 被創建，它就會有一個 reference count，也就是有多少調用者有責任去管理這個 `PyObject`；當 reference count 變為 0，這個 `PyObject` 就會被 free。如果根本沒人在管理這個 `PyObject`， reference count 卻不為 0，就會有 memory leak 的問題。所以我們要記得在利用完這些 `PyObject` 後呼叫 `Py_DECREF` 減少 reference count，某些情況下該增加時也要呼叫 `Py_INCREF`。

但 reference count 的[規則](https://docs.python.org/3.6/extending/extending.html#reference-counting-in-python)有點複雜，自己處理很容易 bug 滿天飛（我可能也有 bug...），這也是使用 `Python/C API` 的難點之一。

##### Step 2: 呼叫 Function

打包好之後，我們就有一個可以呼叫的 C function 了。不過在調用之前，得先做一點設置：

```c
int main() {
    // Initialize Python 直譯器 
    Py_Initialize();
    
    // 設置 Python search path 
    PySys_SetPath(Py_DecodeLocale(".", NULL));
 
    // 呼叫 function
    printf("%d\n", complex_calc(3, 2, 4));

    // 釋放 Python 直譯器佔用資源
    Py_Finalize();
}
```

除了使用前先 initialize，使用後 finalize 外，還要記得設一下 Python search path，否則會搜不到 module。

##### Step 3: 編譯 & 執行程式

用 gcc 編譯程式，產生 `main` 執行檔：

```bash
$ gcc $(python3-config --cflags --ldflags) main.c -o main
```

這邊為了能夠啟用 Python C extension，需要傳入一些必要參數，而 [`python3-config`](https://helpmanual.io/man1/python3-config/) 即是幫我們印出這些參數傳給 gcc。

接著執行：

```bash
$ ./main
>>> 10
```

> 如果不幸在編譯時報錯，例如： 
>
> `ld: library not found for -lpython3.6m`  
>
> 那很有可能是系統安裝的 Python 和你自己安裝的 Python 讓路徑產生混淆。 
>
> 解決辦法如[此文件](https://docs.python.org/3.6/extending/embedding.html#compiling-and-linking-under-unix-like-systems)所建議，在 `python3-config` 前加上絕對路徑。有裝 Anaconda 的可能是 `/anaconda3/bin/python3-config`，自己裝 Python 的可能是 `/usr/local/bin/python3-config`，系統預設的可能是 `/usr/bin/python3-config` 等等，有錯即嘗試另一種。 
>
> 當然，實際路徑因作業系統和安裝情況而異，請先行確認路徑中是否有 `python3-config` 或 `pythonX.Y-config`。

### [Cython](http://docs.cython.org/en/latest/)

相信大家有生之年一定都不想自己處理什麼 reference count 的問題。Cython 是一個跟 Python 寫起來很像的語言，能夠方便且快速的建立 C 的 extension，不只達到 Python 的開發速度，亦能達到 C 的效能。

先安裝起來：

```bash
$ pip3 install Cython
```

假設我們有個 `complex_and_slow_calc` function 不只寫起來複雜，效能又低：

```python
def complex_and_slow_calc(x, a, b):
    return round(math.sqrt(a * x + b))
```

Cython 可以定義針對 Python、C、或兩者的 function。我們把上述 `complex_and_slow_calc` function 用三種寫法一起實現。

以下四步驟調用：

##### Step 1: 用 Cython 取代 Python

先把 Cython 寫在 `speedup_dev_and_performance.pyx` 裡，寫法與 Python 極為相似：

```python
import math 


# Python
def complex_and_slow_calc_p(x, a, b):
    return round(math.sqrt(a * x + b))

# C
cdef public int complex_and_slow_calc_c(int x, int a, int b):
    return round(math.sqrt(a * x + b))

# Python & C
cpdef public int complex_and_slow_calc_cp(int x, int a, int b):
    return round(math.sqrt(a * x + b))
```

依照你的 function 需要被 Python  或 C 或兩者調用，有以上三種寫法，`def`、`cdef`、和 `cpdef`，來建立 Python function 或 C function；C function 的優化比較多，速度也比較快。[這邊](http://notes-on-cython.readthedocs.io/en/latest/function_declarations.html)有比較詳細的解釋。當然，你只需要針對需求選一個寫就好，這邊同時示範三種寫法，命名用 `_p / _c / _cp` 後綴來區別。C function 的 argument 及 return value 都要明確定義 type，跟 C 同理。

如果在 `def` 後加上 `public`，那麼這個 function 就會出現在產生的 `*.h` 標頭檔裡，所以如果有想要給外部 C 檔調用的 function，也就是我們等一下要做的事，便能加上 `public`。

##### Step 2: 建立 Extension

同樣使用 `setup.py` 和 `Distutils` 來建立 extension：

```python
from distutils.core import setup
from Cython.Build import cythonize

setup(ext_modules=cythonize('speedup_dev_and_performance.pyx'))
```

下指令，產生 `*.so`，`*.c`，和 `*.h`：

```
$ python3 setup.py build_ext --inplace
```

##### Step 3: 呼叫 Function

有了標頭檔 `speedup_dev_and_performance.h`，我們建立一個 `main.c` 來調用：

```c
#include <Python.h>
#include "speedup_dev_and_performance.h"

int main() {
    // Init module & Python 直譯器 
    PyImport_AppendInittab("speedup_dev_and_performance", PyInit_speedup_dev_and_performance);
    Py_Initialize();
    PyImport_ImportModule("speedup_dev_and_performance");
    
    // 呼叫 function
    printf("%d\n", complex_and_slow_calc_c(3, 2, 4));

    // 釋放 Python 直譯器佔用資源
    Py_Finalize();
}
```

這邊注意到 initialization 多了幾個步驟：

1. `PyImport_AppendInittab` 把我們要匯入的 module `speedup_dev_and_performance` 加到 built-in module table
2. `Py_Initialize` initialize Python 直譯器 
3. 再呼叫 `PyImport_ImportModule` ，也就是匯入 module， 才能真正 initialize module，因其內部呼叫 `PyInit_speedup_dev_and_performance`

`PyInit_<module>` 是在上上步 `*.h` 檔裡自動生成的。記得我們的 `complex_and_slow_calc` 有 `import math` 嗎？如果沒有這第三步，`import math` 就會失敗。

##### Step 4: 編譯 & 執行程式

同樣用 gcc 編譯程式，產生 `main` 執行檔後執行：

```bash
$ gcc $(python3-config --cflags --ldflags) main.c speedup_dev_and_performance.c -o main 
$ ./main
>>> 3 
```

## 比較

說了這麼多，這些方法有哪些優缺點，適合什麼時候用呢？

||優點|缺點|
|:-:|---|---|
| Python/C API |最原始，最大的控制權。|Reference count 很煩。比較需要 C 的基礎。只針對 CPython。|
| ctypes |使用簡單。不需編譯。可直接使用現成 library。基本使用上不需會 C。|Type 轉換比較麻煩，尤其是 struct、union、array 這種。|
| SWIG |支援多種語言。|要寫一份煩人的 interface file。Overhead 高。|
|Cython|兼顧開發與執行效能。|跟 Python 還是不太一樣，需要學新東西。|

不過這些是很粗淺的比較，一些更深入的優劣勢還是需要真的深入使用之後才能體會。

## 結語

為了魚與熊掌兼得，前人在 C 與 Python 的整合開發上下了不少功夫，也才有這些方便的工具使用。此篇簡單介紹幾個 Python 與 C 的整合工具，尚未觸及到 C++ 或其他語言，但或許認識這些基本概念能更容易延伸到其他語言。

這些在蓬勃發展的資訊領域裡可能只是冰山一角，未來也勢必會有更強大的整合工具或新語言出現。我們能做的就是坐以待斃，喔不是，是分析清楚利弊，為自己的專案挑選最適合的工具。

## 參考資料

* [Python/C API Reference Manual](https://docs.python.org/3/c-api/intro.html)
* [Python - Extension Programming with C](https://www.tutorialspoint.com/python/python_further_extensions.htm)
* [Python Extension Patterns](http://pythonextensionpatterns.readthedocs.io/en/latest/refcount.html)
* [Extending and Embedding the Python Interpreter](https://docs.python.org/3.6/extending/extending.html)
* [ctypes — A foreign function library for Python](https://docs.python.org/3.6/library/ctypes.html)
* [SWIG Users Manual](http://www.swig.org/Doc3.0/Contents.html#Contents)
* [Cython’s Documentation](http://docs.cython.org/en/latest/)
* [Cython def, cdef and cpdef functions](http://notes-on-cython.readthedocs.io/en/latest/index.html#)
* [Python by the C side](https://www.paypal-engineering.com/2016/09/22/python-by-the-c-side/)
* [如何实现 C/C++ 与 Python 的通信？](https://www.zhihu.com/question/23003213)
* [UPenn CIS192 Python Programming: Mixing C with Python/Modules and Packages](https://www.cis.upenn.edu/~cis192/spring2015/files/lec/lec14.pdf)

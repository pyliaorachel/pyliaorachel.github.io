---
layout: post
title:  "Python的import陷阱"
categories: Blog Tech Python
tags: ["Python", "PyLadies"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

在脫離Python幼幼班準備建立稍大型的專案的時候，學習如何組織化你的Python專案是一大要點。Python提供的__module（模組）__與__package（套件）__是建立架構的基本元件，但在module之間為了重複使用一些function（函數）或class（類別）而必須互相__import（匯入）__，使用上一個不注意就會掉入混亂的import陷阱。

此篇將會從基本module和package介紹起，提點基本import語法及absolute import和relative import的用法與差異，最後舉出幾個常見因為錯誤import觀念造成的錯誤。

<!--more-->
---

_* 請注意，以下只針對Python3進行講解與測試。_

## Module與Package

基本上一個file就是一個module，裡頭可以定義function，class，和variable。  
把一個module想成一個file，那一個package就是一個folder了。Package可裝有subpackage和module，讓你的專案更條理更組織化，最後一坨打包好還能分給別人使用。


先看看module。假設有一個module `sample_module.py` 裡頭定義了一個function `sample_func` ：

```python
def sample_func():
	print('Hello!')
```

現在你在同一個目錄裡下有另一個module `sample_module_import.py` 想要重複使用這個function，這時可以直接從 `sample_module` import拿取：

```python
from sample_module import sample_func

if __name__ == '__main__':
	sample_func()
```

跑 `python3 sample_module_import.py` 會得到：

```bash
Hello!
```


再來是package。我們把上面兩個檔案包在一個新的folder `sample_package` 底下：

```bash
sample_package/
├── __init__.py
├── sample_module.py
└── sample_module_import.py
```

很重要的是新增那個 `__init__.py` 檔。它是空的沒關係，但一定要有，有點宣稱自己是一個package的味道。

這時候如果是進到 `sample_package` 裡面跑一樣的指令，那沒差。但既然都打包成package了，通常是需要在package以外的地方下指令的，這時候裡面的import就要稍微做因應。

假設這時我們在跟 `sample_package` 同一個folder底下，讓我們修正一下 `sample_package/sample_module_import.py` ：

```python
'''跑在`sample_package`底下（非常見情況）'''
# from sample_module import sample_func

'''跑在跟`sample_package`同folder底下'''
from .sample_module import sample_func
'''或'''
# from sample_package.sample_module import sample_func


if __name__ == '__main__':
    sample_func()
```

這邊兩種解來自於absolute import和relative import的選擇，等等再提。總之我們可以跑了：

```bash
$ python3 -m sample_package.sample_module_import
```

修好了。這邊[`-m`](https://docs.python.org/2/using/cmdline.html#cmdoption-m)是為了讓Python先import你要的package或module給你，然後再執行script。所以這邊 `sample_module_import` 在跑的時候，是以 `sample_package` 為環境的，這樣那些import才不會出錯。

## 基本import語法

前面有看過了，這邊統整介紹一下。如果你想使用在其他module裡定義的function、class、variable等等，就需要在使用它們之前先進行import。通常都會把需要import的module們列在整個file的最一開始，但不是必須。

```python
'''語法1：import [module]'''
# Import整個`random`module
import random

# 使用`random`module底下的`randint`function
print(random.randint(0, 5))

'''語法2：from [module] import [name1, name2, ...]'''
# 從`random`module裡import其中一個function`randint`
from random import randint 

# 不一樣的是，使用`randint`的時候就不需要先寫`random`了
print(randint(0, 5))

'''語法3：import [module] as [new_name]'''
# Import整個`random`module，但這個名字可能跟其他地方有衝突，改名成`rd`
import random as rd

# 使用`rd`這個名稱取代原本的`random`
print(rd.randint(0, 5))

'''語法4（不推薦）：from [module] import *'''
# Import所有`random`module底下的東西
from random import *

# 使用`randint`的時候也不需要先寫`random`
print(randint(0, 5))
```

語法4不推薦原因是容易造成名稱衝突，降低可讀性和可維護性。

## Absolute Import v.s. Relative Import

Python有兩種import方法，__absolute import__及__relative import__。Absolute import就是完整使用module路徑，relative import則是使用以當前package為參考的相對路徑。Relative import的需求在於，有時候在改變專案架構的時候，裡面的package和module會拉來拉去，這時候如果這些package裡面使用的是relative import的話，他們的相對關係就不會改變，也就是不需要再一一進入module裡更改路徑。但因為relative import的路徑取決於當前package，所以在哪裡執行就會造成不一樣的結果，一不小心又要噴一堆error；這時absolute import就會減少許多困擾。

這邊參考[PEP328](https://www.python.org/dev/peps/pep-0328/#guido-s-decision)提供的範例。Package架構如下：

```bash
package/
    __init__.py
    subpackage1/
        __init__.py
        moduleX.py
        moduleY.py
    subpackage2/
        __init__.py
        moduleZ.py
    moduleA.py
```

現在假設`package/subpackage1/moduleX.py`想要從其他module裡import一些東西，則使用下列語法：

```python
'''[A]表Absolute import範例；[R]表Relative import範例'''
# Import同一個package底下的sibling module `moduleY`
[A] from package.subpackage1 import moduleY
[R] from . import moduleY
[Error] import .moduleY

# 從同一個package底下的sibling module `moduleY` import `spam`這個function
[A] from package.subpackage1.moduleY import spam
[R] from .moduleY import spam

# 從隔壁package底下的module `moduleZ` import `eggs`這個function
[A] from package.subpackage2.moduleZ import eggs
[R] from ..subpackage2.moduleZ import eggs

# Import parent package底下的module `moduleA`
[A] from package import moduleA
[R] from .. import moduleA 或 from ...package import moduleA
```

要點：

1. Relative import裡，`.`代表上一層，幾個`.`就代表上幾層
2. Relative import一律採用 `from ... import ...` 語法，即使是從 `.` import也要寫 `from . import some_module` 而非 `import .some_module`。原因是`.some_module`這個名稱在expression裡無法出現。Absolute import則無限制。

## 常見import陷阱

#### Circular Import

想像一個module `A` 在一開始要import另一個module `B` 裡的東西，但在匯入module `B` 的途中必須先執行它，而很不巧的它也需要從module `A` import一些東西。但module `A`還正在執行途中，自己都還沒定義好自己的function啊！於是你不讓我我不讓你，這種類似deadlock的情形正是常見的__circular import（循環匯入）__。

讓我們看看範例。現在在 `sample_package` 裡有 `A` 和 `B` 兩個module想互打招呼，程式碼分別如下：

```python
# A.py
from .B import B_greet_back


def A_say_hello():
    print('A says hello!')
    B_greet_back()

def A_greet_back():
    print('A says hello back!')

if __name__ == '__main__':
    A_say_hello()
```

```python
# B.py
from .A import A_greet_back


def B_say_hello():
    print('B says hello!')
    A_greet_back()

def B_greet_back():
    print('B says hello back!')

if __name__ == '__main__':
    B_say_hello()
```

內容都一樣，只是`A/B`互換。`B` 很有禮貌想先打招呼。在與 `sample_package` 同目錄底下執行：

```bash
$ python3 -m sample_package.B

>>>
Traceback (most recent call last):
  File "/usr/local/Cellar/python3/3.6.2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/runpy.py", line 193, in _run_module_as_main
    "__main__", mod_spec)
  File "/usr/local/Cellar/python3/3.6.2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/runpy.py", line 85, in _run_code
    exec(code, run_globals)
  File "/path/to/sample_package/B.py", line 2, in <module>
    from .A import A_greet_back
  File "/path/to/sample_package/A.py", line 1, in <module>
    from .B import B_greet_back
  File "/path/to/sample_package/B.py", line 2, in <module>
    from .A import A_greet_back
ImportError: cannot import name 'A_greet_back'
```

觀察到了嗎？`B` 試圖import `A_greet_back`，但途中先進到 `A` 執行，而因為Python是從頭開始一行一行執行下來的，於是在定義 `A_greet_back` 之前會先碰到自己的import statement，於是又進入 `B`，然後陷入死胡同。

常見解決這種circular import的方法如下：

1. Import整個module而非單一attribute  

	把 `B.py` 更改成如下：
	
	```python
	# from .A import A_greet_back
	from . import A


	def B_say_hello():
	    print('B says hello!')
	    # A_greet_back()
	    A.A_greet_back()

	...
	```

	就不會發生錯誤：

	```bash
	$ python3 -m sample_package.B

	>>>
	B says hello!
	A says hello back!
	```

	理由是，執行 `from .A import A_greet_back` 被迫要從load進來的 `A` module object中找出 `A_greet_back` 的定義，但此時這個module object還是空的；而 `from . import A` 就只會檢查 `A` module object 存不存在，至於 `A_greet_back` 存不存在等到需要執行的時候再去找就行了。

2. 延遲import  

	把 `B.py` 更改成如下：

	```python
	# 前面全刪

	def B_say_hello():
	    from .A import A_greet_back

	    print('B says hello!')
	    A_greet_back()
	
	...
	```

	也會成功跑出結果。跟前面類似，Python在跑到這行時才會import `A` module，這時因為 `B` module都已經load完了，所以不會有circular import的問題。但這個方法比較hacky一點，大概只能在hackathon中使用，否則正式專案裡看到這種難維護的code可能會有生命危險。 
 
	另一方面，把所有import statement擺到整個module最後面也是類似效果，但也會被打。

3. 好好釐清架構，避免circular import

	是的，治本方法還是好好思考自己寫的code為什麼會陷入這種危機，然後重新refactor吧。

## Relative Import above Top-level Package

還不熟悉relative import的人常常會見到這個error：

```bash
ValueError: attempted relative import beyond top-level package
```

讓我們重現一下這個error。把 `B.py` 前頭更改成如下：

```python
# from . import A
from ..sample_package import A

...
```

現在我們的路徑位置在與 `sample_package` 同目錄底下。跑：

```bash
$ python3 -m sample_package.B

>>>
Traceback (most recent call last):
  File "/usr/local/Cellar/python3/3.6.2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/runpy.py", line 193, in _run_module_as_main
    "__main__", mod_spec)
  File "/usr/local/Cellar/python3/3.6.2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/runpy.py", line 85, in _run_code
    exec(code, run_globals)
  File "/path/to/sample_package/B.py", line 5, in <module>
    from ..sample_package import A
ValueError: attempted relative import beyond top-level package
```

所謂的 `top-level package` 就是你所執行的package中最高的那一層，也就是 `sample_package`。超過這一層的relative import是不被允許的，指的就是 `..sample_package` 這行嘗試跳兩層上去而超過 `sample_package`了。  

可以試試更改當前目錄到上一層（`cd ..`），假設叫 `parent_folder` ，然後執行 `python3 -m parent_folder.sample_package.B`，就會發現error消失了，因為現在的 `top-level package` 已經變成 `parent_folder`了。

## 結語

Import是各大語言必備功能，看似簡單，使用上來說陷阱卻頗多。如果搞不清楚Python中的import是怎麼運作的，除了在整體專案架構上難以靈活設計，更可能要陷入可怕的error海了。

我寫了一些額外的sample code放上[github](https://github.com/pyliaorachel/python-import-traps)了，有不清楚的地方可以直接參考。

## 參考資料

* [Python Documentation - Modules](https://docs.python.org/2/tutorial/modules.html)
* [Python Documnetation - the Import System](https://docs.python.org/3/reference/import.html)
* [tutorialspoint - Python Modules](https://www.tutorialspoint.com/python/python_modules.htm)
* [PEP328 -- Imports: Multi-Line and Absolute/Relative](https://www.python.org/dev/peps/pep-0328/#guido-s-decision)
* [Importing Python Modules](http://effbot.org/zone/import-confusion.htm)
* [Python 101: All about imports](https://www.blog.pythonlibrary.org/2016/03/01/python-101-all-about-imports/)

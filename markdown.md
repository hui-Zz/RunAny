# Markdown 教程

- [Markdown标题](#Markdown标题)
- [水平线](#Markdown水平线)
- [文本样式](#Markdown文本样式)
- [列表](#Markdown列表)
- [区块](#Markdown区块)
- [代码](#Markdown代码)
- [链接](#Markdown链接)
- [图片](#Markdown图片)
- [表格](#Markdown表格)

## Markdown标题

---

# h1 标题
## h2 标题
### h3 标题
#### h4 标题
##### h5 标题
###### h6 标题


## Markdown水平线

___

---

***

## Markdown文本样式

**粗体文本**

__粗体文本__

*斜体文本*

_This is italic text_

~~Strikethrough~~

***粗斜体文本***

___粗斜体文本___

<html>
<!--在这里插入内容-->
<u>下划线</u>
</html>

使用 <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>Del</kbd> 重启电脑

## Markdown列表

无序

+ Create a list by starting a line with `+`, `-`, or `*`
+ Sub-lists are made by indenting 2 spaces:
  - Marker character change forces new list start:
    * Ac tristique libero volutpat at
    + Facilisis in pretium nisl aliquet
    - Nulla volutpat aliquam velit
+ Very easy!

有序

1. Lorem ipsum dolor sit amet
2. Consectetur adipiscing elit
3. Integer molestie lorem at massa


1. You can use sequential numbers...
1. ...or keep all the numbers as `1.`


1. 第一项：
    - 第一项嵌套的第一个元素
    - 第一项嵌套的第二个元素
2. 第二项：
    - 第二项嵌套的第一个元素
    - 第二项嵌套的第一个元素

## Markdown区块
区块引用

> 最外层
> > 第一层嵌套
> > > 第二层嵌套

区块中使用列表

> 区块中使用列表
> 1. 第一项
> 2. 第二项
> + 第一项
> + 第二项
> + 第三项

列表中使用区块

* 第一项
    > 菜鸟教程
    > 学的不仅是技术更是梦想
* 第二项

## Markdown代码

Inline `code`

Indented code

    // Some comments
    line 1 of code
    line 2 of code
    line 3 of code


Block code "fences"

```
Sample text here...
```

Syntax highlighting

``` js
var foo = function (bar) {
  return bar++;
};

console.log(foo(5));
```

```math
E = mc^2
```

## Markdown链接

[有道云笔记Markdown指南](http://note.youdao.com/iyoudao/?p=2411)

[有道云笔记Markdown指南](http://note.youdao.com/iyoudao/?p=2445 "title:进阶版")

## Markdown图片

![血小板](/images/platelet11.jpg ':size=160x160')

<!-- <img src="/images/platelet21.jpg" width="50%"> -->
<img src="images/platelet21.jpg" width="50%">

![血小板](/images/platelet01.jpg)


## Markdown表格

header 1 | header 2
---|---
row 1 col 1 | row 1 col 2
row 2 col 1 | row 2 col 2

---

<details>
<summary>代码示例</summary>

```
<start>和<end>
from ... to
from ... through 包括<end>
```

```scss
@media (min-width: 992px){
@for $i from 1 through 12 {
      .col-md-#{$i} { width: #{ $i/12*100%}; }
  }
}

// 编译为：
@media (min-width: 992px) {
  .col-md-1 {
    width: 8.3333333333%;
  }

  .col-md-2 {
    width: 16.6666666667%;
  }

  .col-md-3 {
    width: 25%;
  }

  .col-md-4 {
    width: 33.3333333333%;
  }

  .col-md-5 {
    width: 41.6666666667%;
  }

  .col-md-6 {
    width: 50%;
  }

  .col-md-7 {
    width: 58.3333333333%;
  }

  .col-md-8 {
    width: 66.6666666667%;
  }

  .col-md-9 {
    width: 75%;
  }

  .col-md-10 {
    width: 83.3333333333%;
  }

  .col-md-11 {
    width: 91.6666666667%;
  }

  .col-md-12 {
    width: 100%;
  }
}
```

</details>
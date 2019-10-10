# 快速开始

推荐安装 docsify-cli 工具，可以方便创建及本地预览文档网站。

```bash
npm i docsify-cli -g
```

## 初始化项目
如果想在项目的 ./docs 目录里写文档，直接通过 init 初始化项目。

```bash
docsify init ./docs
```

## 本地预览网站

本地实时预览，默认访问 http://localhost:3000 。

```bash
docsify serve docs
# or 端口号默认3000
docsify serve docs -p 3000
```

?> 更多命令行工具用法，参考 [docsify-cli 文档](https://github.com/docsifyjs/docsify-cli)。
# 线条小狗桌面萌宠

![线条小狗桌面萌宠预览](docs/images/readme-hero.png)

一个基于 Electron 的桌面萌宠应用。线条小狗会悬浮在桌面上，可以拖拽移动、点击互动、调整大小，并支持通过命令触发任务完成动画。

## 功能

- 桌面悬浮：无边框、透明背景、置顶显示
- 原生 GIF 动画：睡觉、悬停、点击、拖拽、任务完成等状态
- 鼠标互动：悬停跳跃，点击出现爱心动画
- 拖拽移动：按住小狗即可移动位置
- 缩放调节：悬停后拖动右下角旋钮调整大小
- 快捷关闭：右键呼出关闭按钮
- 单实例运行：重复启动时复用已有窗口
- 任务完成反馈：使用启动参数播放庆祝动画

## 技术栈

- Electron
- JavaScript
- HTML
- CSS
- Node.js / npm

## 快速开始

进入源码目录并安装依赖：

```powershell
cd 源码
npm install
```

启动桌宠：

```powershell
npm start
```

触发任务完成动画：

```powershell
npm run task-complete
```

也可以直接双击根目录下的 `启动桌宠.cmd`。如果依赖尚未安装，脚本会自动进入源码目录执行安装。

## 目录结构

```text
.
├── 启动桌宠.cmd
├── heart.gif
├── jump.gif
├── sleep.gif
├── special.gif
├── usageOver3Hours.gif
├── docs/
│   └── images/
│       └── readme-hero.png
├── 快捷方式图标/
└── 源码/
    ├── assets/
    ├── index.html
    ├── main.js
    ├── package.json
    ├── pet.js
    ├── preload.js
    └── styles.css
```

## 开发说明

主进程逻辑位于 `源码/main.js`，负责创建透明置顶窗口、处理窗口移动和缩放。

桌宠交互逻辑位于 `源码/pet.js`，负责切换不同 GIF 状态、处理鼠标悬停、点击、拖拽、关闭和任务完成反馈。

界面结构和样式分别位于 `源码/index.html` 与 `源码/styles.css`。

## Git 忽略

仓库已忽略 `node_modules/`、构建产物、日志、缓存、编辑器配置和系统文件。提交代码时保留源码、资源文件、`package.json` 与 `package-lock.json` 即可。

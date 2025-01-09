# Contributing to Image Quality Report Vue

我们欢迎任何形式的贡献，包括但不限于：

- 报告问题
- 提交功能建议
- 提交代码修改
- 改进文档

## 开发流程

1. Fork 项目到你的 GitHub 账号
2. 克隆项目到本地
   ```bash
   git clone https://github.com/[你的用户名]/image-quality-report-vue.git
   cd image-quality-report-vue
   ```

3. 安装依赖
   ```bash
   npm install
   ```

4. 创建功能分支
   ```bash
   git checkout -b feature/[功能名称]
   ```

5. 提交更改
   ```bash
   git add .
   git commit -m "描述更改内容"
   git push origin feature/[功能名称]
   ```

6. 创建 Pull Request

## 代码风格

- 使用 2 个空格缩进
- 组件名使用 PascalCase
- Props 名使用 camelCase
- 使用语义化的变量和函数命名

## 提交信息规范

提交信息应该清晰描述更改内容，建议使用以下格式：

- feat: 新功能
- fix: 修复问题
- docs: 文档更新
- style: 代码格式调整
- refactor: 代码重构
- test: 测试相关
- chore: 构建过程或辅助工具的变动

例如：
```
feat: 添加图片质量评分功能
fix: 修复数据展示异常问题
docs: 更新安装说明
```

## 问题反馈

如果你发现了问题或有新的想法，欢迎创建 Issue。创建 Issue 时请：

1. 使用清晰的标题
2. 详细描述问题或建议
3. 如果是问题，请提供：
   - 问题的复现步骤
   - 期望的行为
   - 实际的行为
   - 错误信息（如果有）
   - 运行环境信息

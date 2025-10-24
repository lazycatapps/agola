# Agola - CI/CD 重新定义

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## 项目简介

本项目将开源 CI/CD 平台 [Agola](https://agola.io) 移植到 Lazycat 平台，让用户能够轻松一键部署现代化的持续集成和持续部署系统。

Agola 是一个现代化的开源 CI/CD 平台，旨在重新定义构建自动化工作流。它提供了容器化、可重现和可重启的运行环境，支持高级工作流程和多种 Git 平台集成。

## 主要功能

- 🐳 **容器化执行** - 所有任务在隔离的容器环境中运行，确保可重现性
- 🔄 **可重启运行** - 从失败点恢复执行，而不是从头开始
- 🌐 **多 Git 平台支持** - 同时集成 GitHub、GitLab、Gitea 和自定义 Git 仓库
- 🚀 **高级工作流** - 支持矩阵构建、扇入扇出、多架构等复杂工作流
- ☸️ **灵活部署** - 可在 Kubernetes 集群、本地 Docker 等多种平台上运行
- 📝 **Jsonnet 配置** - 使用 Jsonnet 模板生成配置，避免复杂的 YAML
- 🔐 **强大的密钥管理** - 支持密钥和变量系统，用于环境特定测试
- ⚡ **依赖缓存** - 加速任务执行
- 🎯 **用户直接运行** - 允许在本地仓库直接执行测试
- 📊 **易于安装管理** - 支持单实例或分布式部署

## 使用方法

在 Lazycat 平台上，您可以一键部署 Agola 应用：

1. 在 Lazycat 应用商店找到 Agola 应用
2. 点击安装并等待部署完成
3. 通过分配的域名访问 Agola Web 界面
4. 连接你的 Git 平台账号（GitHub/GitLab/Gitea）
5. 在项目中添加 `.agola/config.jsonnet` 配置文件
6. 推送代码或创建 Pull Request 触发自动构建
7. 在 Web 界面查看运行状态和日志

## 致谢

- **Agola 开发团队** - 感谢创建了这个优秀的 CI/CD 平台
- **开源社区贡献者** - 感谢所有为 Agola 项目做出贡献的开发者
- **Lazycat 平台** - 提供便捷的一键部署基础设施

## 版权说明

- 本移植项目的打包配置采用 **Apache License 2.0** 授权
- Agola 软件本身采用 **Apache License 2.0** 授权
- 版权所有 © 2025 Lazycat Apps

详细许可证信息请查看 [LICENSE](LICENSE) 文件。

## 相关链接

- **Agola 官方网站**: https://agola.io
- **Agola 源代码仓库**: https://github.com/agola-io/agola
- **本项目仓库**: https://github.com/lazycatapps/agola
- **Lazycat 平台**: https://lazycat.cloud

---

**注意**: 本应用已启用后台任务，系统不会自动休眠。数据存储在 `/lzcapp/var/agola` 目录下，支持多用户同时使用。

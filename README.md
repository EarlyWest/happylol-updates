# HappyLOL Updates

HappyLOL 的公开静态更新清单与 Release 数据包。

- `manifest.json`: 客户端固定更新入口。
- Release 附件: 完整 HappyLOLData 数据包。
- `upstream.json`: 上游皮肤仓库镜像状态与回滚包入口。
- GitHub Actions 每 6 小时检查一次上游更新，并自动创建镜像 Release。
- `scripts/publish-data.ps1`: 本机一键发布新的完整基础包并更新固定清单。
- 数据文件均通过 SHA-256 校验。

玩家端平时直接做提交级增量同步，GitHub Release 用于首次安装、完整回滚和上游故障兜底，因此游戏新增皮肤时不要求重新发布 HappyLOL 主程序。

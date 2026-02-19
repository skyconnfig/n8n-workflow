# n8n Shopify 产品上新工作流

一个自动化工作流，通过 n8n 对接 Shopify，实现产品自动上新。支持 AI 生成英文文案、自动计算售价、一键发布到 Shopify 店铺。

## 功能特点

- 🤖 **AI 文案生成** - 使用 OpenAI GPT 自动生成英文标题和描述
- 💰 **智能定价** - 自动计算售价（包含进货价、处理费、运费、利润率、汇率）
- 📦 **图片处理** - 支持多图片自动上传到 Shopify
- 🔗 **一键发布** - 自动创建 Shopify 产品

## 使用前提

1. **n8n** - 自托管或云端版本 (https://n8n.io/)
2. **Shopify 店铺** - 需要 Admin API 访问权限
3. **OpenAI API** - 用于生成产品文案

## 快速开始

### 第 1 步：导入工作流

1. 下载本仓库的 JSON 文件
2. 在 n8n 中：`Workflows → Import from File`
3. 选择模板 JSON 文件

### 第 2 步：配置凭证

在 n8n 中添加以下凭证：

| 凭证类型 | 用途 | 配置方式 |
|----------|------|----------|
| Shopify Access Token | 访问 Shopify API | Shopify 后台 → 设置 → 应用和渠道 → 开发应用 → 创建应用 |
| OpenAI API | AI 文案生成 | OpenAI 平台获取 API Key |

### 第 3 步：配置参数

在【Parameter】节点配置：

| 参数 | 说明 | 示例值 |
|------|------|--------|
| handlingFee | 每单处理费 (RMB) | 28 |
| shippingCostPerKg | 运费 (RMB/kg) | 100 |
| itemWeightGrams | 产品重量 (g) | 400 |
| exchangeRate | 汇率 (RMB to USD) | 7.2 |
| profitMargin | 利润率 | 0.5 (50%) |

### 第 4 步：配置 Shopify URL

在【HTTP Request】节点中，将 URL 里的 `your-store` 改成你的店铺名：

```
https://your-store.myshopify.com/admin/api/2025-07/products.json
```

### 第 5 步：激活工作流

工作流包含一个表单触发器，激活后即可使用。

## 工作流说明

```
┌─────────────────┐
│  Form Trigger  │  ← 用户提交产品信息
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Parameter     │  ← 配置定价参数
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│  AI   │ │ Split │  ← AI 生成文案 + 处理图片
│Writing│ │  Out  │
└───┬───┘ └───┬───┘
    │         │
    ▼         ▼
┌─────────────────┐
│ Price Calculator│ ← 计算售价
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     Merge      │  ← 合并数据
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ HTTP Request   │  ← 发布到 Shopify
└─────────────────┘
```

## 定价公式

```
售价 = (进货价格 + 处理费 + 重量*运费/1000) * (1+利润率) / 汇率
```

然后取最接近的 .99 结尾（如 29.99, 39.99）

## 表单字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| 产品图片 | File | 否 | 支持多张图片 |
| 中文标题 | Text | 是 | 产品中文名称 |
| 中文描述 | Text | 否 | 产品中文描述 |
| 进货价格(RMB) | Number | 是 | 成本价 |
| SKU | Text | 是 | 产品SKU |

## 常见问题

### Q: 提交表单后没有反应
A: 检查工作流是否已激活，凭证是否正确配置

### Q: Shopify API 报错
A: 确认店铺 API 版本是否匹配，检查 Access Token 权限

### Q: AI 生成失败
A: 检查 OpenAI API Key 是否有效，确保 API 余额充足

## 依赖节点

- `n8n-nodes-base.stickyNote`
- `n8n-nodes-base.set`
- `n8n-nodes-base.aggregate`
- `n8n-nodes-base.splitOut`
- `n8n-nodes-base.extractFromFile`
- `n8n-nodes-base.merge`
- `n8n-nodes-base.httpRequest`
- `@n8n/n8n-nodes-langchain.openAi`
- `n8n-nodes-base.formTrigger`

## 相关链接

- [n8n 官网](https://n8n.io/)
- [Shopify Admin API](https://shopify.dev/docs/api/admin-rest)
- [OpenAI API](https://platform.openai.com/)

## 交流社区

有问题欢迎加入 **TBPI Studio** 社区交流：
👉 https://www.skool.com/tbpi-studio-9638

---

**作者**: TBPI Studio  
**YouTube**: https://www.youtube.com/@TBPI_Studio

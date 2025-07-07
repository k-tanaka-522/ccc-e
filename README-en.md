# Enterprise AI Agent Toolkit

An AI agent toolkit to help individual developers build enterprise-level systems.

**📖 Read this in other languages:** [日本語](README.md)

## 🎯 Features

- 🎯 **Consistent development support from requirements to operations**
- ☁️ **AWS-specific architecture auto-design**
- 🎨 **UI/UX design system generation**
- 📊 **SLO/SLI standard values presentation and selection**
- 💰 **Automatic cost estimation**
- 🤖 **Interactive wizard configuration**
- 📋 **Industry-specific template provision**

## 🚀 Quick Start

### Installation

Run the following in your new product directory:

```bash
# Method 1: Direct download (recommended)
curl -sSL https://raw.githubusercontent.com/nishimoto265/ccc-e/main/install.sh | bash

# Method 2: Install from repository
git clone https://github.com/k-tanaka-522/ccc-e.git
cd ccc-e
./install.sh
```

### Basic Usage

```bash
# 1. Project initialization
.ai-agents/wizards/project-init.sh

# 2. Requirements definition (guided mode)
.ai-agents/agents/requirements/agent.sh --wizard

# 3. Requirements definition (auto mode)
.ai-agents/agents/requirements/agent.sh --auto "Want to create an e-commerce site"

# 4. Requirements validation and update
.ai-agents/agents/requirements/agent.sh --validate
.ai-agents/agents/requirements/agent.sh --update

# 5. Requirements document export
.ai-agents/agents/requirements/agent.sh --export
```

## 🤖 Agent List

| Agent | Role | Main Features |
|-------|------|---------------|
| 📋 **Requirements Agent** | Requirements definition | Wizard, auto-generation, validation |
| 🏗️ **Architect Agent** | System design | AWS configuration, architecture diagrams |
| 🎨 **UI/UX Agent** | Design specification | Design system, wireframes |
| 💻 **Developer Agent** | Implementation support | Code generation, best practices |
| 🔧 **SRE Agent** | Operations design | Monitoring, deployment, operation automation |

## 📁 Generated File Structure

```
your-project/
├── .ai-agents/                    # Toolkit (gitignore recommended)
├── requirements/                  # Requirements definition
│   ├── index.md                  # Things to decide list
│   ├── decision_log.md           # Decision record
│   └── requirements.md           # Final requirements document
├── architecture/                 # Design materials
│   ├── design.md                # Design document
│   └── diagrams/                # Architecture diagrams
├── aws/                          # AWS configuration
│   └── cloudformation.yaml      # CloudFormation template
├── uiux/                         # UI/UX design
│   ├── design-system.md         # Design system
│   └── wireframes/              # Wireframes
└── src/                          # Actual source code
```

## 🏗️ Industry Templates

| Industry | Features | Recommended Configuration |
|----------|----------|---------------------------|
| **E-commerce** | High availability, payment system | ECS + RDS + ElastiCache |
| **SaaS** | Multi-tenant, API-centric | Lambda + DynamoDB + API Gateway |
| **Media** | High traffic, CDN | EC2 + CloudFront + S3 |
| **Enterprise** | Security-focused | VPC + EC2 + RDS |
| **Startup** | Low cost, rapid deployment | Lambda + DynamoDB |

## 📊 SLO/SLI Standard Values

| Availability | Monthly Downtime | Use Case |
|--------------|------------------|----------|
| 99.0% | 7.2 hours | Development environment |
| 99.9% | 43 minutes | Production (standard) |
| 99.95% | 21 minutes | Critical systems |
| 99.99% | 4 minutes | Mission critical |

## 💰 Cost Estimation

The toolkit presents the following cost patterns based on selected configuration:

- **Minimal configuration**: Basic functionality only
- **Recommended configuration**: Suitable for production operation
- **Redundant configuration**: High availability focused

## 🔍 Troubleshooting

### Common Issues

1. **Installation fails**
   ```bash
   # Check permissions
   chmod +x install.sh
   ./install.sh
   ```

2. **Requirements document not generated**
   ```bash
   # Check directory permissions
   ls -la requirements/
   chmod -R 755 requirements/
   ```

3. **Agents don't work**
   ```bash
   # Check execution permissions
   chmod +x .ai-agents/agents/**/*.sh
   ```

## 🤝 Contributing

Pull requests and issues are welcome!

### Participate in Development

1. Fork this repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push branch (`git push origin feature/amazing-feature`)
5. Create pull request

## 📄 License

This project is released under the [MIT License](LICENSE).

## 🙏 Acknowledgments

This toolkit is built based on knowledge and best practices cultivated in enterprise development.

---

🚀 **Supporting enterprise development for individual developers!** 🤖✨
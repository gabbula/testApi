# testApi

A modern REST API with comprehensive CI/CD pipelines, built with Node.js and Express.

[![CI](https://github.com/gabbula/testApi/workflows/Continuous%20Integration/badge.svg)](https://github.com/gabbula/testApi/actions/workflows/ci.yml)
[![CD](https://github.com/gabbula/testApi/workflows/Continuous%20Deployment/badge.svg)](https://github.com/gabbula/testApi/actions/workflows/cd.yml)
[![CodeQL](https://github.com/gabbula/testApi/workflows/CodeQL%20Security%20Analysis/badge.svg)](https://github.com/gabbula/testApi/actions/workflows/codeql-analysis.yml)

## 🚀 Features

- **RESTful API** built with Express.js
- **Comprehensive Testing** with Jest (unit and integration tests)
- **Security First** with Helmet, CORS, and security scanning
- **Code Quality** with ESLint, Prettier, and pre-commit hooks
- **CI/CD Pipelines** with GitHub Actions
- **Docker Support** for containerized deployment
- **Health Checks** and monitoring endpoints
- **Environment Configuration** for different deployment stages

## 📋 Prerequisites

- Node.js (>= 18.0.0)
- npm (>= 9.0.0)
- Docker (optional, for containerized deployment)

## 🛠️ Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/gabbula/testApi.git
   cd testApi
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create environment file:
   ```bash
   cp .env.example .env
   ```

4. Start the development server:
   ```bash
   npm run dev
   ```

The API will be available at `http://localhost:3000`

## 🏃‍♂️ Usage

### Health Check
```bash
curl http://localhost:3000/health
```

### Get Users
```bash
curl http://localhost:3000/api/v1/users
```

### Create User
```bash
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

## 🧪 Testing

### Run all tests
```bash
npm test
```

### Run tests with coverage
```bash
npm run test:coverage
```

### Run integration tests
```bash
npm run test:integration
```

### Watch mode
```bash
npm run test:watch
```

## 🔍 Code Quality

### Linting
```bash
npm run lint        # Check for issues
npm run lint:fix    # Fix issues automatically
```

### Formatting
```bash
npm run format:check # Check formatting
npm run format       # Format code
```

## 🐳 Docker

### Build image
```bash
docker build -t testapi:latest .
```

### Run container
```bash
docker run -p 3000:3000 --env-file .env testapi:latest
```

## 🚀 CI/CD Pipelines

This project includes comprehensive CI/CD pipelines with GitHub Actions:

### Continuous Integration (`ci.yml`)
- **Code Quality Checks**: ESLint, Prettier, Python linting
- **Security Scanning**: Trivy vulnerability scanner, CodeQL analysis
- **Multi-Environment Testing**: Development and staging environments
- **Build Verification**: Node.js build, Docker build test
- **Integration Testing**: Database and Redis integration tests
- **Coverage Reporting**: Automated test coverage uploads

### Continuous Deployment (`cd.yml`)
- **Container Building**: Multi-platform Docker images (amd64/arm64)
- **Staging Deployment**: Automatic deployment on main branch
- **Production Deployment**: Triggered by version tags or manual dispatch
- **Smoke Testing**: Post-deployment health verification
- **Rollback Support**: Automatic rollback on deployment failures

### Security Analysis (`codeql-analysis.yml`)
- **Static Code Analysis**: JavaScript and Python security scanning
- **Scheduled Scans**: Weekly automated security audits
- **Vulnerability Reporting**: Integration with GitHub Security tab

### Dependency Management
- **Dependabot**: Automated dependency updates
- **Security Patches**: Automatic security update PRs
- **Multi-Ecosystem Support**: Node.js, Python, Docker, GitHub Actions

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment (development/staging/production) | `development` |
| `PORT` | Server port | `3000` |
| `API_VERSION` | API version | `v1` |
| `LOG_LEVEL` | Logging level | `info` |

### Pipeline Configuration

The CI/CD pipelines are configured to:
- ✅ Run on every push to `main` and `develop` branches
- ✅ Run on all pull requests
- ✅ Support manual deployment triggers
- ✅ Use matrix builds for multiple environments
- ✅ Cache dependencies for faster builds
- ✅ Provide detailed logging and notifications

## 📁 Project Structure

```
testApi/
├── .github/                    # GitHub configuration
│   ├── workflows/             # GitHub Actions workflows
│   │   ├── ci.yml            # Continuous Integration
│   │   ├── cd.yml            # Continuous Deployment
│   │   └── codeql-analysis.yml # Security analysis
│   ├── ISSUE_TEMPLATE/       # Issue templates
│   ├── dependabot.yml        # Dependency updates config
│   └── pull_request_template.md # PR template
├── src/                      # Source code
│   └── app.js               # Main application
├── tests/                   # Test files
│   ├── unit/               # Unit tests
│   └── integration/        # Integration tests
├── Dockerfile              # Container configuration
├── .env.example           # Environment template
├── .eslintrc.json         # ESLint configuration
├── .prettierrc            # Prettier configuration
├── .gitignore             # Git ignore rules
└── package.json           # Project configuration
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Workflow

1. **Pre-commit hooks** ensure code quality
2. **CI pipeline** validates all changes
3. **Integration tests** verify functionality
4. **Security scans** check for vulnerabilities
5. **Code review** process ensures quality

## 📊 Monitoring

- Health endpoint: `/health`
- Metrics collection ready
- Error tracking integrated
- Performance monitoring configured

## 🔒 Security

- Helmet.js for security headers
- CORS configuration
- Input validation with Joi
- Automated vulnerability scanning
- Dependency security audits
- CodeQL static analysis

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:

1. Check the [Issues](https://github.com/gabbula/testApi/issues) page
2. Create a new issue with the appropriate template
3. Review the [Contributing Guidelines](CONTRIBUTING.md)

---

**Built with ❤️ using modern DevOps practices**
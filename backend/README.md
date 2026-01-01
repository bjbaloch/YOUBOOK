# YOUBOOK Backend API

A production-ready FastAPI backend for the YOUBOOK multi-service booking platform.

## 🚀 Features

- **Authentication**: Supabase Auth integration with JWT
- **Database**: PostgreSQL with Supabase (auto-scaling)
- **Security**: Rate limiting, CORS, RLS policies
- **Monitoring**: Request logging and health checks
- **Scalability**: Async operations, connection pooling
- **API**: RESTful design with automatic OpenAPI docs

## 📋 Prerequisites

- Python 3.9+
- Supabase account and project
- Environment variables configured

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your actual values
   ```

## ⚙️ Configuration

### Required Environment Variables

```bash
# Security (CHANGE IN PRODUCTION!)
SECRET_KEY=your-super-secret-key-here-minimum-32-characters
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key

# Supabase
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key

# Optional
OPENCAGE_API_KEY=your-opencage-api-key
DATABASE_URL=postgresql://user:password@localhost/youbook
```

### Supabase Setup

1. **Apply Database Schema**
   ```bash
   # Copy schema to Supabase SQL Editor and run
   cat supabase_schema.sql
   ```

2. **Configure Authentication**
   - Enable email confirmation in Supabase Auth settings
   - Set up SMTP for email delivery

## 🚀 Running the Application

### Development
```bash
python main.py
# Or with uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Production
```bash
# Using gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000

# Using uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000
```

## 🔒 Security Features

### Rate Limiting
- Global: 100 requests/minute per IP
- Manager applications: 5 per minute per IP
- Configurable via environment variables

### CORS Protection
- Restricted to specific origins only
- No wildcard origins in production

### Authentication
- JWT tokens with expiration
- Supabase Auth integration
- Role-based access control

### Data Protection
- Row Level Security (RLS) policies
- Encrypted sensitive data
- Input validation and sanitization

## 📊 Monitoring

### Health Checks
```
GET /health
```

### Request Logging
- All requests logged with timing
- Error tracking and monitoring
- Performance metrics

### Metrics (Future Enhancement)
- Response times
- Error rates
- User activity
- Database performance

## 🔧 API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/signup` - User registration

### Profiles
- `GET /api/v1/profile` - Get user profile
- `PUT /api/v1/profile` - Update user profile
- `POST /api/v1/profile/apply-manager` - Apply for manager role
- `GET /api/v1/profile/manager-application` - Get application status

### Health
- `GET /health` - Health check

## 🧪 Testing

```bash
# Run tests (when implemented)
pytest

# API testing with Swagger UI
# Visit http://localhost:8000/docs
```

## 🚀 Deployment

### Docker
```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Cloud Platforms

#### Railway
1. Connect GitHub repository
2. Set environment variables
3. Deploy

#### Render
1. Create Web Service
2. Connect repository
3. Configure build and start commands

#### Heroku
1. Create app
2. Set buildpacks
3. Configure environment variables

## 🔍 Troubleshooting

### Common Issues

1. **"Invalid API key"**
   - Check SUPABASE_SERVICE_ROLE_KEY in environment

2. **CORS errors**
   - Verify BACKEND_CORS_ORIGINS includes your domain

3. **Rate limiting**
   - Check logs for rate limit violations
   - Adjust limits in code if needed

4. **Database connection**
   - Ensure Supabase project is active
   - Check network connectivity

### Logs
```bash
# View application logs
tail -f logs/app.log

# View uvicorn logs
uvicorn main:app --log-level debug
```

## 📈 Performance Optimization

### Database
- Indexes on frequently queried columns
- Query optimization
- Connection pooling via Supabase

### Caching (Future)
- Redis for session storage
- CDN for static assets
- API response caching

### Scaling
- Horizontal scaling with load balancer
- Database read replicas
- Microservices architecture (future)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request

## 📄 License

[Your License Here]

## 📞 Support

For support, email youbook210@gmail.com or join our Discord community.

---

**⚠️ Security Notice**: Never commit `.env` files or expose secret keys in your code. Always use environment variables for sensitive configuration.
